//
//  ConfettiMetalView.swift
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

import MetalKit
import SwiftUI

struct ConfettiMetalView {
    let emissions: [ConfettiEmission]
    let configuration: ConfettiConfiguration
    let executionMode: ConfettiResolvedExecutionMode
    let size: CGSize
    let displayScale: CGFloat
}

#if os(iOS)
extension ConfettiMetalView: UIViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> MTKView {
        makeMTKView(coordinator: context.coordinator)
    }
    
    func updateUIView(_ view: MTKView, context: Context) {
        update(view: view, coordinator: context.coordinator)
    }
}
#elseif os(macOS)
extension ConfettiMetalView: NSViewRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeNSView(context: Context) -> MTKView {
        makeMTKView(coordinator: context.coordinator)
    }
    
    func updateNSView(_ view: MTKView, context: Context) {
        update(view: view, coordinator: context.coordinator)
    }
}
#endif

extension ConfettiMetalView {
    final class Coordinator {
        var renderer: ConfettiMetalRenderer?
    }
    
    @MainActor
    fileprivate func makeMTKView(coordinator: Coordinator) -> MTKView {
        let view = MTKView(frame: .zero)
        view.isOpaque = false
        view.clearColor = MTLClearColorMake(0, 0, 0, 0)
        view.colorPixelFormat = .bgra8Unorm
        view.framebufferOnly = false
        view.enableSetNeedsDisplay = false
        view.isPaused = false
        view.preferredFramesPerSecond = 60
        
        coordinator.renderer = ConfettiMetalRenderer(mtkView: view)
        coordinator.renderer?.onActivityChanged = { isActive in
            view.isPaused = !isActive
        }
        view.delegate = coordinator.renderer
        return view
    }
    
    @MainActor
    fileprivate func update(view: MTKView, coordinator: Coordinator) {
        view.drawableSize = CGSize(
            width: max(size.width * displayScale, 1),
            height: max(size.height * displayScale, 1)
        )
        let isActive = coordinator.renderer?.update(
            emissions: emissions,
            configuration: configuration,
            executionMode: executionMode,
            canvasSize: size
        ) ?? false
        
        view.isPaused = !isActive
        if isActive {
            view.draw()
        }
    }
}
