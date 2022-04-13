//
//  RenderPipelineHelpers.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import MetalKit

extension BaseShader {
    func create(vertexFunction: MTLFunction, fragmentFunction: MTLFunction, view: MTKView) throws -> MTLRenderPipelineState {
        let pipeline = MTLRenderPipelineDescriptor()
        pipeline.sampleCount = 1
        pipeline.vertexFunction = vertexFunction
        pipeline.fragmentFunction = fragmentFunction
        pipeline.colorAttachments[0].pixelFormat = view.colorPixelFormat
        return try device.makeRenderPipelineState(descriptor: pipeline)
    }
    
    static var copyFragment: String { "copyFragment" }
    static var copyVertex: String { "copyVertex" }
}

