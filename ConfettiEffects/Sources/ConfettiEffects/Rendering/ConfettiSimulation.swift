//
//  ConfettiSimulation.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import SwiftUI

enum ConfettiSimulation {
    static func makeBurst(
        configuration: ConfettiConfiguration,
        seed: UInt64
    ) -> [ConfettiParticle] {
        guard configuration.particleCount > 0 else {
            return []
        }
        
        var generator = SplitMix64(state: seed)
        let baseAngle = configuration.launchAngle.radians
        let halfSpread = configuration.spread.radians / 2
        let paletteCount = max(configuration.palette.colors.count, 1)
        let lifetimeRange = sampleRange(lowerBound: 1.1, upperBound: configuration.lifetime)
        let dragRange = sampleRange(lowerBound: 0.2, upperBound: configuration.drag)
        let shapes = configuration.shapes
        
        return (0..<configuration.particleCount).map { _ in
            let angle = generator.next(in: (baseAngle - halfSpread)...(baseAngle + halfSpread))
            let speed = generator.next(in: configuration.initialVelocity)
            let rotation = Angle.radians(generator.next(in: 0...(2 * .pi)))
            let angularVelocity = generator.next(in: -8...8)
            let colorIndex = Int(generator.next() % UInt64(paletteCount))
            let shapeIndex = Int(generator.next() % UInt64(shapes.count))
            let shape = shapes[shapeIndex]
            let size = sampleSize(for: shape, configuration: configuration, generator: &generator)
            let lifetime = generator.next(in: lifetimeRange)
            let drag = generator.next(in: dragRange)
            let velocity = CGVector(
                dx: cos(angle) * speed,
                dy: sin(angle) * speed
            )
            
            return ConfettiParticle(
                position: .zero,
                velocity: velocity,
                size: size,
                rotation: rotation,
                angularVelocity: angularVelocity,
                colorIndex: colorIndex,
                shape: shape,
                lifetime: lifetime,
                drag: drag
            )
        }
    }
    
    static func sample(
        particle: ConfettiParticle,
        elapsed: Double,
        origin: CGPoint,
        configuration: ConfettiConfiguration
    ) -> ConfettiParticleSample? {
        guard elapsed >= 0, elapsed <= particle.lifetime else {
            return nil
        }
        
        let offset = displacement(
            initialVelocity: particle.velocity,
            elapsed: elapsed,
            gravity: configuration.gravity,
            drag: particle.drag
        )
        let progress = elapsed / particle.lifetime
        let opacity = fadeOpacity(for: progress)
        let rotation = particle.rotation + .radians(particle.angularVelocity * elapsed)
        let color = configuration.palette.colors[particle.colorIndex % configuration.palette.colors.count]
        
        return ConfettiParticleSample(
            position: CGPoint(
                x: origin.x + particle.position.x + offset.dx,
                y: origin.y + particle.position.y + offset.dy
            ),
            rotation: rotation,
            size: particle.size,
            opacity: opacity,
            color: color
        )
    }
    
    static func displacement(
        initialVelocity: CGVector,
        elapsed: Double,
        gravity: Double,
        drag: Double
    ) -> CGVector {
        let gravityVector = CGVector(dx: 0, dy: gravity)
        
        guard drag > 0.0001 else {
            return CGVector(
                dx: initialVelocity.dx * elapsed,
                dy: initialVelocity.dy * elapsed + (0.5 * gravity * elapsed * elapsed)
            )
        }
        
        let damping = exp(-drag * elapsed)
        let inverseDrag = 1 / drag
        let terminalVelocity = CGVector(
            dx: gravityVector.dx * inverseDrag,
            dy: gravityVector.dy * inverseDrag
        )
        
        return CGVector(
            dx: (terminalVelocity.dx * elapsed) + ((initialVelocity.dx - terminalVelocity.dx) * (1 - damping) * inverseDrag),
            dy: (terminalVelocity.dy * elapsed) + ((initialVelocity.dy - terminalVelocity.dy) * (1 - damping) * inverseDrag)
        )
    }
    
    private static func sampleSize(
        for shape: ConfettiConfiguration.Shape,
        configuration: ConfettiConfiguration,
        generator: inout SplitMix64
    ) -> CGSize {
        switch shape {
        case .circle:
            let diameter = generator.next(in: configuration.circleSize) * configuration.particleScale
            return CGSize(width: diameter, height: diameter)
        case .rectangle, .roundedRectangle:
            return CGSize(
                width: generator.next(in: configuration.rectangleSize.width) * configuration.particleScale,
                height: generator.next(in: configuration.rectangleSize.height) * configuration.particleScale
            )
        }
    }
    
    private static func sampleRange(
        lowerBound: Double,
        upperBound: Double
    ) -> ClosedRange<Double> {
        let clampedUpperBound = max(lowerBound, upperBound)
        return lowerBound...clampedUpperBound
    }
    
    private static func fadeOpacity(for progress: Double) -> Double {
        let fadeStart = 0.72
        
        guard progress > fadeStart else {
            return 1
        }
        
        let normalizedFade = min(max((progress - fadeStart) / (1 - fadeStart), 0), 1)
        let easedFade = normalizedFade * normalizedFade * (3 - (2 * normalizedFade))
        return max(0, 1 - easedFade)
    }
}

private struct SplitMix64 {
    var state: UInt64
    
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }
    
    mutating func next(in range: ClosedRange<Double>) -> Double {
        let unit = Double(next()) / Double(UInt64.max)
        return range.lowerBound + (range.upperBound - range.lowerBound) * unit
    }
}
