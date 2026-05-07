//
//  ConfettiModels.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import SwiftUI

struct ConfettiEmission: Equatable {
    let id: UInt64
    let birthDate: Date
    let particles: [ConfettiParticle]
}

struct ConfettiParticle: Equatable {
    let position: CGPoint
    let velocity: CGVector
    let size: CGSize
    let rotation: Angle
    let angularVelocity: Double
    let colorIndex: Int
    let shape: ConfettiConfiguration.Shape
    let lifetime: Double
    let drag: Double
}

struct ConfettiParticleSample {
    let position: CGPoint
    let rotation: Angle
    let size: CGSize
    let opacity: Double
    let color: Color
}

extension ConfettiEmission {
    func expirationDate(configuration: ConfettiConfiguration) -> Date {
        let particleLifetime = particles.map(\.lifetime).max() ?? configuration.lifetime
        return birthDate.addingTimeInterval(particleLifetime)
    }
}
