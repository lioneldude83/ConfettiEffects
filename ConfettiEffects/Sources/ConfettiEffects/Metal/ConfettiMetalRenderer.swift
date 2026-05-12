//
//  ConfettiMetalRenderer.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import MetalKit

final class ConfettiMetalRenderer: NSObject, MTKViewDelegate {
    static let isSupported = MTLCreateSystemDefaultDevice() != nil
    
    private struct RuntimeParticle {
        var position: SIMD2<Float>
        var velocity: SIMD2<Float>
        var size: SIMD2<Float>
        var rotation: Float
        var angularVelocity: Float
        var color: SIMD4<Float>
        var age: Float
        var lifetime: Float
        var drag: Float
        var shape: UInt32
    }
    
    private struct ConfettiVertex {
        var position: SIMD2<Float>
    }
    
    private struct ConfettiInstance {
        var position: SIMD2<Float>
        var size: SIMD2<Float>
        var rotation: Float
        var alpha: Float
        var color: SIMD4<Float>
        var shape: UInt32
    }
    
    private struct GPUConfettiParticle {
        var position: SIMD2<Float>
        var velocity: SIMD2<Float>
        var size: SIMD2<Float>
        var rotation: Float
        var angularVelocity: Float
        var color: SIMD4<Float>
        var age: Float
        var lifetime: Float
        var drag: Float
        var shape: UInt32
        var isActive: Float
    }
    
    private struct Uniforms {
        var viewportSize: SIMD2<Float>
    }
    
    private struct ComputeUniforms {
        var deltaTime: Float
        var gravity: Float
        var particleCount: UInt32
        var padding: UInt32 = 0
    }
    
    private let maxParticles = 5_000
    private let fixedTimeStep: Float = 1 / 60
    
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let computePipelineState: MTLComputePipelineState
    private let vertexBuffer: MTLBuffer
    private let instanceBuffer: MTLBuffer
    private let gpuParticleBuffer: MTLBuffer
    
    private var configuration = ConfettiConfiguration()
    private var executionMode: ConfettiResolvedExecutionMode = .metalCPUSimulation
    private var canvasSize: CGSize = .zero
    private var cpuParticles: [RuntimeParticle] = []
    private var gpuParticleAges: [Float] = []
    private var gpuParticleLifetimes: [Float] = []
    private var currentGPUInstanceCount = 0
    private var lastTimestamp: CFTimeInterval = 0
    private var isActive = false
    
    var onActivityChanged: (@MainActor (Bool) -> Void)?
    
    @MainActor
    init?(mtkView: MTKView) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue()
        else {
            return nil
        }
        
        do {
            let library = try device.makeDefaultLibrary(bundle: .module)
            
            let renderDescriptor = MTLRenderPipelineDescriptor()
            renderDescriptor.label = "ConfettiEffects.RenderPipeline"
            renderDescriptor.vertexFunction = library.makeFunction(name: "confettiVertex")
            renderDescriptor.fragmentFunction = library.makeFunction(name: "confettiFragment")
            renderDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            renderDescriptor.colorAttachments[0].isBlendingEnabled = true
            renderDescriptor.colorAttachments[0].rgbBlendOperation = .add
            renderDescriptor.colorAttachments[0].alphaBlendOperation = .add
            renderDescriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            renderDescriptor.colorAttachments[0].sourceAlphaBlendFactor = .one
            renderDescriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            renderDescriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            self.pipelineState = try device.makeRenderPipelineState(descriptor: renderDescriptor)
            
            guard let computeFunction = library.makeFunction(name: "confettiUpdateParticles") else {
                return nil
            }
            self.computePipelineState = try device.makeComputePipelineState(function: computeFunction)
        } catch {
            return nil
        }
        
        guard
            let vertexBuffer = device.makeBuffer(
                bytes: [
                    ConfettiVertex(position: SIMD2(-0.5, -0.5)),
                    ConfettiVertex(position: SIMD2(0.5, -0.5)),
                    ConfettiVertex(position: SIMD2(-0.5, 0.5)),
                    ConfettiVertex(position: SIMD2(0.5, 0.5)),
                ],
                length: MemoryLayout<ConfettiVertex>.stride * 4
            ),
            let instanceBuffer = device.makeBuffer(length: MemoryLayout<ConfettiInstance>.stride * maxParticles),
            let gpuParticleBuffer = device.makeBuffer(length: MemoryLayout<GPUConfettiParticle>.stride * maxParticles)
        else {
            return nil
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.vertexBuffer = vertexBuffer
        self.instanceBuffer = instanceBuffer
        self.gpuParticleBuffer = gpuParticleBuffer
        super.init()
        
        mtkView.device = device
    }
    
