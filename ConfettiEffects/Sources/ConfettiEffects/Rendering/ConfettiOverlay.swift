//
//  ConfettiOverlay.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import SwiftUI

struct ConfettiOverlay: View {
    @Environment(\.displayScale) private var displayScale
    
    let emissions: [ConfettiEmission]
    let configuration: ConfettiConfiguration
    
    var body: some View {
        if emissions.isEmpty {
            EmptyView()
        } else {
            GeometryReader { proxy in
                let executionMode = configuration.resolvedExecutionMode(
                    isMetalAvailable: ConfettiMetalRenderer.isSupported,
                    canvasSize: proxy.size,
                    displayScale: displayScale,
                    liveParticleCount: emissions.reduce(0) { $0 + $1.particles.count }
                )
                
                switch executionMode {
                case .cpuCanvas:
                    ConfettiCanvasOverlay(
                        emissions: emissions,
                        configuration: configuration
                    )
                case .metalCPUSimulation, .metalGPUSimulation:
                    ConfettiMetalView(
                        emissions: emissions,
                        configuration: configuration,
                        executionMode: executionMode,
                        size: proxy.size,
                        displayScale: displayScale
                    )
                }
            }
        }
    }
}

private struct ConfettiCanvasOverlay: View {
    private static let circlePath = Path(ellipseIn: CGRect(x: -0.5, y: -0.5, width: 1, height: 1))
    private static let rectanglePath = Path(CGRect(x: -0.5, y: -0.5, width: 1, height: 1))
    private static let roundedRectanglePath = RoundedRectangle(
        cornerRadius: 0.25,
        style: .continuous
    ).path(in: CGRect(x: -0.5, y: -0.5, width: 1, height: 1))
    
    let emissions: [ConfettiEmission]
    let configuration: ConfettiConfiguration
    
    var body: some View {
        TimelineView(.animation) { context in
            Canvas { canvas, canvasSize in
                let origin = configuration.resolvedOrigin(in: canvasSize)
                
                for emission in emissions {
                    let baseElapsed = context.date.timeIntervalSince(emission.birthDate)
                    
                    for particle in emission.particles {
                        let elapsed = baseElapsed
                        
                        guard let sample = ConfettiSimulation.sample(
                            particle: particle,
                            elapsed: elapsed,
                            origin: origin,
                            configuration: configuration
                        ) else {
                            continue
                        }
                        
                        var transform = CGAffineTransform.identity
                        transform = transform.translatedBy(x: sample.position.x, y: sample.position.y)
                        transform = transform.rotated(by: sample.rotation.radians)
                        transform = transform.scaledBy(x: sample.size.width, y: sample.size.height)
                        
                        var particleCanvas = canvas
                        particleCanvas.opacity = sample.opacity
                        particleCanvas.fill(
                            path(for: particle.shape).applying(transform),
                            with: .color(sample.color)
                        )
                    }
                }
            }
        }
    }
    
    private func path(for shape: ConfettiConfiguration.Shape) -> Path {
        switch shape {
        case .circle:
            return Self.circlePath
        case .rectangle:
            return Self.rectanglePath
        case .roundedRectangle:
            return Self.roundedRectanglePath
        }
    }
}
