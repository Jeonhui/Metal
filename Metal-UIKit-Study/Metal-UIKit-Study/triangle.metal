//
//  triangle.metal
//  Metal-UIKit-Study
//
//  Created by 이전희 on 5/21/24.
//

#include <metal_stdlib>
using namespace metal;

struct RasterizerData {
    float4 position [[position]]; // float4 타입의 좌표
    float4 color; // float4 color [[ attribute(1) ]];
    // 특정버퍼에 대한 포인터를 가져오는 대신 attribute에 인덱싱 된 값을 사용 가능
    // vertices.color[vetexId];
    
};

// return vertext & texture position
// buffer를 설정할 때 인덱싱, 파라미터로 읽음
// vertex_id: ushort or uint type vertext index
vertex RasterizerData vertexPassThroughShader(const device packed_float2* vertices [[ buffer(0) ]],
                                              const device packed_float4* colors [[buffer(1) ]],
                                              unsigned int vertexId [[ vertex_id ]]) {
    RasterizerData outData;
    outData.position = float4(vertices[vertexId], 0.0, 1.0);
    outData.color = colors[vertexId];
    return outData;
}

// return pixel color
// stage_in: 구조체로 캡슐화 된 데이터 포함(지울 시, color 값을 얻지 못함)
fragment float4 fragment fragmentPassThroughShader(RasterizerData data [[ stage_in ]]) {
    return data.color;
}

