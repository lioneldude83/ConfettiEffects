//
//  View+ConfettiEffect.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import SwiftUI

public extension View {
    /// Adds a one-shot confetti burst whenever `trigger` changes.
    /// Attach it to the container you want the effect to fill, not just the button that triggers it.
    /// - Parameters:
    ///   - trigger: Any changing `Equatable` value that should emit a new burst.
    ///   - configuration: Burst, palette, size, accessibility, and backend settings.
    func confettiEffect(
        trigger: some Equatable,
        configuration: ConfettiConfiguration = ConfettiConfiguration()
    ) -> some View {
        modifier(ConfettiEffectModifier(trigger: trigger, configuration: configuration))
    }
    
    /// Adds a one-shot confetti burst from a specific point whenever `trigger` changes.
    /// Attach it to the container you want the effect to fill, not just the control that triggers it.
    /// - Parameters:
    ///   - trigger: Any changing `Equatable` value that should emit a new burst.
    ///   - origin: Relative point where the burst starts inside the modified view.
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    func confettiBurst(
        trigger: some Equatable,
        from origin: UnitPoint = .center,
        particleCount: Int = 180,
        lifetime: TimeInterval = 2.4,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(86),
        initialVelocity: ClosedRange<Double> = 240...480,
        gravity: Double = 680,
        palette: ConfettiConfiguration.Palette = .rainbow,
        shapes: [ConfettiConfiguration.Shape] = [.rectangle, .roundedRectangle]
    ) -> some View {
        confettiEffect(
            trigger: trigger,
            configuration: .burst(
                from: origin,
                particleCount: particleCount,
                lifetime: lifetime,
                launchAngle: launchAngle,
                spread: spread,
                initialVelocity: initialVelocity,
                gravity: gravity,
                palette: palette,
                shapes: shapes
            )
        )
    }
    
    /// Adds a directional confetti cannon whenever `trigger` changes.
    /// The cannon emits from the selected edge using a configurable launch angle and narrow cone.
    /// - Parameters:
    ///   - trigger: Any changing `Equatable` value that should emit a new cannon burst.
    ///   - edge: Edge where the cannon starts.
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the cannon's launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    func confettiCannon(
        trigger: some Equatable,
        edge: Edge,
        particleCount: Int = 180,
        lifetime: TimeInterval = 2.4,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(24),
        initialVelocity: ClosedRange<Double> = 320...560,
        gravity: Double = 680,
        palette: ConfettiConfiguration.Palette = .rainbow,
        shapes: [ConfettiConfiguration.Shape] = [.rectangle, .roundedRectangle]
    ) -> some View {
        confettiEffect(
            trigger: trigger,
            configuration: .cannon(
                from: edge,
                particleCount: particleCount,
                lifetime: lifetime,
                launchAngle: launchAngle,
                spread: spread,
                initialVelocity: initialVelocity,
                gravity: gravity,
                palette: palette,
                shapes: shapes
            )
        )
    }
    
    /// Adds a celebratory confetti preset whenever `trigger` changes.
    /// Use this for successful actions, milestones, and completed tasks.
    /// - Parameters:
    ///   - trigger: Any changing `Equatable` value that should emit a success burst.
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    func successConfetti(
        trigger: some Equatable,
        particleCount: Int = 150,
        lifetime: TimeInterval = 2.3,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(92),
        initialVelocity: ClosedRange<Double> = 280...520,
        gravity: Double = 680,
        palette: ConfettiConfiguration.Palette = .rainbow,
        shapes: [ConfettiConfiguration.Shape] = [.roundedRectangle, .rectangle, .sparkle]
    ) -> some View {
        confettiEffect(
            trigger: trigger,
            configuration: .success(
                particleCount: particleCount,
                lifetime: lifetime,
                launchAngle: launchAngle,
                spread: spread,
                initialVelocity: initialVelocity,
                gravity: gravity,
                palette: palette,
                shapes: shapes
            )
        )
    }
    
    /// Adds a restrained confetti preset whenever `trigger` changes.
    /// Use this for small confirmations or interactions that may happen frequently.
    /// - Parameters:
    ///   - trigger: Any changing `Equatable` value that should emit a subtle burst.
    ///   - particleCount: Number of particles generated per burst.
    ///   - lifetime: Maximum visible lifetime for generated particles.
    ///   - launchAngle: Base launch direction for the burst.
    ///   - spread: Angular spread around the launch angle.
    ///   - initialVelocity: Initial launch velocity range for generated particles.
    ///   - gravity: Downward acceleration applied every frame.
    ///   - particleScale: Multiplies all generated particle sizes.
    ///   - palette: Built-in color palette used for generated particles.
    ///   - shapes: Shapes available when generating particles.
    func subtleConfetti(
        trigger: some Equatable,
        particleCount: Int = 64,
        lifetime: TimeInterval = 1.6,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(58),
        initialVelocity: ClosedRange<Double> = 180...320,
        gravity: Double = 540,
        particleScale: Double = 0.72,
        palette: ConfettiConfiguration.Palette = .ocean,
        shapes: [ConfettiConfiguration.Shape] = [.circle, .roundedRectangle]
    ) -> some View {
        confettiEffect(
            trigger: trigger,
            configuration: .subtle(
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
        )
    }
    
    /// Adds a sparkle-focused confetti preset whenever `trigger` changes.
    /// Use this for lightweight celebratory accents that should feel bright and compact.
    /// - Parameters:
    ///   - trigger: Any changing `Equatable` value that should emit a sparkle burst.
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
    func sparkleConfetti(
        trigger: some Equatable,
        particleCount: Int = 96,
        lifetime: TimeInterval = 2.1,
        launchAngle: Angle = .degrees(-90),
        spread: Angle = .degrees(66),
        initialVelocity: ClosedRange<Double> = 220...390,
        gravity: Double = 480,
        particleScale: Double = 0.88,
        sparkleSharpness: Double = 2.6,
        palette: ConfettiConfiguration.Palette = .sunrise,
        shapes: [ConfettiConfiguration.Shape] = [.sparkle, .circle]
    ) -> some View {
        confettiEffect(
            trigger: trigger,
            configuration: .sparkle(
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
        )
    }
    
    /// Adds an ocean-colored glint confetti preset whenever `trigger` changes.
    /// Use this for soft twinkling accents with a translucent circular backing.
    /// - Parameters:
    ///   - trigger: Any changing `Equatable` value that should emit a glint burst.
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
    func glintConfetti(
        trigger: some Equatable,
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
        palette: ConfettiConfiguration.Palette = .ocean,
        shapes: [ConfettiConfiguration.Shape] = [.glint]
    ) -> some View {
        confettiEffect(
            trigger: trigger,
            configuration: .glint(
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
        )
    }
}
