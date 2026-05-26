//
//  ConfettiEffectsTests.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import CoreGraphics
import Foundation
import MetalKit
import Testing
@testable import ConfettiEffects

@Test func configurationNormalizesValues() {
    let configuration = ConfettiConfiguration(
        particleCount: -12,
        lifetime: 0,
        spread: .degrees(-30),
        initialVelocity: 300...520,
        drag: -2,
        angularVelocity: -8...8,
        particleScale: -1,
        sparkleSharpness: 8,
        glintCircleOpacity: 2,
        glintCircleScale: 2,
        shapes: []
    )
    let lowerBoundConfiguration = ConfettiConfiguration(
        sparkleSharpness: 1,
        glintCircleScale: 0.2
    )
    
    #expect(configuration.particleCount == 0)
    #expect(configuration.lifetime == 0.1)
    #expect(configuration.spread == .degrees(0))
    #expect(configuration.initialVelocity == 300...520)
    #expect(configuration.drag == 0)
    #expect(configuration.angularVelocity == -8...8)
    #expect(configuration.particleScale == 0)
    #expect(configuration.sparkleSharpness == 5)
    #expect(configuration.glintCircleOpacity == 1)
    #expect(configuration.glintCircleScale == 1)
    #expect(configuration.shapes == ConfettiConfiguration.Shape.allCases)
    #expect(lowerBoundConfiguration.sparkleSharpness == 1.5)
    #expect(lowerBoundConfiguration.glintCircleScale == 0.5)
}

@Test func automaticBackendPrefersMetalWhenAvailable() {
    let configuration = ConfettiConfiguration(particleCount: 24, backend: .automatic)
    
    #expect(configuration.resolvedBackend(isMetalAvailable: true) == .metal)
    #expect(configuration.resolvedExecutionMode(isMetalAvailable: true) == .metalCPUSimulation)
    #expect(configuration.resolvedExecutionMode(isMetalAvailable: false) == .cpuCanvas)
}

@Test func automaticBackendCanSelectMetalForLargeBursts() {
    let configuration = ConfettiConfiguration(
        particleCount: ConfettiConfiguration.automaticMetalParticleThreshold,
        backend: .automatic
    )
    
    #expect(configuration.resolvedBackend(isMetalAvailable: true) == .metal)
    #expect(configuration.resolvedBackend(isMetalAvailable: false) == .cpu)
}

@Test func automaticBackendCanSelectMetalForHighDensityCanvas() {
    let configuration = ConfettiConfiguration(
        particleCount: 40,
        backend: .automatic
    )
    
    #expect(
        configuration.resolvedBackend(
            isMetalAvailable: true,
            canvasSize: CGSize(width: 430, height: 932),
            displayScale: 3,
            liveParticleCount: 80
        ) == .metal
    )
}

@Test func automaticExecutionModeCanSelectGPUForLargeBursts() {
    let configuration = ConfettiConfiguration(
        particleCount: ConfettiConfiguration.automaticMetalParticleThreshold,
        backend: .automatic
    )
    
    #expect(configuration.resolvedExecutionMode(isMetalAvailable: true) == .metalGPUSimulation)
}

@Test func automaticExecutionModeCanSelectGPUEarlyForHighDensityCanvas() {
    let configuration = ConfettiConfiguration(
        particleCount: ConfettiConfiguration.automaticMetalHighDensityThreshold,
        backend: .automatic
    )
    
    #expect(
        configuration.resolvedExecutionMode(
            isMetalAvailable: true,
            canvasSize: CGSize(width: 430, height: 932),
            displayScale: 3
        ) == .metalGPUSimulation
    )
}

@Test func explicitBackendModesResolveExpectedRenderers() {
    let cpuConfiguration = ConfettiConfiguration(backend: .cpu)
    let metalConfiguration = ConfettiConfiguration(backend: .metal)
    
    #expect(cpuConfiguration.resolvedBackend(isMetalAvailable: true) == .cpu)
    #expect(cpuConfiguration.resolvedExecutionMode(isMetalAvailable: true) == .cpuCanvas)
    #expect(metalConfiguration.resolvedBackend(isMetalAvailable: false) == .cpu)
    #expect(metalConfiguration.resolvedExecutionMode(isMetalAvailable: false) == .cpuCanvas)
    #expect(metalConfiguration.resolvedBackend(isMetalAvailable: true) == .metal)
}

