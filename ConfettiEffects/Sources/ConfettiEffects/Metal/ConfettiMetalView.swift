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
    
    static func dismantleUIView(_ view: MTKView, coordinator: Coordinator) {
        dismantle(view: view, coordinator: coordinator)
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
    
    static func dismantleNSView(_ view: MTKView, coordinator: Coordinator) {
        dismantle(view: view, coordinator: coordinator)
    }
}
#endif

extension ConfettiMetalView {
    final class Coordinator {
        var renderer: ConfettiMetalRenderer?
    }
    
    @MainActor
    private func makeMTKView(coordinator: Coordinator) -> MTKView {
        let view = MTKView(frame: .zero)
        #if os(iOS)
        view.isOpaque = false
        #elseif os(macOS)
        view.layer?.isOpaque = false
        view.layer?.backgroundColor = NSColor.clear.cgColor
        #endif
        view.clearColor = MTLClearColorMake(0, 0, 0, 0)
        view.colorPixelFormat = .bgra8Unorm
        view.framebufferOnly = false
        
        view.autoResizeDrawable = false
        view.enableSetNeedsDisplay = false
        view.preferredFramesPerSecond = 60
        
        // Keep the draw loop stopped until SwiftUI provides valid content to render.
        view.isPaused = true
        
        coordinator.renderer = ConfettiMetalRenderer(mtkView: view)
        
        // Do not let renderer activity callbacks keep the platform view alive.
        coordinator.renderer?.onActivityChanged = { [weak view] isActive in
            Task { @MainActor [weak view] in
                view?.isPaused = !isActive
            }
        }
        view.delegate = coordinator.renderer
        return view
    }
    
    @MainActor
    private static func dismantle(view: MTKView, coordinator: Coordinator) {
        view.isPaused = true
        view.delegate = nil
        coordinator.renderer?.onActivityChanged = nil
        coordinator.renderer = nil
    }
    
    @MainActor
    private func update(view: MTKView, coordinator: Coordinator) {
        // Skip rendering until SwiftUI reports a usable logical size and display scale.
        guard size.width > 0, size.height > 0,
              size.width.isFinite, size.height.isFinite,
              displayScale > 0, displayScale.isFinite else {
            view.isPaused = true
            return
        }
        
        view.drawableSize = CGSize(
            width: size.width * displayScale,
            height: size.height * displayScale
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
