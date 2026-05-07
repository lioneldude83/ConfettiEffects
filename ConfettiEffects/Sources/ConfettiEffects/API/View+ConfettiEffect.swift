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
    func confettiEffect<Trigger: Equatable>(
        trigger: Trigger,
        configuration: ConfettiConfiguration = ConfettiConfiguration()
    ) -> some View {
        modifier(ConfettiEffectModifier(trigger: trigger, configuration: configuration))
    }
}
