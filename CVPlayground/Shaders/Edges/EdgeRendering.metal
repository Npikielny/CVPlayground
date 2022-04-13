//
//  EdgeRendering.metal
//  CVPlayground
//
//  Created by Noah Pikielny on 4/13/22.
//

#include <metal_stdlib>
using namespace metal;
#include "../Shared.h"

fragment float4 verticalEdge(VertOut in [[stage_in]],
                             constant int & radius,
                             texture2d<float>unprocessedImage,
                             texture2d<float, access::write>image) {
    float v = 0.;
    float2 imSize = float2(unprocessedImage.get_width(), unprocessedImage.get_height());
    float2 convertedUV = float2(in.uv.x, 1 - in.uv.y);
    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            if (x == 0) {
                float4 color = unprocessedImage.sample(sam, convertedUV + float2(x, y) / imSize);
                v += length(color.xyz) / sqrt(3.);
            }
        }
    }
    float4 color = unprocessedImage.sample(sam, convertedUV);
    if (radius == 0) { return color; }
    float side = 2 * radius;
    return color * v / side / side;
}

