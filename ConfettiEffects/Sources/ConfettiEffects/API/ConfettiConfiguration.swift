//
//  ConfettiConfiguration.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import SwiftUI

/// Configures how a confetti burst is generated, rendered, and adapted for accessibility.
public struct ConfettiConfiguration: Sendable, Equatable {
    /// Width and height ranges used for rectangle-based confetti pieces.
    public struct ConfettiSize: Sendable, Equatable {
        /// Width range for rectangular and rounded rectangle particles.
        public var width: ClosedRange<Double>
        /// Height range for rectangular and rounded rectangle particles.
        public var height: ClosedRange<Double>
        
        /// Creates size ranges for rectangular confetti pieces.
        /// - Parameters:
        ///   - width: Width range for generated particles.
        ///   - height: Height range for generated particles.
        public init(
            width: ClosedRange<Double> = 8...14,
            height: ClosedRange<Double> = 12...22
        ) {
            self.width = min(width.lowerBound, width.upperBound)...max(width.lowerBound, width.upperBound)
            self.height = min(height.lowerBound, height.upperBound)...max(height.lowerBound, height.upperBound)
        }
    }
    
    /// Selects which renderer the effect should use.
    public enum Backend: String, Sendable, Equatable, CaseIterable {
        case automatic
        case cpu
        case metal
    }
    
    /// Built-in color palettes available to the confetti effect.
    public enum Palette: String, Sendable, Equatable, CaseIterable {
        case rainbow
        case sunrise
        case ocean
        case monochrome
        
        var colors: [Color] {
            switch self {
            case .rainbow:
                return Self.rainbowColors
            case .sunrise:
                return Self.sunriseColors
            case .ocean:
                return Self.oceanColors
            case .monochrome:
                return Self.monochromeColors
            }
        }
        
        var metalColors: [SIMD4<Float>] {
            switch self {
            case .rainbow:
                return Self.rainbowMetalColors
            case .sunrise:
                return Self.sunriseMetalColors
            case .ocean:
                return Self.oceanMetalColors
            case .monochrome:
                return Self.monochromeMetalColors
            }
        }
        
        private static let rainbowColors: [Color] = [
            Color(red: 1.00, green: 0.36, blue: 0.38),
            Color(red: 1.00, green: 0.74, blue: 0.22),
            Color(red: 0.30, green: 0.84, blue: 0.48),
            Color(red: 0.30, green: 0.68, blue: 1.00),
            Color(red: 0.76, green: 0.46, blue: 1.00),
            Color(red: 1.00, green: 0.90, blue: 0.28),
        ]
        private static let sunriseColors: [Color] = [
            Color(red: 1.00, green: 0.64, blue: 0.36),
            Color(red: 1.00, green: 0.84, blue: 0.42),
            Color(red: 1.00, green: 0.58, blue: 0.76),
            Color(red: 1.00, green: 0.44, blue: 0.46),
        ]
        private static let oceanColors: [Color] = [
            Color(red: 0.38, green: 0.86, blue: 0.94),
            Color(red: 0.42, green: 0.72, blue: 1.00),
            Color(red: 0.56, green: 0.60, blue: 0.96),
            Color(red: 0.52, green: 0.90, blue: 0.78),
        ]
        private static let monochromeColors: [Color] = [
            Color(white: 0.96),
            Color(white: 0.72),
            Color(white: 0.38),
        ]
        
