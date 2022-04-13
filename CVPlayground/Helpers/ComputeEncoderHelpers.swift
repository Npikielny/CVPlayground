//
//  ComputeEncoderHelpers.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

import MetalKit

extension MTLComputeCommandEncoder {
    func encodeInformation(
        shader: MTLComputePipelineState,
        buffers: [MTLBuffer],
        packets: [Packet],
        textures: [MTLTexture]
    ) {
        setComputePipelineState(shader)
        setBuffers(buffers, offsets: Array(repeating: 0, count: buffers.count), range: 0..<buffers.count)
        packets.computeBytes(self, offset: buffers.count)
        setTextures(textures, range: 0..<textures.count)
    }
    
    func encodeAndDispatch(
        shader: MTLComputePipelineState,
        buffers: [MTLBuffer],
        packets: [Packet],
        textures: [MTLTexture],
        threadGroupSize: MTLSize = MTLSize(width: 8, height: 8, depth: 1),
        threadGroups: MTLSize,
        endEncoding: Bool = true
    ) {
        encodeInformation(shader: shader, buffers: buffers, packets: packets, textures: textures)
        dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadGroupSize)
        if endEncoding {
            self.endEncoding()
        }
    }
    
    func dispatchThreadgroups(threadGroupSize: MTLSize, totalSize: MTLSize) {
        dispatchThreadgroups(
            MTLSize(
                width: totalSize.width + (threadGroupSize.width - 1),
                height: totalSize.height + (threadGroupSize.height - 1),
                depth: 1
            ),
            threadsPerThreadgroup: threadGroupSize
        )
    }
    
    func dispatchThreadgroups(threadGroupSize: MTLSize, workingTexture: MTLTexture) {
        dispatchThreadgroups(
            MTLSize(
                width: workingTexture.width + (threadGroupSize.width - 1),
                height: workingTexture.height + (threadGroupSize.height - 1),
                depth: 1
            ),
            threadsPerThreadgroup: threadGroupSize
        )
    }
    
    
    func encodeAndDispatch(
        shader: MTLComputePipelineState,
        buffers: [MTLBuffer],
        packets: [Packet],
        textures: [MTLTexture],
        threadGroupSize: MTLSize = MTLSize(width: 8, height: 8, depth: 1),
        totalSize: MTLSize,
        endEncoding: Bool = true
    ) {
        encodeAndDispatch(
            shader: shader,
            buffers: buffers,
            packets: packets,
            textures: textures,
            threadGroupSize: threadGroupSize,
            threadGroups: MTLSize(
                width: totalSize.width + (threadGroupSize.width - 1),
                height: totalSize.height + (threadGroupSize.height - 1),
                depth: 1
            ),
            endEncoding: endEncoding)
    }
    
    func encodeAndDispatch(
        shader: MTLComputePipelineState,
        buffers: [MTLBuffer],
        packets: [Packet],
        textures: [MTLTexture],
        threadGroupSize: MTLSize = MTLSize(width: 8, height: 8, depth: 1),
        workingTexture: MTLTexture,
        endEncoding: Bool = true
    ) {
        encodeAndDispatch(
            shader: shader,
            buffers: buffers,
            packets: packets,
            textures: textures,
            threadGroupSize: threadGroupSize,
            totalSize: MTLSize(width: workingTexture.width, height: workingTexture.height, depth: 1),
            endEncoding: endEncoding
        )
    }
}
