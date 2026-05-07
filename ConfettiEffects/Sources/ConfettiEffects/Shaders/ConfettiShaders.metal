//
//  ConfettiShaders.metal
//  ConfettiEffects
//
//  Created by Lionel Ng on 5/5/26.
//

#include <metal_stdlib>
using namespace metal;

struct ConfettiVertex {
    float2 position;
};

struct ConfettiInstance {
    float2 position;
    float2 size;
    float rotation;
    float alpha;
    float4 color;
    uint shape;
};

struct Uniforms {
    float2 viewportSize;
};

struct GPUConfettiParticle {
    float2 position;
    float2 velocity;
    float2 size;
    float rotation;
    float angularVelocity;
    float4 color;
    float age;
    float lifetime;
    float drag;
    uint shape;
    float isActive;
};

struct ComputeUniforms {
    float deltaTime;
    float gravity;
    uint particleCount;
    uint padding;
};

struct VertexOut {
    float4 position [[position]];
    float4 color;
    float2 localPosition;
    float opacity;
    uint shape;
};

float confettiOpacity(float age, float lifetime) {
    const float fadeStart = 0.72;
    const float progress = clamp(age / lifetime, 0.0, 1.0);
    
    if (progress <= fadeStart) {
        return 1.0;
    }
    
    const float normalizedFade = (progress - fadeStart) / (1.0 - fadeStart);
    const float easedFade = normalizedFade * normalizedFade * (3.0 - (2.0 * normalizedFade));
    return max(0.0, 1.0 - easedFade);
}

vertex VertexOut confettiVertex(
    uint vertexID [[vertex_id]],
    uint instanceID [[instance_id]],
    constant ConfettiVertex *vertices [[buffer(0)]],
    constant ConfettiInstance *instances [[buffer(1)]],
    constant Uniforms &uniforms [[buffer(2)]]
) {
    const ConfettiVertex quadVertex = vertices[vertexID];
    const ConfettiInstance instance = instances[instanceID];
    const float s = sin(instance.rotation);
    const float c = cos(instance.rotation);
    const float2 scaled = quadVertex.position * instance.size;
    const float2 rotated = float2(
        (scaled.x * c) - (scaled.y * s),
        (scaled.x * s) + (scaled.y * c)
    );
    const float2 worldPosition = instance.position + rotated;
    
    float2 clipPosition = (worldPosition / uniforms.viewportSize) * 2.0 - 1.0;
    clipPosition.y *= -1.0;
    
    VertexOut out;
    out.position = float4(clipPosition, 0.0, 1.0);
    out.color = instance.color;
    out.localPosition = quadVertex.position * 2.0;
    out.opacity = instance.alpha;
    out.shape = instance.shape;
    return out;
}

fragment float4 confettiFragment(VertexOut in [[stage_in]]) {
    float edgeAlpha = 1.0;
    
    if (in.shape == 0) {
        float distanceToCenter = length(in.localPosition);
        edgeAlpha = 1.0 - smoothstep(0.9, 1.0, distanceToCenter);
    } else if (in.shape == 1) {
        float edgeDistance = max(abs(in.localPosition.x), abs(in.localPosition.y));
        edgeAlpha = 1.0 - smoothstep(0.92, 1.0, edgeDistance);
    } else if (in.shape == 2) {
        float2 q = abs(in.localPosition) - float2(0.7, 0.7);
        float roundedDistance = length(max(q, float2(0.0))) + min(max(q.x, q.y), 0.0) - 0.3;
        edgeAlpha = 1.0 - smoothstep(-0.06, 0.02, roundedDistance);
    }
    
    if (edgeAlpha <= 0.001 || in.opacity <= 0.001) {
        discard_fragment();
    }
    
    return float4(in.color.rgb, in.color.a * in.opacity * edgeAlpha);
}

kernel void confettiUpdateParticles(
    device GPUConfettiParticle *particles [[buffer(0)]],
    device ConfettiInstance *instances [[buffer(1)]],
    constant ComputeUniforms &uniforms [[buffer(2)]],
    uint id [[thread_position_in_grid]]
) {
    if (id >= uniforms.particleCount) {
        return;
    }
    
    GPUConfettiParticle particle = particles[id];
    if (particle.isActive < 0.5) {
        instances[id].position = particle.position;
        instances[id].size = particle.size;
        instances[id].rotation = particle.rotation;
        instances[id].alpha = 0.0;
        instances[id].color = particle.color;
        instances[id].shape = particle.shape;
        return;
    }
    
    particle.age += uniforms.deltaTime;
    if (particle.age >= particle.lifetime) {
        particle.age = particle.lifetime;
        particle.isActive = 0.0;
        particles[id] = particle;
        
        instances[id].position = particle.position;
        instances[id].size = particle.size;
        instances[id].rotation = particle.rotation;
        instances[id].alpha = 0.0;
        instances[id].color = particle.color;
        instances[id].shape = particle.shape;
        return;
    }
    
    particle.velocity.y += uniforms.gravity * uniforms.deltaTime;
    const float dragFactor = max(0.72, 1.0 - (particle.drag * uniforms.deltaTime));
    particle.velocity *= dragFactor;
    particle.position += particle.velocity * uniforms.deltaTime;
    particle.rotation += particle.angularVelocity * uniforms.deltaTime;
    particles[id] = particle;
    
    instances[id].position = particle.position;
    instances[id].size = particle.size;
    instances[id].rotation = particle.rotation;
    instances[id].alpha = confettiOpacity(particle.age, particle.lifetime);
    instances[id].color = particle.color;
    instances[id].shape = particle.shape;
}
