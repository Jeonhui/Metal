//
//  simd+.swift
//  Metal-Cube
//
//  Created by Jeonhui on 5/24/24
//


import Foundation
import simd

/*
 simd_bool Bool
 simd_int1 Int32
 simd_int2 SIMD2<Int32>
 simd_int3 SIMD3<Int32>
 simd_int4 SIMD4<Int32>
 simd_int8 SIMD8<Int32>
 simd_int16 SIMD16<Int32>
 simd_char1 CChar
 simd_char2 SIMD2<CChar>
 simd_char3 SIMD3<CChar>
 simd_char4 SIMD4<CChar>
 simd_char8 SIMD8<CChar>
 simd_char16 SIMD16<CChar>
 simd_char32 SIMD32<CChar>
 simd_char64 SIMD64<CChar>
 simd_float1 Float
 simd_float2 SIMD2<Float>
 simd_float3 SIMD3<Float>
 simd_float4 SIMD4<Float>
 simd_float8 SIMD8<Float>
 simd_float16 SIMD16<Float>
 simd_long1 Int
 simd_long2 SIMD2<Int>
 simd_long3 SIMD3<Int>
 simd_long4 SIMD4<Int>
 simd_long8 SIMD8<Int>
 ...
 */


extension SIMD {
    init(sequence: [Scalar]) {
        self.init(sequence)
    }
}

extension SIMD4<Float> {
    init(array: [CGFloat]) {
        guard array.count == 4 else {
            fatalError("array element count must be 4")
        }
        self.init(sequence: array.map { Float($0) })
    }
    
    var values: [CGFloat] {
        return (0..<4).map { CGFloat(self[$0]) }
    }
}

extension simd_float4x4 {
    init(array: [[CGFloat]]) {
        guard array.count == 4 else {
            fatalError("array element count must be 4")
        }
        self.init(rows: array.map{ simd_float4(array: $0) })
    }
    
    var values: [[CGFloat]] {
        return (0..<4).map { self[$0].values }
    }
}

