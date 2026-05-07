//
//  ConfettiEffectModifier.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import SwiftUI

struct ConfettiEffectModifier<Trigger: Equatable>: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var accessibilityReduceMotion
    
    let trigger: Trigger
    let configuration: ConfettiConfiguration
    
    @State private var emissions: [ConfettiEmission] = []
    @State private var sequence: UInt64 = 0
    @State private var nextCleanupDate: Date?
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ConfettiOverlay(
                    emissions: emissions,
                    configuration: effectiveConfiguration
                )
                .allowsHitTesting(false)
                .accessibilityHidden(true)
            }
            .onChange(of: trigger, initial: false) { _, _ in
                emitConfetti()
            }
            .task(id: nextCleanupDate) {
                await cleanupExpiredEmissionsWhenNeeded()
            }
    }
    
    private func emitConfetti() {
        let configuration = effectiveConfiguration
        let now = Date()
        
        pruneExpiredEmissions(referenceDate: now)
        sequence &+= 1
        
        emissions.append(
            ConfettiEmission(
                id: sequence,
                birthDate: now,
                particles: ConfettiSimulation.makeBurst(
                    configuration: configuration,
                    seed: sequence
                )
            )
        )
        
        scheduleNextCleanup()
    }
    
    private func pruneExpiredEmissions(referenceDate: Date) {
        emissions.removeAll { $0.expirationDate(configuration: effectiveConfiguration) <= referenceDate }
        scheduleNextCleanup()
    }
    
    private func scheduleNextCleanup() {
        nextCleanupDate = emissions
            .map { $0.expirationDate(configuration: effectiveConfiguration) }
            .min()
    }
    
    @MainActor
    private func cleanupExpiredEmissionsWhenNeeded() async {
        guard let nextCleanupDate else {
            return
        }
        
        let delay = max(0, nextCleanupDate.timeIntervalSinceNow)
        if delay > 0 {
            let duration = Duration.seconds(delay)
            
            do {
                try await Task.sleep(for: duration)
            } catch {
                return
            }
        }
        
        pruneExpiredEmissions(referenceDate: Date())
    }
    
    private var effectiveConfiguration: ConfettiConfiguration {
        configuration.adjustedForReduceMotion(accessibilityReduceMotion)
    }
}