    @MainActor
    func update(
        emissions: [ConfettiEmission],
        configuration: ConfettiConfiguration,
        executionMode: ConfettiResolvedExecutionMode,
        canvasSize: CGSize
    ) -> Bool {
        self.configuration = configuration
        self.executionMode = executionMode
        self.canvasSize = canvasSize
        rebuildSimulation(from: emissions, referenceDate: Date())
        lastTimestamp = 0
        
        let isActive = hasActiveParticles
        notifyIfNeeded(isActive: isActive)
        return isActive
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
    
    func draw(in view: MTKView) {
        guard
            canvasSize.width > 0,
            canvasSize.height > 0,
            let renderPassDescriptor = view.currentRenderPassDescriptor,
            let drawable = view.currentDrawable,
            let commandBuffer = commandQueue.makeCommandBuffer()
        else {
            return
        }
        
        let deltaTime = frameDeltaTime(for: CACurrentMediaTime())
        let activeParticleCount = updateParticles(deltaTime: deltaTime, commandBuffer: commandBuffer)
        
        guard activeParticleCount > 0 else {
            notifyIfNeeded(isActive: false)
            return
        }
        
        var uniforms = Uniforms(
            viewportSize: SIMD2(Float(canvasSize.width), Float(canvasSize.height))
        )
        
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            return
        }
        
        encoder.label = "ConfettiEffects.Draw"
        encoder.setRenderPipelineState(pipelineState)
        encoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        encoder.setVertexBuffer(instanceBuffer, offset: 0, index: 1)
        encoder.setVertexBytes(&uniforms, length: MemoryLayout<Uniforms>.stride, index: 2)
        encoder.drawPrimitives(
            type: .triangleStrip,
            vertexStart: 0,
            vertexCount: 4,
            instanceCount: activeParticleCount
        )
        encoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
        notifyIfNeeded(isActive: true)
    }
    
    private var hasActiveParticles: Bool {
        switch executionMode {
        case .cpuCanvas:
            return false
        case .metalCPUSimulation:
            return cpuParticles.isEmpty == false
        case .metalGPUSimulation:
            return gpuParticleAges.indices.contains { gpuParticleAges[$0] < gpuParticleLifetimes[$0] }
        }
    }
    
    private func rebuildSimulation(from emissions: [ConfettiEmission], referenceDate: Date) {
        cpuParticles.removeAll(keepingCapacity: true)
        gpuParticleAges.removeAll(keepingCapacity: true)
        gpuParticleLifetimes.removeAll(keepingCapacity: true)
        currentGPUInstanceCount = 0
        
        guard canvasSize.width > 0, canvasSize.height > 0 else {
            return
        }
        
        let origin = configuration.resolvedOrigin(in: canvasSize)
        let palette = configuration.palette.metalColors
        var rebuiltParticles: [RuntimeParticle] = []
        rebuiltParticles.reserveCapacity(min(maxParticles, emissions.reduce(0) { $0 + $1.particles.count }))
        
        for emission in emissions {
            let elapsed = max(0, Float(referenceDate.timeIntervalSince(emission.birthDate)))
            
            for particle in emission.particles {
                let color = palette[particle.colorIndex % palette.count]
                let runtimeParticle = RuntimeParticle(
                    position: SIMD2(
                        Float(origin.x + particle.position.x),
                        Float(origin.y + particle.position.y)
                    ),
                    velocity: SIMD2(Float(particle.velocity.dx), Float(particle.velocity.dy)),
                    size: SIMD2(Float(particle.size.width), Float(particle.size.height)),
                    rotation: Float(particle.rotation.radians),
                    angularVelocity: Float(particle.angularVelocity),
                    color: color,
                    age: 0,
                    lifetime: Float(particle.lifetime),
                    drag: Float(particle.drag),
                    shape: shapeValue(for: particle.shape)
                )
                
                if let advancedParticle = advanceToAge(runtimeParticle, elapsed: elapsed) {
                    rebuiltParticles.append(advancedParticle)
                }
                
                if rebuiltParticles.count >= maxParticles {
                    break
                }
            }
            
            if rebuiltParticles.count >= maxParticles {
                break
            }
        }
        
        switch executionMode {
        case .cpuCanvas:
            break
        case .metalCPUSimulation:
            cpuParticles = rebuiltParticles
            populateInstanceBuffer(from: rebuiltParticles)
        case .metalGPUSimulation:
            loadGPUBuffer(with: rebuiltParticles)
        }
    }
    
