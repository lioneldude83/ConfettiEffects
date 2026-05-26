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
        case sparkle
        case glint
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
    /// Angular velocity range used for particle rotation.
    public var angularVelocity: ClosedRange<Double>
    /// Multiplies all generated particle sizes.
    public var particleScale: Double
    /// Diameter range for circular particles.
    public var circleSize: ClosedRange<Double>
    /// Diameter range for sparkle particles.
    public var sparkleSize: ClosedRange<Double>
    /// Controls how thin or sharp sparkle and glint star arms appear.
    public var sparkleSharpness: Double
    /// Width and height ranges for rectangle-based particles.
    public var rectangleSize: ConfettiSize
    /// Opacity of the circular backing layer used for glint particles.
    public var glintCircleOpacity: Double
    /// Scale of the circular backing layer relative to the sparkle layer for glint particles.
    public var glintCircleScale: Double
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
    ///   - angularVelocity: Angular velocity range used for particle rotation.
    ///   - particleScale: Multiplies all generated particle sizes.
    ///   - circleSize: Diameter range for circular particles.
    ///   - sparkleSize: Diameter range for sparkle particles.
    ///   - sparkleSharpness: Controls how thin or sharp sparkle and glint star arms appear.
    ///   - rectangleSize: Width and height ranges for rectangle-based particles.
    ///   - glintCircleOpacity: Opacity of the circular backing layer used for glint particles.
    ///   - glintCircleScale: Scale of the circular backing layer relative to the sparkle layer for glint particles.
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
        angularVelocity: ClosedRange<Double> = -8...8,
        particleScale: Double = 1,
        circleSize: ClosedRange<Double> = 8...14,
        sparkleSize: ClosedRange<Double> = 10...22,
        sparkleSharpness: Double = 2.6,
        rectangleSize: ConfettiSize = ConfettiSize(),
        glintCircleOpacity: Double = 0.2,
        glintCircleScale: Double = 0.6,
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
        self.angularVelocity = min(angularVelocity.lowerBound, angularVelocity.upperBound)...max(angularVelocity.lowerBound, angularVelocity.upperBound)
        self.particleScale = max(0, particleScale)
        self.circleSize = min(circleSize.lowerBound, circleSize.upperBound)...max(circleSize.lowerBound, circleSize.upperBound)
        self.sparkleSize = min(sparkleSize.lowerBound, sparkleSize.upperBound)...max(sparkleSize.lowerBound, sparkleSize.upperBound)
        self.sparkleSharpness = min(max(sparkleSharpness, 1.5), 5)
        self.rectangleSize = rectangleSize
        self.glintCircleOpacity = min(max(glintCircleOpacity, 0), 1)
        self.glintCircleScale = min(max(glintCircleScale, 0.5), 1)
        self.emissionOrigin = emissionOrigin
        self.reduceMotionBehavior = reduceMotionBehavior
        self.palette = palette
        self.shapes = shapes.isEmpty ? Shape.allCases : shapes
        self.backend = backend
    }
}

public extension ConfettiConfiguration {
    /// Creates the default one-shot burst configuration from a specific point in the modified view.
    /// - Parameters:
    ///   - origin: Relative point where the burst starts inside the modified view.
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    /// - Returns: A configuration tuned for a balanced upward confetti burst.
    static func burst(
        from origin: UnitPoint = .center,
        particleCount: Int = 180,
        lifetime: TimeInterval = 2.4,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(86),
        initialVelocity: ClosedRange<Double> = 240...480,
        gravity: Double = 680,
        palette: Palette = .rainbow,
        shapes: [Shape] = [.rectangle, .roundedRectangle]
    ) -> ConfettiConfiguration {
        ConfettiConfiguration(
            particleCount: particleCount,
            lifetime: lifetime,
            launchAngle: launchAngle,
            spread: spread,
            initialVelocity: initialVelocity,
            gravity: gravity,
            emissionOrigin: origin,
            palette: palette,
            shapes: shapes
        )
    }
    
    /// Creates a directional cannon configuration that emits confetti from one edge.
    /// - Parameters:
    ///   - edge: Edge where the cannon starts.
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the cannon.
    ///   - spread: Angular spread around the cannon's launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    /// - Returns: A configuration with its origin matched to `edge`.
    static func cannon(
        from edge: Edge,
        particleCount: Int = 180,
        lifetime: TimeInterval = 2.4,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(24),
        initialVelocity: ClosedRange<Double> = 320...560,
        gravity: Double = 680,
        palette: Palette = .rainbow,
        shapes: [Shape] = [.rectangle, .roundedRectangle]
    ) -> ConfettiConfiguration {
        switch edge {
        case .top:
            ConfettiConfiguration(
                particleCount: particleCount,
                lifetime: lifetime,
                launchAngle: launchAngle,
                spread: spread,
                initialVelocity: initialVelocity,
                gravity: gravity,
                emissionOrigin: .top,
                palette: palette,
                shapes: shapes
            )
        case .bottom:
            ConfettiConfiguration(
                particleCount: particleCount,
                lifetime: lifetime,
                launchAngle: launchAngle,
                spread: spread,
                initialVelocity: initialVelocity,
                gravity: gravity,
                emissionOrigin: .bottom,
                palette: palette,
                shapes: shapes
            )
        case .leading:
            ConfettiConfiguration(
                particleCount: particleCount,
                lifetime: lifetime,
                launchAngle: launchAngle,
                spread: spread,
                initialVelocity: initialVelocity,
                gravity: gravity,
                emissionOrigin: .leading,
                palette: palette,
                shapes: shapes
            )
        case .trailing:
            ConfettiConfiguration(
                particleCount: particleCount,
                lifetime: lifetime,
                launchAngle: launchAngle,
                spread: spread,
                initialVelocity: initialVelocity,
                gravity: gravity,
                emissionOrigin: .trailing,
                palette: palette,
                shapes: shapes
            )
        }
    }
    
