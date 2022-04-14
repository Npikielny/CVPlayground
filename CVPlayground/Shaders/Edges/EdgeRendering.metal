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
                             texture2d<float>image) {
    float v = 0.;
    float2 imSize = float2(image.get_width(), image.get_height());
    float2 convertedUV = float2(in.uv.x, 1 - in.uv.y);
    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            float weight;
            if (x == 0) { weight = 0; }
            else { weight = sign(float(x)); }
            v += length(image.sample(sam, convertedUV + float2(x, y) / imSize).xyz) / sqrt(3.) * weight;
        }
    }
    float side = 2 * radius;
    return (radius == 0) ? float4(float3(1), v) : float4(float3(v / side / side), 1);
}

fragment float4 horizontalEdge(VertOut in [[stage_in]],
                             constant int & radius,
                             texture2d<float>image) {
    float v = 0.;
    float2 imSize = float2(image.get_width(), image.get_height());
    float2 convertedUV = float2(in.uv.x, 1 - in.uv.y);
    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            float weight;
            if (y == 0) { weight = 0; }
            else { weight = sign(float(y)); }
            v += length(image.sample(sam, convertedUV + float2(x, y) / imSize).xyz) / sqrt(3.) * weight;
        }
    }
    float side = 2 * radius;
    return (radius == 0) ? float4(float3(1), v) : float4(float3(v / side / side), 1);
}

fragment float4 diagonalPositive(VertOut in [[stage_in]],
                             constant int & radius,
                             texture2d<float>image) {
    float v = 0.;
    float2 imSize = float2(image.get_width(), image.get_height());
    float2 convertedUV = float2(in.uv.x, 1 - in.uv.y);
    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            float weight;
            if (y == x) { weight = 0; }
            else { weight = (y > x) ? 1 : -1; }
            v += length(image.sample(sam, convertedUV + float2(x, y) / imSize).xyz) / sqrt(3.) * weight;
        }
    }
    float side = 2 * radius;
    return (radius == 0) ? float4(float3(1), v) : float4(float3(v / side / side), 1);
}

fragment float4 diagonalNegative(VertOut in [[stage_in]],
                             constant int & radius,
                             texture2d<float>image) {
    float v = 0.;
    float2 imSize = float2(image.get_width(), image.get_height());
    float2 convertedUV = float2(in.uv.x, 1 - in.uv.y);
    for (int x = -radius; x <= radius; x++) {
        for (int y = -radius; y <= radius; y++) {
            float weight;
            if (y == x) { weight = 0; }
            else { weight = (y > x) ? -1 : 1; }
            v += length(image.sample(sam, convertedUV + float2(x, y) / imSize).xyz) / sqrt(3.) * weight;
        }
    }
    float side = 2 * radius;
    return (radius == 0) ? float4(float3(1), v) : float4(float3(v / side / side), 1);
}

float4 max (float4 v1, float4 v2, float4 v3, float4 v4) {
    return max(max(v1, v2), max(v3, v4));
}

fragment float4 combine(VertOut in [[stage_in]],
                        texture2d<float>im1,
                        texture2d<float>im2,
                        texture2d<float>im3,
                        texture2d<float>im4,
                        texture2d<float>stonks) {
    
    float4 maxValue = max(im1.sample(sam, in.uv),
                                im2.sample(sam, in.uv),
                                im3.sample(sam, in.uv),
                                im4.sample(sam, in.uv));
    float certainty = length(maxValue.xyz) / sqrt(3.);
    return float4(float3(1) * certainty, 1);
}
