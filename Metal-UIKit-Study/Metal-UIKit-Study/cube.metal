//
//  cube.metal
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/22/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4 vertex_cube(const VertexIn vertex_in[[ stage_in ]],
                          constant float &timer [[ buffer(1) ]]) {
    float4 position = vertex_in.position;
    position.y += timer;
    return position;
}

