//
//  Shared.metal
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

#include <metal_stdlib>
using namespace metal;
#include "Shared.h"

float2 uv(float2 coord, float2 size) {
    return coord / size;
}

float2 uv (uint2 tid, texture2d<float> image) {
    return float2(tid)/float2(image.get_width(), image.get_height());
}

float2 uv (uint2 tid, texture2d<float, access::write> image) {
    return float2(tid)/float2(image.get_width(), image.get_height());
}