@Test func simulationProducesNoParticlesForZeroParticleCount() {
    let configuration = ConfettiConfiguration(particleCount: 0)
    
    #expect(ConfettiSimulation.makeBurst(configuration: configuration, seed: 1).isEmpty)
}

@Test func simulationProducesDeterministicBurst() {
    let configuration = ConfettiConfiguration(particleCount: 4, palette: .ocean, shapes: [.circle])
    
    let first = ConfettiSimulation.makeBurst(configuration: configuration, seed: 42)
    let second = ConfettiSimulation.makeBurst(configuration: configuration, seed: 42)
    
    #expect(first == second)
    #expect(first.count == 4)
    #expect(
        first.allSatisfy {
            configuration.initialVelocity.contains(hypot($0.velocity.dx, $0.velocity.dy))
        }
    )
    #expect(first.allSatisfy { configuration.circleSize.contains($0.size.width) })
    #expect(first.allSatisfy { $0.size.width == $0.size.height })
    #expect(first.allSatisfy { $0.shape == .circle })
    #expect(first.allSatisfy { (1.1...configuration.lifetime).contains($0.lifetime) })
    #expect(first.allSatisfy { (0.2...configuration.drag).contains($0.drag) })
    #expect(first.allSatisfy { configuration.angularVelocity.contains($0.angularVelocity) })
}

@Test func simulationUsesRectangleWidthAndHeightRanges() {
    let configuration = ConfettiConfiguration(
        particleCount: 6,
        rectangleSize: .init(width: 8...14, height: 12...22),
        shapes: [.rectangle, .roundedRectangle]
    )
    
    let particles = ConfettiSimulation.makeBurst(configuration: configuration, seed: 7)
    
    #expect(particles.count == 6)
    #expect(particles.allSatisfy { configuration.rectangleSize.width.contains($0.size.width) })
    #expect(particles.allSatisfy { configuration.rectangleSize.height.contains($0.size.height) })
    #expect(particles.allSatisfy { $0.shape != .circle })
}

@Test func simulationCanMixCircleAndRectangleShapes() {
    let configuration = ConfettiConfiguration(
        particleCount: 24,
        circleSize: 10...10,
        rectangleSize: .init(width: 12...12, height: 20...20),
        shapes: [.circle, .rectangle]
    )
    
    let particles = ConfettiSimulation.makeBurst(configuration: configuration, seed: 11)
    let shapes = Set(particles.map(\.shape))
    
    #expect(shapes.contains(.circle))
    #expect(shapes.contains(.rectangle))
    #expect(particles.filter { $0.shape == .circle }.allSatisfy { $0.size == CGSize(width: 10, height: 10) })
    #expect(particles.filter { $0.shape == .rectangle }.allSatisfy { $0.size == CGSize(width: 12, height: 20) })
}

@Test func simulationCanGenerateSparkleShapes() {
    let configuration = ConfettiConfiguration(
        particleCount: 8,
        circleSize: 12...12,
        sparkleSize: 18...18,
        shapes: [.sparkle]
    )
    
    let particles = ConfettiSimulation.makeBurst(configuration: configuration, seed: 15)
    
    #expect(particles.count == 8)
    #expect(particles.allSatisfy { $0.shape == .sparkle })
    #expect(particles.allSatisfy { $0.size == CGSize(width: 18, height: 18) })
}

@Test func simulationCanGenerateGlintShapes() {
    let configuration = ConfettiConfiguration(
        particleCount: 8,
        sparkleSize: 18...18,
        glintCircleOpacity: 0.35,
        shapes: [.glint]
    )
    
    let particles = ConfettiSimulation.makeBurst(configuration: configuration, seed: 16)
    
    #expect(configuration.glintCircleOpacity == 0.35)
    #expect(particles.count == 8)
    #expect(particles.allSatisfy { $0.shape == .glint })
    #expect(particles.allSatisfy { $0.size == CGSize(width: 18, height: 18) })
}

