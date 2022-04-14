//
//  GaussShader.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import MetalKit

typealias GaussShader = BaseShader<String, TemplateTextures>

extension GaussShader {
    static func gaussShader(radius: Int32) -> GaussShader? {
        GaussShader(textures: [.stonks: TemplateTextures.stonks.rawValue]) { create, device in
            guard let pipeline: Pipeline = .render(
                vertexFunction: GaussShader.copyVertex,
                fragmentFunction: "gauss",
                create: { create($0, nil) },
                device: device,
                fragmentTextures: [.stonks],
                fragmentBytes: [Packet(radius)]
            ) else { return nil }
            return [pipeline]
        }

    }
}
