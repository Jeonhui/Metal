//
//  Texture2DCoordinator.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/23/24
//


import Foundation

struct Texture2DCoordinator {
    let u: CGFloat
    let v: CGFloat
    
    static var topLeft: Self { Texture2DCoordinator(u: 0.0, v: 0.0) }
    static var bottomLeft: Self  { Texture2DCoordinator(u: 0.0, v: 1.0) }
    static var topRight: Self { Texture2DCoordinator(u: 1.0, v: 0.0) }
    static var bottomRight: Self { Texture2DCoordinator(u: 1.0, v: 1.0) }
    
    init(u: CGFloat, v: CGFloat) {
        self.u = u
        self.v = v
    }
    
    var coordinator: (u: CGFloat, v: CGFloat) { (u, v) }
}
