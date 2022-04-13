//
//  EdgeShaders.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import MetalKit

enum TemplateTextures {
    case stonks
}

extension Shader {
    static func verticalEdgeShader() -> BaseShader<String, TemplateTextures>? {
        return BaseShader<String, TemplateTextures>.init { _ in
            return [:]
        } textures: { device in
            let loader = Self.textureLoader(device: device)
            guard let stonks = loader("stonksButBold") else { return [:] }
            return [.stonks: stonks]
        } pipeline: { create, device in
            guard let vertexFunction = create(ResourcelessShader.copyVertex, nil),
                  let fragmentFunction = create("verticalEdge", nil) else { print("failed making functions"); return nil }
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = fragmentFunction
            descriptor.sampleCount = 1
            descriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
            do {
                let pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
                return [
                    .render(pipelineState: pipeline, instructions: { edgeShader, texture, renderPassDescriptor, commandBuffer, pipelineState in
                        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else { return }
                        guard let stonksTexture = edgeShader[TemplateTextures.stonks] else { return }
                        encoder.setRenderPipelineState(pipelineState)
                        encoder.setFragmentBytes([Int32(5)], length: MemoryLayout<Int32>.stride, index: 0)
                        encoder.setFragmentTexture(stonksTexture, index: 0)
                        encoder.setFragmentTexture(texture, index: 1)
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
