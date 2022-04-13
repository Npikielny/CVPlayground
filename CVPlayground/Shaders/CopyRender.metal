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

