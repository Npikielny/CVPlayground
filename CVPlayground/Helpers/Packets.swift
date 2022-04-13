//
//  Packet.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

import Metal

public class Packet  {
    private var compute: ((MTLComputeCommandEncoder, Int) -> Void)?
    private var vertex: ((MTLRenderCommandEncoder, Int) -> Void)?
    private var fragment: ((MTLRenderCommandEncoder, Int) -> Void)?
    
    func erase() {
        compute = nil
        vertex = nil
        fragment = nil
    }
    
    func setBytes(encoder: MTLComputeCommandEncoder, index: Int) {
        compute!(encoder, index)
        erase()
    }
    
    func setVertexBytes(encoder: MTLRenderCommandEncoder, index: Int) {
        vertex!(encoder, index)
        erase()
    }
    
    func setFragmentBytes(encoder: MTLRenderCommandEncoder, index: Int) {
        fragment!(encoder, index)
        erase()
    }
    
    public init<T>(_ array: Array<T>) {
        compute = { encoder, index in
            encoder.setBytes(array, length: MemoryLayout<T>.stride * array.count, index: index)
        }
        vertex = { encoder, index in
            encoder.setVertexBytes(array, length: MemoryLayout<T>.stride * array.count, index: index)
        }
        fragment = { encoder, index in
            encoder.setFragmentBytes(array, length: MemoryLayout<T>.stride * array.count, index: index)
        }
    }
    
    public init<T>(_ element: T) {
        compute = { encoder, index in
            encoder.setBytes([element], length: MemoryLayout<T>.stride, index: index)
        }
        vertex = { encoder, index in
            encoder.setVertexBytes([element], length: MemoryLayout<T>.stride, index: index)
        }
        fragment = { encoder, index in
            encoder.setFragmentBytes([element], length: MemoryLayout<T>.stride, index: index)
        }
    }
}

extension Array where Element == Packet {
    func computeBytes(_ encoder: MTLComputeCommandEncoder, offset: Int) {
        enumerated().forEach { index, packet in
            packet.setBytes(encoder: encoder, index: index + offset)
        }
    }
    
    func vertexBytes(_ encoder: MTLRenderCommandEncoder, offset: Int) {
        enumerated().forEach { index, packet in
            packet.setVertexBytes(encoder: encoder, index: index + offset)
        }
    }
    
    func fragmentBytes(_ encoder: MTLRenderCommandEncoder, offset: Int) {
        enumerated().forEach { index, packet in
            packet.setFragmentBytes(encoder: encoder, index: index + offset)
        }
    }
}