        private static let rainbowMetalColors: [SIMD4<Float>] = [
            SIMD4(0.96, 0.30, 0.34, 1.0),
            SIMD4(1.00, 0.66, 0.14, 1.0),
            SIMD4(0.24, 0.76, 0.42, 1.0),
            SIMD4(0.24, 0.60, 0.96, 1.0),
            SIMD4(0.68, 0.38, 0.96, 1.0),
            SIMD4(0.96, 0.84, 0.18, 1.0),
        ]
        private static let sunriseMetalColors: [SIMD4<Float>] = [
            SIMD4(0.98, 0.56, 0.28, 1.0),
            SIMD4(0.98, 0.78, 0.34, 1.0),
            SIMD4(0.96, 0.50, 0.68, 1.0),
            SIMD4(0.96, 0.36, 0.38, 1.0),
        ]
        private static let oceanMetalColors: [SIMD4<Float>] = [
            SIMD4(0.24, 0.78, 0.90, 1.0),
            SIMD4(0.30, 0.62, 0.96, 1.0),
            SIMD4(0.46, 0.50, 0.88, 1.0),
            SIMD4(0.38, 0.82, 0.70, 1.0),
        ]
        private static let monochromeMetalColors: [SIMD4<Float>] = [
            SIMD4(0.90, 0.90, 0.90, 1.0),
            SIMD4(0.62, 0.62, 0.62, 1.0),
            SIMD4(0.26, 0.26, 0.26, 1.0),
        ]
    }
    
    /// The particle shapes available when generating a burst.
    public enum Shape: String, Sendable, Equatable, CaseIterable {
        case circle
        case rectangle
        case roundedRectangle
    }
    
    /// Controls how the effect responds when the system Reduce Motion setting is enabled.
    public enum ReduceMotionBehavior: String, Sendable, Equatable, CaseIterable {
        case ignore
        case automatic
        case disable
    }
    
    /// Number of particles generated per burst.
    public var particleCount: Int
    /// Maximum visible lifetime for generated particles.
    public var lifetime: TimeInterval
    /// Base launch direction for the burst.
    public var launchAngle: Angle
    /// Angular spread around the launch angle.
    public var spread: Angle
    /// Initial launch velocity range for generated particles.
    public var initialVelocity: ClosedRange<Double>
    /// Downward acceleration applied every frame.
    public var gravity: Double
    /// Per-particle velocity damping applied every frame.
    public var drag: Double
    /// Multiplies all generated particle sizes.
    public var particleScale: Double
    /// Diameter range for circular particles.
    public var circleSize: ClosedRange<Double>
    /// Width and height ranges for rectangle-based particles.
    public var rectangleSize: ConfettiSize
    /// Relative origin point used to place the burst inside the modified view.
    public var emissionOrigin: UnitPoint
    /// Behavior used when the system Reduce Motion setting is enabled.
    public var reduceMotionBehavior: ReduceMotionBehavior
    /// Built-in color palette used for generated particles.
    public var palette: Palette
    /// Shapes available when generating particles.
    public var shapes: [Shape]
    /// Renderer selection strategy for the effect.
    public var backend: Backend
    
    /// Creates a confetti configuration with tunable burst, motion, size, palette, and backend settings.
    /// - Parameters:
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - drag: Per-particle velocity damping applied every frame.
    ///   - particleScale: Multiplies all generated particle sizes.
    ///   - circleSize: Diameter range for circular particles.
    ///   - rectangleSize: Width and height ranges for rectangle-based particles.
    ///   - emissionOrigin: Relative origin point used to place the burst inside the modified view.
    ///   - reduceMotionBehavior: Behavior used when the system Reduce Motion setting is enabled.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    ///   - backend: Renderer selection strategy for the effect.
    public init(
        particleCount: Int = 180,
        lifetime: TimeInterval = 2.4,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(86),
        initialVelocity: ClosedRange<Double> = 240...480,
        gravity: Double = 680,
        drag: Double = 0.9,
        particleScale: Double = 1,
        circleSize: ClosedRange<Double> = 8...14,
        rectangleSize: ConfettiSize = ConfettiSize(),
        emissionOrigin: UnitPoint = .center,
        reduceMotionBehavior: ReduceMotionBehavior = .automatic,
        palette: Palette = .rainbow,
        shapes: [Shape] = [.rectangle, .roundedRectangle],
        backend: Backend = .automatic
    ) {
        self.particleCount = max(0, particleCount)
        self.lifetime = max(0.1, lifetime)
        self.launchAngle = launchAngle
        self.spread = .degrees(max(0, spread.degrees))
        self.initialVelocity = min(initialVelocity.lowerBound, initialVelocity.upperBound)...max(initialVelocity.lowerBound, initialVelocity.upperBound)
        self.gravity = gravity
        self.drag = max(0, drag)
        self.particleScale = max(0, particleScale)
        self.circleSize = min(circleSize.lowerBound, circleSize.upperBound)...max(circleSize.lowerBound, circleSize.upperBound)
        self.rectangleSize = rectangleSize
        self.emissionOrigin = emissionOrigin
        self.reduceMotionBehavior = reduceMotionBehavior
        self.palette = palette
        self.shapes = shapes.isEmpty ? Shape.allCases : shapes
        self.backend = backend
    }
}

