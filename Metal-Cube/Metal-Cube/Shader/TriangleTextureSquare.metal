//
//  TriangleShader.metal
//  Metal-Cube
//
//  Created by Jeonhui on 5/22/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexTextureSquare {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
};

struct VertexTextureSquareOut {
    float4 position [[position]];
    float2 texCoord;
};

vertex VertexTextureSquareOut vertexTextureSquare(VertexTextureSquare in [[stage_in]]) {
    VertexTextureSquareOut out;
    out.position = in.position;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragmentTextureSquare(VertexTextureSquareOut in [[stage_in]],
                                 texture2d<float> colorTexture [[texture(0)]]) {
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear);
    float4 color = colorTexture.sample(colorSampler, in.texCoord);
    return float4(color.rgb, 1.0);
}