    private func updateParticles(deltaTime: Float, commandBuffer: MTLCommandBuffer) -> Int {
        switch executionMode {
        case .cpuCanvas:
            return 0
        case .metalCPUSimulation:
            updateParticlesCPU(deltaTime: deltaTime)
            populateInstanceBuffer(from: cpuParticles)
            return cpuParticles.count
        case .metalGPUSimulation:
            return updateParticlesGPU(deltaTime: deltaTime, commandBuffer: commandBuffer)
        }
    }
    
    private func updateParticlesCPU(deltaTime: Float) {
        for index in cpuParticles.indices.reversed() {
            guard advanceParticle(&cpuParticles[index], deltaTime: deltaTime) else {
                cpuParticles.remove(at: index)
                continue
            }
        }
    }
    
    private func updateParticlesGPU(deltaTime: Float, commandBuffer: MTLCommandBuffer) -> Int {
        guard currentGPUInstanceCount > 0 else {
            return 0
        }
        
        for index in 0..<currentGPUInstanceCount {
            gpuParticleAges[index] += deltaTime
        }
        
        let activeParticleCount = compactGPUParticles()
        
        guard activeParticleCount > 0 else {
            currentGPUInstanceCount = 0
            return 0
        }
        
        var uniforms = ComputeUniforms(
            deltaTime: deltaTime,
            gravity: Float(configuration.gravity),
            particleCount: UInt32(currentGPUInstanceCount)
        )
        
        guard let encoder = commandBuffer.makeComputeCommandEncoder() else {
            return 0
        }
        
        encoder.label = "ConfettiEffects.Compute"
        encoder.setComputePipelineState(computePipelineState)
        encoder.setBuffer(gpuParticleBuffer, offset: 0, index: 0)
        encoder.setBuffer(instanceBuffer, offset: 0, index: 1)
        encoder.setBytes(&uniforms, length: MemoryLayout<ComputeUniforms>.stride, index: 2)
        
        let threadWidth = computePipelineState.threadExecutionWidth
        let threadsPerThreadgroup = MTLSize(width: threadWidth, height: 1, depth: 1)
        let threadgroupsPerGrid = MTLSize(
            width: (currentGPUInstanceCount + threadWidth - 1) / threadWidth,
            height: 1,
            depth: 1
        )
        
        encoder.dispatchThreadgroups(threadgroupsPerGrid, threadsPerThreadgroup: threadsPerThreadgroup)
        encoder.endEncoding()
        
        return currentGPUInstanceCount
    }
    
    private func compactGPUParticles() -> Int {
        guard currentGPUInstanceCount > 0 else {
            return 0
        }
        
        let particlePointer = gpuParticleBuffer.contents().bindMemory(
            to: GPUConfettiParticle.self,
            capacity: maxParticles
        )
        let instancePointer = instanceBuffer.contents().bindMemory(
            to: ConfettiInstance.self,
            capacity: maxParticles
        )
        
        var writeIndex = 0
        
        for readIndex in 0..<currentGPUInstanceCount {
            guard gpuParticleAges[readIndex] < gpuParticleLifetimes[readIndex] else {
                continue
            }
            
            if writeIndex != readIndex {
                particlePointer[writeIndex] = particlePointer[readIndex]
                particlePointer[writeIndex].age = gpuParticleAges[readIndex]
                particlePointer[writeIndex].isActive = 1
                instancePointer[writeIndex] = instancePointer[readIndex]
                gpuParticleAges[writeIndex] = gpuParticleAges[readIndex]
                gpuParticleLifetimes[writeIndex] = gpuParticleLifetimes[readIndex]
            } else {
                particlePointer[writeIndex].age = gpuParticleAges[readIndex]
            }
            
            writeIndex += 1
        }
        
        if writeIndex < currentGPUInstanceCount {
            gpuParticleAges.removeSubrange(writeIndex..<currentGPUInstanceCount)
            gpuParticleLifetimes.removeSubrange(writeIndex..<currentGPUInstanceCount)
            currentGPUInstanceCount = writeIndex
        }
        
        return writeIndex
    }
    
