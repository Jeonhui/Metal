//
//  TriangleShader.metal
//  Metal-Cube
//
//  Created by Jeonhui on 5/22/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexTriangle {
    float2 position;
    float3 color;
};

struct VertexTriangleOut {
    float4 position [[position]];
    float3 color;
};

vertex VertexTriangleOut vertexTriangle(uint vertexId [[vertex_id]],
                                constant VertexTriangle* vertices [[buffer(0)]]) {
    VertexTriangleOut out;
    
    out.position = float4(vertices[vertexId].position, 0.0, 1.0);
    out.color = vertices[vertexId].color;
    
    return out;
}

fragment float4 fragmentTriangle(VertexTriangleOut in [[stage_in]]) {
    return float4(in.color, 1.0);
}
