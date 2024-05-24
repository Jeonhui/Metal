//
//  VertexPosition.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/23/24
//


import Foundation

struct VertexPosition {
    let x: CGFloat
    let y: CGFloat
    let z: CGFloat
    let w: CGFloat
    
    static var topLeft: Self { VertexPosition(x: -1.0, y: 1.0) }
    static var bottomLeft: Self  { VertexPosition(x: -1.0, y: -1.0) }
    static var topRight: Self { VertexPosition(x: 1.0, y: 1.0) }
    static var bottomRight: Self { VertexPosition(x: 1.0, y: -1.0) }
    
    init(x: CGFloat, y: CGFloat, z: CGFloat = 0.0, w: CGFloat = 1.0) {
        self.x = x
        self.y = y
        self.z = z
        self.w = w
    }
    
    func half() -> Self {
        VertexPosition(x: x/2, y: y/2)
    }
    
    var position: (x: CGFloat, y: CGFloat, z: CGFloat, w: CGFloat) {
        return (x, y, z, w)
    }
}