    private func populateInstanceBuffer(from particles: [RuntimeParticle]) {
        let pointer = instanceBuffer.contents().bindMemory(
            to: ConfettiInstance.self,
            capacity: maxParticles
        )
        
        for (index, particle) in particles.enumerated() {
            pointer[index] = ConfettiInstance(
                position: particle.position,
                size: particle.size,
                rotation: particle.rotation,
                alpha: particleOpacity(for: particle.age, lifetime: particle.lifetime),
                color: particle.color,
                shape: particle.shape
            )
        }
    }
    
    private func loadGPUBuffer(with particles: [RuntimeParticle]) {
        currentGPUInstanceCount = particles.count
        gpuParticleAges = particles.map(\.age)
        gpuParticleLifetimes = particles.map(\.lifetime)
        
        let particlePointer = gpuParticleBuffer.contents().bindMemory(
            to: GPUConfettiParticle.self,
            capacity: maxParticles
        )
        let instancePointer = instanceBuffer.contents().bindMemory(
            to: ConfettiInstance.self,
            capacity: maxParticles
        )
        
        for (index, particle) in particles.enumerated() {
            particlePointer[index] = GPUConfettiParticle(
                position: particle.position,
                velocity: particle.velocity,
                size: particle.size,
                rotation: particle.rotation,
                angularVelocity: particle.angularVelocity,
                color: particle.color,
                age: particle.age,
                lifetime: particle.lifetime,
                drag: particle.drag,
                shape: particle.shape,
                isActive: 1
            )
            
            instancePointer[index] = ConfettiInstance(
                position: particle.position,
                size: particle.size,
                rotation: particle.rotation,
                alpha: particleOpacity(for: particle.age, lifetime: particle.lifetime),
                color: particle.color,
                shape: particle.shape
            )
        }
    }
    
    private func advanceToAge(_ particle: RuntimeParticle, elapsed: Float) -> RuntimeParticle? {
        guard elapsed > 0 else {
            return particle
        }
        
        var advancedParticle = particle
        var remaining = elapsed
        
        while remaining > 0 {
            let deltaTime = min(fixedTimeStep, remaining)
            guard advanceParticle(&advancedParticle, deltaTime: deltaTime) else {
                return nil
            }
            remaining -= deltaTime
        }
        
        return advancedParticle
    }
    
    private func advanceParticle(_ particle: inout RuntimeParticle, deltaTime: Float) -> Bool {
        particle.age += deltaTime
        
        guard particle.age < particle.lifetime else {
            return false
        }
        
        particle.velocity.y += Float(configuration.gravity) * deltaTime
        let dragFactor = max(0.72, 1 - (particle.drag * deltaTime))
        particle.velocity *= dragFactor
        particle.position += particle.velocity * deltaTime
        particle.rotation += particle.angularVelocity * deltaTime
        return true
    }
    
    private func frameDeltaTime(for timestamp: CFTimeInterval) -> Float {
        guard lastTimestamp != 0 else {
            lastTimestamp = timestamp
            return fixedTimeStep
        }
        
        let deltaTime = min(Float(timestamp - lastTimestamp), 1 / 24)
        lastTimestamp = timestamp
        return deltaTime
    }
    
    private func particleOpacity(for age: Float, lifetime: Float) -> Float {
        let fadeStart: Float = 0.72
        let progress = max(0, min(age / lifetime, 1))
        
        guard progress > fadeStart else {
            return 1
        }
        
        let normalizedFade = (progress - fadeStart) / (1 - fadeStart)
        let easedFade = normalizedFade * normalizedFade * (3 - (2 * normalizedFade))
        return max(0, 1 - easedFade)
    }
    
    private func shapeValue(for shape: ConfettiConfiguration.Shape) -> UInt32 {
        switch shape {
        case .circle:
            return 0
        case .rectangle:
            return 1
        case .roundedRectangle:
            return 2
        }
    }
    
    private func notifyIfNeeded(isActive: Bool) {
        guard self.isActive != isActive else {
            return
        }
        
        self.isActive = isActive
        let onActivityChanged = self.onActivityChanged
        
        Task { @MainActor in
            onActivityChanged?(isActive)
        }
    }
}
