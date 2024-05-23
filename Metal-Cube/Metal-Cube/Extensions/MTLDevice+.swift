//
//  MTLDevice+.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/23/24.
//

import Metal

extension MTLDevice {
    func makeBuffer<T: Any>(array: [T],
                            options: MTLResourceOptions = []) -> (any MTLBuffer)? {
        return array.withUnsafeBytes { bufferPointer in
            guard let address = bufferPointer.baseAddress else { return nil }
            let dataSize = array.count * MemoryLayout<T>.stride
            return self.makeBuffer(bytes: address,
                                   length: dataSize,
                                   options: options)
        }
    }
}


