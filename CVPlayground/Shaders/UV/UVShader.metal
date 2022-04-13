//
//  UV.metal
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

#include <metal_stdlib>
using namespace metal;
#include "../Shared.h"

fragment float4 uvFragment(VertOut in [[stage_in]],
                             texture2d<float> image) {
    float4 color = float4(in.uv, 0, 1);
    return color;
}
