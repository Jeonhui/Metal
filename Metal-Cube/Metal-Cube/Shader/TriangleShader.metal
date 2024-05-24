//
//  TriangleShader2.metal
//  Metal-Cube
//
//  Created by Jeonhui on 5/23/24
//


#include <metal_stdlib>
using namespace metal;

struct VertexTriangle2 {
    float4 position;
    float4 color;
};

struct VertexTriangle2Out {
    float4 position [[position]];
    float4 color;
};

vertex VertexTriangle2Out vertexTriangle2(uint vertexId [[vertex_id]],
                                constant VertexTriangle2* vertices [[buffer(0)]]) {
    VertexTriangle2Out out;
    
    out.position = vertices[vertexId].position;
    out.color = vertices[vertexId].color;
    
    return out;
}

fragment float4 fragmentTriangle2(VertexTriangle2Out in [[stage_in]]) {
    return in.color;
}