@Test func particleScaleResizesGeneratedParticles() {
    let circleConfiguration = ConfettiConfiguration(
        particleCount: 4,
        particleScale: 0.5,
        circleSize: 10...10,
        shapes: [.circle]
    )
    let rectangleConfiguration = ConfettiConfiguration(
        particleCount: 4,
        particleScale: 0.5,
        rectangleSize: .init(width: 12...12, height: 20...20),
        shapes: [.rectangle]
    )
    
    let circleParticles = ConfettiSimulation.makeBurst(configuration: circleConfiguration, seed: 1)
    let rectangleParticles = ConfettiSimulation.makeBurst(configuration: rectangleConfiguration, seed: 2)
    
    #expect(circleParticles.allSatisfy { $0.size == CGSize(width: 5, height: 5) })
    #expect(rectangleParticles.allSatisfy { $0.size == CGSize(width: 6, height: 10) })
}

@Test func configurationPreservesOrderedRanges() {
    let configuration = ConfettiConfiguration(
        initialVelocity: 300...520,
        angularVelocity: -8...8,
        circleSize: 8...14,
        sparkleSize: 10...22,
        rectangleSize: .init(width: 8...14, height: 12...22)
    )
    
    #expect(configuration.initialVelocity == 300...520)
    #expect(configuration.angularVelocity == -8...8)
    #expect(configuration.circleSize == 8...14)
    #expect(configuration.sparkleSize == 10...22)
    #expect(configuration.rectangleSize.width == 8...14)
    #expect(configuration.rectangleSize.height == 12...22)
}

@Test func configurationResolvesEmissionOrigin() {
    let configuration = ConfettiConfiguration(emissionOrigin: .topTrailing)
    
    let origin = configuration.resolvedOrigin(in: CGSize(width: 200, height: 120))
    
    #expect(origin == CGPoint(x: 200, y: 0))
}

@Test func burstPresetUsesRequestedOrigin() {
    let configuration = ConfettiConfiguration.burst(from: .topLeading)
    
    #expect(configuration.emissionOrigin == .topLeading)
    #expect(configuration.launchAngle == .degrees(-90))
}

@Test func cannonPresetUsesRequestedEdgeAndDefaultLaunchAngle() {
    let top = ConfettiConfiguration.cannon(from: .top)
    let bottom = ConfettiConfiguration.cannon(from: .bottom)
    let leading = ConfettiConfiguration.cannon(from: .leading)
    let trailing = ConfettiConfiguration.cannon(from: .trailing)
    
    #expect(top.emissionOrigin == .top)
    #expect(top.launchAngle == .degrees(-90))
    #expect(abs(top.spread.degrees - 24) < 0.0001)
    #expect(top.initialVelocity == 320...560)
    #expect(bottom.emissionOrigin == .bottom)
    #expect(bottom.launchAngle == .degrees(-90))
    #expect(leading.emissionOrigin == .leading)
    #expect(leading.launchAngle == .degrees(-90))
    #expect(trailing.emissionOrigin == .trailing)
    #expect(trailing.launchAngle == .degrees(-90))
}

@Test func cannonPresetUsesCustomLaunchAngleSpreadAndVelocity() {
    let configuration = ConfettiConfiguration.cannon(
        from: .bottom,
        launchAngle: .degrees(-90),
        spread: .degrees(14),
        initialVelocity: 420...720
    )
    
    #expect(configuration.emissionOrigin == .bottom)
    #expect(configuration.launchAngle == .degrees(-90))
    #expect(configuration.spread == .degrees(14))
    #expect(configuration.initialVelocity == 420...720)
}

@Test func namedPresetsUseDistinctShapeAndParticleProfiles() {
    let success = ConfettiConfiguration.success()
    let subtle = ConfettiConfiguration.subtle()
    let sparkle = ConfettiConfiguration.sparkle()
    let glint = ConfettiConfiguration.glint()
    
    #expect(success.particleCount > subtle.particleCount)
    #expect(success.launchAngle == .degrees(-90))
    #expect(subtle.launchAngle == .degrees(-90))
    #expect(sparkle.launchAngle == .degrees(-90))
    #expect(glint.launchAngle == .degrees(-90))
    #expect(subtle.particleScale < 1)
    #expect(sparkle.shapes.contains(.sparkle))
    #expect(sparkle.palette == .sunrise)
    #expect(glint.shapes == [.glint])
    #expect(glint.palette == .ocean)
}

