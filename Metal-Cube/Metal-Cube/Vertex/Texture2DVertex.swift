//
//  Texture2DVertex.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/23/24
//


import Foundation
import simd

struct Texture2DVertex{
    var position: simd_float4
    var texCoord: simd_float2
    
    init(position: VertexPosition,
         u: CGFloat, v: CGFloat) {
        let (x,y,z,w) = position.position
        self.position = simd_float4(Float(x), Float(y), Float(z), Float(w))
        self.texCoord = simd_float2(Float(u), Float(v))
    }
    
    init(position: VertexPosition,
         texCoord: Texture2DCoordinator) {
        let (u, v) = texCoord.coordinator
        self.init(position: position, u: u, v: v)
    }
}

