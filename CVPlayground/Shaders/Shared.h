//
//  Shared.h
//  CVPlayground
//
//  Created by Noah Pikielny on 4/12/22.
//

#ifndef Shared_h
#define Shared_h

// used to render the entire screen
constant float2 cornerVerts[] = {
    // top left
    float2(-1, -1),
    float2(-1,  1),
    float2( 1, 1),
    // bottom right
    float2(-1, -1),
    float2( 1,  1),
    float2( 1, -1),
};

struct VertOut {
    float4 position [[position]];
    float2 uv;
};

float2 uv(float2 coord, float2 size);

float2 uv (uint2 tid, texture2d<float> image);
float2 uv (uint2 tid, texture2d<float, access::write> image);

constexpr sampler sam(min_filter::nearest, mag_filter::nearest, mip_filter::none);
#endif /* Shared_h */