@Test func subtlePresetUsesCustomParticleParameters() {
    let subtle = ConfettiConfiguration.subtle(
        particleCount: 48,
        lifetime: 1.2,
        launchAngle: .degrees(-75),
        spread: .degrees(42),
        initialVelocity: 140...260,
        particleScale: 0.6,
        palette: .monochrome
    )
    
    #expect(subtle.particleCount == 48)
    #expect(subtle.lifetime == 1.2)
    #expect(subtle.particleScale == 0.6)
    #expect(subtle.launchAngle == .degrees(-75))
    #expect(subtle.spread == .degrees(42))
    #expect(subtle.initialVelocity == 140...260)
    #expect(subtle.palette == .monochrome)
    #expect(subtle.shapes == [.circle, .roundedRectangle])
}

@Test func sparklePresetUsesCustomParticleParameters() {
    let sparkle = ConfettiConfiguration.sparkle(
        particleCount: 120,
        lifetime: 2.0,
        launchAngle: .degrees(-80),
        spread: .degrees(48),
        initialVelocity: 200...360,
        particleScale: 0.9,
        sparkleSharpness: 4.2,
        palette: .ocean
    )
    
    #expect(sparkle.particleCount == 120)
    #expect(sparkle.lifetime == 2.0)
    #expect(sparkle.particleScale == 0.9)
    #expect(sparkle.launchAngle == .degrees(-80))
    #expect(sparkle.sparkleSharpness == 4.2)
    #expect(abs(sparkle.spread.degrees - 48) < 0.0001)
    #expect(sparkle.initialVelocity == 200...360)
    #expect(sparkle.palette == .ocean)
    #expect(sparkle.shapes == [.sparkle, .circle])
}

@Test func glintPresetUsesCustomParticleParameters() {
    let glint = ConfettiConfiguration.glint(
        particleCount: 120,
        lifetime: 2.4,
        launchAngle: .degrees(-70),
        spread: .degrees(44),
        initialVelocity: 240...420,
        particleScale: 1.2,
        sparkleSharpness: 3.8,
        glintCircleOpacity: 0.35,
        glintCircleScale: 0.7,
        palette: .rainbow
    )
    
    #expect(glint.particleCount == 120)
    #expect(glint.lifetime == 2.4)
    #expect(glint.particleScale == 1.2)
    #expect(glint.launchAngle == .degrees(-70))
    #expect(glint.sparkleSharpness == 3.8)
    #expect(glint.spread == .degrees(44))
    #expect(glint.initialVelocity == 240...420)
    #expect(glint.palette == .rainbow)
    #expect(glint.glintCircleOpacity == 0.35)
    #expect(glint.glintCircleScale == 0.7)
    #expect(glint.shapes == [.glint])
}

@Test func reduceMotionCanDisableConfetti() {
    let configuration = ConfettiConfiguration(
        particleCount: 180,
        reduceMotionBehavior: .disable
    )
    
    let reduced = configuration.adjustedForReduceMotion(true)
    
    #expect(reduced.particleCount == 0)
    #expect(reduced.reduceMotionBehavior == .disable)
}

@Test func reduceMotionCanScaleDownConfetti() {
    let configuration = ConfettiConfiguration(
        particleCount: 180,
        lifetime: 3.6,
        spread: .degrees(72),
        initialVelocity: 320...580,
        angularVelocity: -10...10,
        backend: .automatic
    )
    
    let reduced = configuration.adjustedForReduceMotion(true)
    
    #expect(reduced.particleCount == 60)
    #expect(reduced.lifetime == 1.5)
    #expect(reduced.spread == .degrees(50))
    #expect(reduced.initialVelocity == 176...319)
    #expect(reduced.angularVelocity == -3.5...3.5)
    #expect(reduced.backend == .automatic)
    #expect(reduced.reduceMotionBehavior == .automatic)
}

@Test func reduceMotionKeepsSmallNonzeroBurstsVisible() {
    let configuration = ConfettiConfiguration(particleCount: 4)
    
    let reduced = configuration.adjustedForReduceMotion(true)
    
    #expect(reduced.particleCount == 18)
}

@Test func reduceMotionCanBeIgnored() {
    let configuration = ConfettiConfiguration(reduceMotionBehavior: .ignore)
    
    #expect(configuration.adjustedForReduceMotion(true) == configuration)
}

