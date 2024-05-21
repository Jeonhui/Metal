//
//  add_arrays.metal
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/21/24.
//

#include <metal_stdlib>
using namespace metal;

// public GPU function
// compute parallel operation with use grid of threads
kernel void add_arrays(device const float* inA, // device address space
                       device const float* inB,
                       device float* result,
                       uint index [[thread_position_in_grid]]){
    result[index] = inA[index] + inB[index];
}

