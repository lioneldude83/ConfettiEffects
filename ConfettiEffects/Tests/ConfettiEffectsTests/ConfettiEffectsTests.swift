//
//  ConfettiEffectsTests.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import CoreGraphics
import Foundation
import Testing
@testable import ConfettiEffects

@Test func configurationNormalizesValues() {
    let configuration = ConfettiConfiguration(
        particleCount: -12,
        lifetime: 0,
        spread: .degrees(-30),
        initialVelocity: 300...520,
        drag: -2,
        particleScale: -1,
        shapes: []
    )
    
    #expect(configuration.particleCount == 0)
    #expect(configuration.lifetime == 0.1)
    #expect(configuration.spread == .degrees(0))
    #expect(configuration.initialVelocity == 300...520)
    #expect(configuration.drag == 0)
    #expect(configuration.particleScale == 0)
    #expect(configuration.shapes == ConfettiConfiguration.Shape.allCases)
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
    #expect(first.allSatisfy { (-8...8).contains($0.angularVelocity) })
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

@Test func configurationResolvesEmissionOrigin() {
    let configuration = ConfettiConfiguration(emissionOrigin: .topTrailing)
    
    let origin = configuration.resolvedOrigin(in: CGSize(width: 200, height: 120))
    
    #expect(origin == CGPoint(x: 200, y: 0))
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
        backend: .automatic
    )
    
    let reduced = configuration.adjustedForReduceMotion(true)
    
    #expect(reduced.particleCount == 60)
    #expect(reduced.lifetime == 1.5)
    #expect(reduced.spread == .degrees(35))
    #expect(reduced.initialVelocity == 144...261)
    #expect(reduced.backend == .cpu)
    #expect(reduced.reduceMotionBehavior == .automatic)
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
