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
    
    static func texture(
        device: MTLDevice,
        view: MTKView,
        size: (width: Int, height: Int),
        editable: Bool = false,
        read: Bool = true,
        write: Bool = true,
        renderTarget: Bool
    ) -> MTLTexture? {
        let renderTargetDescriptor = MTLTextureDescriptor()
        renderTargetDescriptor.pixelFormat = view.colorPixelFormat
        renderTargetDescriptor.textureType = MTLTextureType.type2D
        renderTargetDescriptor.width = size.width
        renderTargetDescriptor.height = size.width
        renderTargetDescriptor.storageMode = editable ? .managed : .private
        renderTargetDescriptor.usage = MTLTextureUsage([] + (renderTarget ? [.renderTarget] : []) + (read ? [.shaderRead] : []) + (write ? [.shaderWrite] : []))
        return device.makeTexture(descriptor: renderTargetDescriptor)
    }
}