    /// Creates a celebratory preset for successful actions, milestones, and completed tasks.
    /// - Parameters:
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    /// - Returns: A configuration tuned for a higher-energy celebration.
    static func success(
        particleCount: Int = 150,
        lifetime: TimeInterval = 2.3,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(92),
        initialVelocity: ClosedRange<Double> = 280...520,
        gravity: Double = 680,
        palette: Palette = .rainbow,
        shapes: [Shape] = [.roundedRectangle, .rectangle, .sparkle]
    ) -> ConfettiConfiguration {
        ConfettiConfiguration(
            particleCount: particleCount,
            lifetime: lifetime,
            launchAngle: launchAngle,
            spread: spread,
            initialVelocity: initialVelocity,
            gravity: gravity,
            palette: palette,
            shapes: shapes
        )
    }
    
    /// Creates a restrained preset for small interface confirmations and frequently repeated actions.
    /// - Parameters:
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - particleScale: Multiplies all generated particle sizes.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    /// - Returns: A subtle configuration using circle and rounded rectangle particles.
    static func subtle(
        particleCount: Int = 64,
        lifetime: TimeInterval = 1.6,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(58),
        initialVelocity: ClosedRange<Double> = 180...320,
        gravity: Double = 540,
        particleScale: Double = 0.72,
        palette: Palette = .ocean,
        shapes: [Shape] = [.circle, .roundedRectangle]
    ) -> ConfettiConfiguration {
        ConfettiConfiguration(
            particleCount: particleCount,
            lifetime: lifetime,
            launchAngle: launchAngle,
            spread: spread,
            initialVelocity: initialVelocity,
            gravity: gravity,
            particleScale: particleScale,
            palette: palette,
            shapes: shapes
        )
    }
    
    /// Creates a bright preset that favors sparkle particles for lightweight celebratory accents.
    /// - Parameters:
    ///   - particleCount: Number of sparkle particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - particleScale: Multiplies all generated particle sizes.
    ///   - sparkleSharpness: Controls how thin or sharp sparkle star arms appear.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    /// - Returns: A sparkle-focused configuration using sparkle and circle particles.
    static func sparkle(
        particleCount: Int = 96,
        lifetime: TimeInterval = 2.1,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(66),
        initialVelocity: ClosedRange<Double> = 220...390,
        gravity: Double = 480,
        particleScale: Double = 0.88,
        sparkleSharpness: Double = 2.6,
        palette: Palette = .sunrise,
        shapes: [Shape] = [.sparkle, .circle]
    ) -> ConfettiConfiguration {
        ConfettiConfiguration(
            particleCount: particleCount,
            lifetime: lifetime,
            launchAngle: launchAngle,
            spread: spread,
            initialVelocity: initialVelocity,
            gravity: gravity,
            particleScale: particleScale,
            sparkleSharpness: sparkleSharpness,
            palette: palette,
            shapes: shapes
        )
    }
    
    /// Creates an ocean-colored preset that favors glint particles.
    /// - Parameters:
    ///   - particleCount: Number of glint particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - particleScale: Multiplies all generated particle sizes.
    ///   - sparkleSharpness: Controls how thin or sharp glint star arms appear.
    ///   - glintCircleOpacity: Opacity of the circular backing layer used for glint particles.
    ///   - glintCircleScale: Scale of the circular backing layer relative to the sparkle layer.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    /// - Returns: A glint-focused configuration using glint particles.
    static func glint(
        particleCount: Int = 96,
        lifetime: TimeInterval = 2.1,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(66),
        initialVelocity: ClosedRange<Double> = 220...390,
        gravity: Double = 480,
        particleScale: Double = 0.88,
        sparkleSharpness: Double = 2.6,
        glintCircleOpacity: Double = 0.2,
        glintCircleScale: Double = 0.6,
        palette: Palette = .ocean,
        shapes: [Shape] = [.glint]
    ) -> ConfettiConfiguration {
        ConfettiConfiguration(
            particleCount: particleCount,
            lifetime: lifetime,
            launchAngle: launchAngle,
            spread: spread,
            initialVelocity: initialVelocity,
            gravity: gravity,
            particleScale: particleScale,
            sparkleSharpness: sparkleSharpness,
            glintCircleOpacity: glintCircleOpacity,
            glintCircleScale: glintCircleScale,
            palette: palette,
            shapes: shapes
        )
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
            configuration.particleCount = particleCount == 0 ? 0 : min(60, max(18, Int(Double(particleCount) * 0.6)))
            configuration.lifetime = min(lifetime, 1.5)
            configuration.initialVelocity = scaledRange(initialVelocity, factor: 0.55)
            configuration.angularVelocity = scaledRange(angularVelocity, factor: 0.35)
            configuration.spread = .degrees(min(spread.degrees, 50))
            return configuration
        }
    }
    
    private func scaledRange(_ range: ClosedRange<Double>, factor: Double) -> ClosedRange<Double> {
        (range.lowerBound * factor)...(range.upperBound * factor)
    }
}
