//
//  UVShader.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import Foundation
import Metal

extension ResourcelessShader {
    static func UVShader() -> ResourcelessShader? {
        ResourcelessShader.init { _ in
            return [:]
        } textures: { _ in
            return [:]
        } pipeline: { create, device in
            guard let vertexFunction = create(ResourcelessShader.copyVertex, nil),
                  let fragmentFunction = create("uvFragment", nil) else { print("failed making functions"); return nil }
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.sampleCount = 1
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            do {
                let pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
                return [
                    .render(pipelineState: pipeline, instructions: { uvShader, texture, renderPassDescriptor, commandBuffer, pipelineState in
                        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
                        encoder.setRenderPipelineState(pipelineState)
                        encoder.setFragmentTexture(texture, index: 0)
                        encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
                        encoder.endEncoding()
                    })
                ]
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
}
