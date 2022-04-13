//
//  TextureLoading.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import MetalKit

extension Shader {
    static var textureLoaderOptions: [MTKTextureLoader.Option : NSNumber] {
        [
            MTKTextureLoader.Option.allocateMipmaps: NSNumber(value: false),
            MTKTextureLoader.Option.SRGB: NSNumber(value: false)
        ]
    }
//    var textureLoader: MTKTextureLoader { MTKTextureLoader(device: device) }
//
//    func loadTexture(named: String) -> MTLTexture? {
//        let image = NSImage(named: named)
//        guard let data = image?.tiffRepresentation else { print("failed getting image data"); return nil }
//        do {
//            return try textureLoader.newTexture(data: data, options: Self.textureLoaderOptions)
//        } catch {
//            print(error.localizedDescription)
//            return nil
//        }
//    }
    static func textureLoader(device: MTLDevice) -> ((String) -> MTLTexture?) {
        let loader = MTKTextureLoader(device: device)
        
        return { named in
            let image = NSImage(named: named)
            guard let data = image?.tiffRepresentation else { print("failed getting image data"); return nil }
            do {
                return try loader.newTexture(data: data, options:
                                                [
                                                    MTKTextureLoader.Option.allocateMipmaps: NSNumber(value: false),
                                                    MTKTextureLoader.Option.SRGB: NSNumber(value: false)
                                                ]
                )
            } catch {
                print(error.localizedDescription)
                return nil
            }
        }
    }
}
