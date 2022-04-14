//
//  Convolve.swift
//  CVPlayground
//
//  Created by Noah Pikielny on 4/14/22.
//

import Foundation

extension BaseShader {
//    static func convolve(radius: Int, weightFunction: (_ dx: Int, _ dy: Int) -> Float) -> Self? {
//        var weights = [Float]()
//        for x in -radius...radius {
//            for y in -radius...radius {
//                weights.append(weightFunction(x, y))
//            }
//        }
//        return convolve(radius: radius, weights: weights)
//    }
//    static func convolve(runType: RunType = .single, radius: Int, weights: [Float]) -> Self? {
//        let side = (radius * 2 + 1)
//        assert(weights.count == side * side)
//        
//        return Self.init(runType: runType, buffers: <#T##(MTLDevice) -> [Hashable : MTLBuffer]#>, textures: <#T##[Hashable : String]#>, pipeline: <#T##((String, MTLFunctionConstantValues?) -> MTLFunction?, MTLDevice) -> [BaseShader<Hashable, Hashable>.Pipeline]?#>)
//    }
}
