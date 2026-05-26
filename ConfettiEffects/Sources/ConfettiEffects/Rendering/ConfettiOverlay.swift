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
    private static func sparklePath(sharpness: Double) -> Path {
        var path = Path()
        let innerOffset = 0.26 / sharpness
        let points = [
            CGPoint(x: 0, y: -0.5),
            CGPoint(x: innerOffset, y: -innerOffset),
            CGPoint(x: 0.5, y: 0),
            CGPoint(x: innerOffset, y: innerOffset),
            CGPoint(x: 0, y: 0.5),
            CGPoint(x: -innerOffset, y: innerOffset),
            CGPoint(x: -0.5, y: 0),
            CGPoint(x: -innerOffset, y: -innerOffset),
        ]
        
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
    
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
                        
                        drawParticle(
                            particle.shape,
                            sample: sample,
                            transform: transform,
                            in: canvas
                        )
                    }
                }
            }
        }
    }
    
    private func drawParticle(
        _ shape: ConfettiConfiguration.Shape,
        sample: ConfettiParticleSample,
        transform: CGAffineTransform,
        in canvas: GraphicsContext
    ) {
        if shape == .glint {
            var backingCanvas = canvas
            backingCanvas.opacity = sample.opacity * configuration.glintCircleOpacity
            let circleTransform = transform.scaledBy(
                x: configuration.glintCircleScale,
                y: configuration.glintCircleScale
            )
            backingCanvas.fill(
                Self.circlePath.applying(circleTransform),
                with: .color(sample.color)
            )
            
            var sparkleCanvas = canvas
            sparkleCanvas.opacity = sample.opacity
            sparkleCanvas.fill(
                Self.sparklePath(sharpness: configuration.sparkleSharpness).applying(transform),
                with: .color(sample.color)
            )
        } else {
            var particleCanvas = canvas
            particleCanvas.opacity = sample.opacity
            particleCanvas.fill(
                path(for: shape).applying(transform),
                with: .color(sample.color)
            )
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
        case .sparkle, .glint:
            return Self.sparklePath(sharpness: configuration.sparkleSharpness)
        }
    }
}