@Test func emissionExpirationUsesLongestParticleLifetime() {
    let configuration = ConfettiConfiguration(lifetime: 2)
    let birthDate = Date(timeIntervalSinceReferenceDate: 100)
    let particles = [
        ConfettiParticle(
            position: .zero,
            velocity: .zero,
            size: CGSize(width: 8, height: 12),
            rotation: .zero,
            angularVelocity: 0,
            colorIndex: 0,
            shape: .rectangle,
            lifetime: 1.2,
            drag: 0.9
        ),
        ConfettiParticle(
            position: .zero,
            velocity: .zero,
            size: CGSize(width: 8, height: 12),
            rotation: .zero,
            angularVelocity: 0,
            colorIndex: 0,
            shape: .rectangle,
            lifetime: 2.4,
            drag: 1.1
        ),
    ]
    let emission = ConfettiEmission(id: 1, birthDate: birthDate, particles: particles)
    
    #expect(
        emission.expirationDate(configuration: configuration)
            == birthDate.addingTimeInterval(2.4)
    )
}

@Test func simulationSampleArcsUpwardThenFallsAndFadesOut() {
    let configuration = ConfettiConfiguration(
        particleCount: 1,
        lifetime: 2,
        launchAngle: .degrees(-90),
        spread: .degrees(0),
        initialVelocity: 120...120,
        gravity: 240,
        drag: 0
    )
    let particle = ConfettiParticle(
        position: .zero,
        velocity: CGVector(dx: 100, dy: -120),
        size: CGSize(width: 10, height: 20),
        rotation: .zero,
        angularVelocity: 3,
        colorIndex: 0,
        shape: .rectangle,
        lifetime: 2,
        drag: 0
    )
    
    #expect(
        ConfettiSimulation.sample(
            particle: particle,
            elapsed: -0.1,
            origin: .zero,
            configuration: configuration
        ) == nil
    )
    #expect(
        ConfettiSimulation.sample(
            particle: particle,
            elapsed: 0,
            origin: CGPoint(x: 10, y: 20),
            configuration: configuration
        )?.position == CGPoint(x: 10, y: 20)
    )
    #expect(
        ConfettiSimulation.sample(
            particle: particle,
            elapsed: 2,
            origin: .zero,
            configuration: configuration
        ) != nil
    )
    
    let risingSample = ConfettiSimulation.sample(
        particle: particle,
        elapsed: 0.5,
        origin: .zero,
        configuration: configuration
    )
    let fallingSample = ConfettiSimulation.sample(
        particle: particle,
        elapsed: 1.5,
        origin: .zero,
        configuration: configuration
    )
    let fadingSample = ConfettiSimulation.sample(
        particle: particle,
        elapsed: 1.9,
        origin: .zero,
        configuration: configuration
    )
    
    #expect(risingSample != nil)
    #expect(risingSample?.position == CGPoint(x: 50, y: -30))
    #expect(risingSample?.opacity == 1.0)
    #expect(fallingSample != nil)
    #expect(fallingSample?.position == CGPoint(x: 150, y: 90))
    #expect((fallingSample?.opacity ?? 0) > 0.9)
    #expect(fadingSample != nil)
    #expect((fadingSample?.opacity ?? 0) < 0.2)
    #expect(fallingSample?.rotation == .radians(4.5))
    #expect(
        ConfettiSimulation.sample(
            particle: particle,
            elapsed: 2.1,
            origin: .zero,
            configuration: configuration
        ) == nil
    )
}
@MainActor
@Test func metalRendererCanBuildPipelineAndAcceptEmission() throws {
    guard ConfettiMetalRenderer.isSupported else {
        return
    }
    
    let view = MTKView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
    view.colorPixelFormat = .bgra8Unorm
    view.framebufferOnly = false
    
    let renderer = try #require(ConfettiMetalRenderer(mtkView: view))
    let configuration = ConfettiConfiguration(
        particleCount: 8,
        shapes: [.rectangle],
        backend: .metal
    )
    let emission = ConfettiEmission(
        id: 1,
        birthDate: Date(),
        particles: ConfettiSimulation.makeBurst(configuration: configuration, seed: 1)
    )
    
    let isActive = renderer.update(
        emissions: [emission],
        configuration: configuration,
        executionMode: .metalCPUSimulation,
        canvasSize: CGSize(width: 200, height: 200)
    )
    
    #expect(isActive)
}
