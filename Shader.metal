//
//  Shader1.metal
//  MetalBezierDrawing
//
//  Created by radhika sharma on 11/2/26.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut {
    float4 position [[position]];
};

vertex VertexOut vertexMain(
    const device float2 *points [[buffer(0)]],
    constant float2 &viewport [[buffer(1)]],
    uint vertexID [[vertex_id]]
) {
    float2 point = points[vertexID];

    // Convert UIKit points to Metal clip coordinates
    float2 ndc = float2(
        (point.x / viewport.x) * 2.0 - 1.0,
        1.0 - (point.y / viewport.y) * 2.0
    );

    VertexOut out;
    out.position = float4(ndc, 0.0, 1.0);
    return out;
}

fragment float4 fragmentMain(
    constant float4 &color [[buffer(0)]]
) {
    return color;
}

