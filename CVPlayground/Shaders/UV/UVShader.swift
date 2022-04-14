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
        ResourcelessShader.init { create, device in
            guard let pipeline: ResourcelessShader.Pipeline = .render(
                vertexFunction: ResourcelessShader.copyVertex,
                fragmentFunction: "uvFragment",
                create: { create($0, nil) },
                device: device,
                threadSize: MTLSize(width: 8, height: 8, depth: 1)
            ) else { return nil }
                
            return [
                pipeline
            ]
        }

    }
}
