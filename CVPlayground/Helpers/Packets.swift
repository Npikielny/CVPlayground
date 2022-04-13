//
//  Packet.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

import Metal

public class Packet  {
    private var v: ((MTLComputeCommandEncoder, Int) -> Void)?
    
    internal func setBytes(encoder: MTLComputeCommandEncoder, index: Int) {
        v!(encoder, index)
        v = nil
    }
    
    public init<T>(_ array: Array<T>) {
        self.v = { encoder, index in
            encoder.setBytes(array, length: MemoryLayout<T>.stride * array.count, index: index)
        }
    }
    
    public init<T>(_ element: T) {
        self.v = { encoder, index in
            encoder.setBytes([element], length: MemoryLayout<T>.stride, index: index)
        }
    }
}