enum ConfettiResolvedBackend: Equatable {
    case cpu
    case metal
}

enum ConfettiResolvedExecutionMode: Equatable {
    case cpuCanvas
    case metalCPUSimulation
    case metalGPUSimulation
}

extension ConfettiConfiguration {
    static let automaticMetalParticleThreshold = 120
    static let automaticMetalHighDensityThreshold = 80
    static let automaticMetalCanvasAreaThreshold: CGFloat = 160_000
    
    func resolvedBackend(
        isMetalAvailable: Bool,
        canvasSize: CGSize = .zero,
        displayScale: CGFloat = 1,
        liveParticleCount: Int? = nil
    ) -> ConfettiResolvedBackend {
        switch resolvedExecutionMode(
            isMetalAvailable: isMetalAvailable,
            canvasSize: canvasSize,
            displayScale: displayScale,
            liveParticleCount: liveParticleCount
        ) {
        case .cpuCanvas:
            return .cpu
        case .metalCPUSimulation, .metalGPUSimulation:
            return .metal
        }
    }
    
    func resolvedExecutionMode(
        isMetalAvailable: Bool,
        canvasSize: CGSize = .zero,
        displayScale: CGFloat = 1,
        liveParticleCount: Int? = nil
    ) -> ConfettiResolvedExecutionMode {
        let liveParticleCount = liveParticleCount ?? particleCount
        let scaledArea = canvasSize.width * canvasSize.height * displayScale * displayScale
        
        switch backend {
        case .cpu:
            return .cpuCanvas
        case .metal:
            guard isMetalAvailable else {
                return .cpuCanvas
            }
            
            return liveParticleCount >= Self.automaticMetalParticleThreshold
            ? .metalGPUSimulation
            : .metalCPUSimulation
        case .automatic:
            guard isMetalAvailable else {
                return .cpuCanvas
            }
            
            if liveParticleCount >= Self.automaticMetalParticleThreshold {
                return .metalGPUSimulation
            }
            
            if liveParticleCount >= Self.automaticMetalHighDensityThreshold,
               scaledArea >= Self.automaticMetalCanvasAreaThreshold {
                return .metalGPUSimulation
            }
            
            return .metalCPUSimulation
        }
    }
    
    func resolvedOrigin(in size: CGSize) -> CGPoint {
        CGPoint(
            x: size.width * emissionOrigin.x,
            y: size.height * emissionOrigin.y
        )
    }
    
    func adjustedForReduceMotion(_ isEnabled: Bool) -> ConfettiConfiguration {
        guard isEnabled else {
            return self
        }
        
        switch reduceMotionBehavior {
        case .ignore:
            return self
        case .disable:
            var configuration = self
            configuration.particleCount = 0
            return configuration
        case .automatic:
            var configuration = self
            configuration.particleCount = particleCount == 0 ? 0 : max(12, particleCount / 3)
            configuration.lifetime = min(lifetime, 1.5)
            configuration.initialVelocity = scaledRange(initialVelocity, factor: 0.45)
            configuration.spread = .degrees(min(spread.degrees, 35))
            configuration.backend = .cpu
            return configuration
        }
    }
    
    private func scaledRange(_ range: ClosedRange<Double>, factor: Double) -> ClosedRange<Double> {
        (range.lowerBound * factor)...(range.upperBound * factor)
    }
}
