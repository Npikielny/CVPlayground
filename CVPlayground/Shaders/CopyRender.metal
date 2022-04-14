//
//  CopyRender.metal
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

#include <metal_stdlib>
using namespace metal;
#include "Shared.h"

vertex VertOut copyVertex(uint vid [[vertex_id]]) {
    float2 vert = cornerVerts[vid];
    
    VertOut out;
    out.position = float4(vert, 0, 1);
    out.uv = vert * 0.5 + 0.5;
    
    return out;
}

fragment float4 copyFragment(VertOut in [[stage_in]],
                             texture2d<float> image) {
    float4 color = image.sample(sam, in.uv);
    return color;
}

fragment float4 convolve(VertOut in [[stage_in]],
                         constant int & radius,
                         constant float * weights,
                         texture2d<float> image) {
    float4 v = 0.;
    float2 imSize = float2(image.get_width(), image.get_height());
    float2 convertedUV = float2(in.uv.x, 1 - in.uv.y);
    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            float weight = weights[x + y * (2 * radius + 1)];
            v += image.sample(sam, convertedUV + float2(x, y) / imSize) * weight;
        }
    }
    if (radius == 0) { return v; }
    float side = 2 * radius;
    return v / side / side;
}
