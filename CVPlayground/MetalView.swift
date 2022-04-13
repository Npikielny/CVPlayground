//
//  MetalView.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import SwiftUI
import MetalKit

struct MetalView<S: Shader>: NSViewRepresentable {
    var view: MTKView
    
    init(frame: CGRect, shader: S) {
        view = MTKView(frame: frame, device: shader.device)
        view.delegate = shader
        let _ = Timer.scheduledTimer(withTimeInterval: 1 / 120, repeats: true) { [self] _ in
            shader.draw(in: view)
        }
    }
    
    init(frame: CGRect, shader: (MTKView) -> S) {
        view = MTKView(frame: frame)
        view.delegate = shader(view)
    }
    
    func makeNSView(context: Context) -> MTKView {
        return view
    }
    
    func updateNSView(_ nsView: MTKView, context: Context) {}
}
