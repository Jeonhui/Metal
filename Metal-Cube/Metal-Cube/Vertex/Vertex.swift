//
//  Vertex.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/23/24
//

import UIKit
import SwiftUI
import simd

struct Vertex {
    var position: simd_float4
    var color: simd_float4
    
    init(position: VertexPosition,
         r: CGFloat = 0.0, g: CGFloat = 0.0, b: CGFloat = 0.0, a: CGFloat = 1.0) {
        let (x,y,z,w) = position.position
        self.position = simd_float4(Float(x), Float(y), Float(z), Float(w))
        self.color = simd_float4(Float(r), Float(g), Float(b), Float(a))
    }
    
    init(position: VertexPosition, uiColor: UIColor) {
        guard let cgColorComponents = uiColor.cgColor.components else {
            fatalError("Failed to convert UIColor to CGColor")
        }
        if cgColorComponents.count < 4 {
            let c = cgColorComponents[0]
            let a = cgColorComponents[1]
            self.init(position: position,
                      r: c, g: c, b: c, a: a)
        } else {
            let r = cgColorComponents[0]
            let g = cgColorComponents[1]
            let b = cgColorComponents[2]
            let a = cgColorComponents[3]
            self.init(position: position,
                      r: r, g: g, b: b, a: a)
        }
    }
    
    init(position: VertexPosition, color: Color) {
        self.init(position: position, uiColor: UIColor(color))
    }
}
