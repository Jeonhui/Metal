//
//  imageRectangle.metal
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/22/24.
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

typedef struct {
    float4 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
} ImageVertex;

typedef struct {
    float4 position [[position]];
    float2 texCoord;
} ImageOut;


vertex ImageOut imageVertexFunction( ImageVertex in [[stage_in]]) {
    ImageOut out;
    
    float4 position = float4(in.position);
    out.position = position;
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 imageFragmentFunction(ImageOut in [[stage_in]], texture2d<float> texture [[texture(0)]] ) {
    
    constexpr sampler colorSampler;
    float4 color = texture.sample(colorSampler, in.texCoord);
    return color;
}
