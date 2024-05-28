//
//  QuadShader.metal
//  Metal-Cube
//
//  Created by Jeonhui on 5/24/24
//


#include <metal_stdlib>
using namespace metal;

struct VertexQuad {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexQuadOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexQuadOut vertexQuadFunction(VertexQuad in [[stage_in]],
                                        // const float2& quadPosition [[buffer(0)]]
                                        // constant float4x4& projectionMatrix [[buffer(0)]],
                                        constant float4x4& modelMatrix [[buffer(1)]]) {
    VertexQuadOut out;
    // out.position = float4(quadPosition + in.position, 0.0, 1.0);
    // out.position = modelMatrix * float4 (in.position, 0.0 , 1.0 );
    // out.position = modelMatrix * in.position;
    
    out.position = modelMatrix * in.position;
    // out.position = projectionMatrix * modelMatrix * in.position;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragmentQuadFunction(VertexQuadOut in [[stage_in]],
                                   texture2d<float> colorTexture [[texture(0)]]) {
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    float4 color = colorTexture.sample(colorSampler, in.texCoord);
    return float4(color.rgb, 1.0);
}
