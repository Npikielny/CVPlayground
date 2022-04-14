//
//  EdgeShaders.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import MetalKit

enum TemplateTextures: String, CaseIterable {
    case stonks = "stonksButBold"
}

enum EdgeTextures {
    case stonks
    case texture1
    case texture2
    case texture3
    case texture4
    case out
}

typealias EdgeShader = BaseShader<String, EdgeTextures>

extension EdgeShader {
    static func verticalEdgeShader(radius: Int32) -> EdgeShader? {
        return EdgeShader() { _ in
            [:]
        } textures: { device in
            let loader = Self.textureLoader(device: device)
            guard let stonks = loader("stonksButBold") else { return [:] }
            return [.stonks: stonks]
        } pipeline: { create, device in
            guard let pipeline: EdgeShader.Pipeline = .render(
                vertexFunction: EdgeShader.copyVertex,
                fragmentFunction: "verticalEdge",
                create: { create($0, nil) },
                device: device,
                fragmentTextures: [.stonks],
                fragmentBytes: [Packet(radius)],
                threadSize: MTLSize(width: 8, height: 8, depth: 1)
            ) else { return nil }
            return [pipeline]
        }
    }
    
    static func edgeShader(radius: Int32, view: MTKView) -> EdgeShader? {
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        let loader = Self.textureLoader(device: device)
        guard let stonks = loader("stonksButBold") else { return nil }
        guard let texture1 = Self.texture(device: device, view: view, size: (width: stonks.width, height: stonks.height), renderTarget: true),
              let texture2 = Self.texture(device: device, view: view, size: (width: stonks.width, height: stonks.height), renderTarget: true),
              let texture3 = Self.texture(device: device, view: view, size: (width: stonks.width, height: stonks.height), renderTarget: true),
              let texture4 = Self.texture(device: device, view: view, size: (width: stonks.width, height: stonks.height), renderTarget: true),
              let out = Self.texture(device: device, view: view, size: (width: stonks.width, height: stonks.height), renderTarget: true)
        else { return nil }
        
        let shader = EdgeShader(runType: .continuous) { _ in
            [:]
        } textures: { device in
            return [.stonks: stonks, .texture1: texture1, .texture2: texture2, .texture3: texture3, .texture4: texture4, .out: out]
        } pipeline: { create, device in
            let descriptors = [
                MTLRenderPassDescriptor(),
                MTLRenderPassDescriptor(),
                MTLRenderPassDescriptor(),
                MTLRenderPassDescriptor(),
                MTLRenderPassDescriptor()
            ]
            descriptors.forEach { descriptor in
                descriptor.colorAttachments[0].loadAction = .clear
                descriptor.colorAttachments[0].storeAction = .store
                descriptor.renderTargetWidth = stonks.width
                descriptor.renderTargetHeight = stonks.height
                descriptor.defaultRasterSampleCount = 1
                descriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
            }
            let kernels = ["verticalEdge", "horizontalEdge", "diagonalPositive", "diagonalNegative"]
            let textures = [texture1, texture2, texture3, texture4, out]
            var pipelines = [Pipeline]()
            for i in 0..<kernels.count {
                descriptors[i].colorAttachments[0].texture = textures[i]
                
                guard let pipeline: Pipeline = .render(
                    vertexFunction: Self.copyVertex,
                    fragmentFunction: kernels[i],
                    renderPassDescriptor: descriptors[i],
                    pixelFormat: view.colorPixelFormat,
                    create: { create($0, nil) },
                    device: device,
                    fragmentTextures: [.stonks],
                    fragmentBytes: [Packet(radius)]
                ) else { print("failed making pipeline \(kernels[i])"); return nil }
                pipelines.append(
                    pipeline
                )
            }
            
            descriptors[descriptors.count - 1].colorAttachments[0].texture = textures[textures.count - 1]
            guard let combinePipeline: Pipeline = .render(
                vertexFunction: Self.copyVertex,
                fragmentFunction: "combine",
                renderPassDescriptor: descriptors[descriptors.count - 1],
                pixelFormat: view.colorPixelFormat,
                create: { create($0, nil) },
                device: device,
                fragmentTextures: [.texture1, .texture2, .texture3, .texture4, .stonks]
            ) else {
                return nil
            }

            pipelines.append(combinePipeline)
            
            guard let presentPipeline: Pipeline = .render(
                vertexFunction: Self.copyVertex,
                fragmentFunction: Self.copyFragment,
                pixelFormat: view.colorPixelFormat,
                create: { create($0, nil) },
                device: device,
                fragmentTextures: [.out]
            ) else {
                return nil
            }
            pipelines.append(presentPipeline)
            return pipelines
        }
        
        guard let shader = shader else { return nil }
        view.delegate = shader
        view.device = shader.device
        shader.mtkView(view, drawableSizeWillChange: CGSize(width: stonks.width, height: stonks.height))
        return shader
    }
}

