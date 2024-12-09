
// include the Metal standard library
#include <metal_stdlib>
using namespace metal;

// define all the colors to render
constant float3 colors[] = {
    
    // character (index: 0)
    float3(1.0f, 1.0f, 1.0f),
    
    // ground (index: 1)
    float3(0.05f, 0.05f, 0.05f),
    
    // structure (index: 2)
    float3(0.15f, 0.15f, 0.15f),
    
    // billboard (index: 3 - 22)
    float3(0.0f, 1.0f, 0.623f),
    float3(0.0f, 0.9f, 0.7f),
    float3(0.0f, 1.0f, 0.55f),
    float3(0.1f, 1.0f, 0.7f),
    float3(0.0f, 0.721f, 1.0f),
    float3(0.0f, 0.8f, 1.0f),
    float3(0.1f, 0.7f, 1.0f),
    float3(0.0f, 0.75f, 0.9f),
    float3(0.0f, 0.118f, 1.0f),
    float3(0.0f, 0.1f, 1.0f),
    float3(0.0f, 0.15f, 1.0f),
    float3(0.0f, 0.12f, 0.9f),
    float3(0.741f, 0.0f, 1.0f),
    float3(0.7f, 0.0f, 1.0f),
    float3(0.8f, 0.0f, 1.0f),
    float3(0.75f, 0.0f, 0.95f),
    float3(0.839f, 0.0f, 0.9f),
    float3(0.85f, 0.0f, 0.9f),
    float3(0.8f, 0.0f, 0.9f),
    float3(0.85f, 0.0f, 0.85f),
    
    // apartment (index: 23 - 28)
    float3(0.518f, 0.125f, 0.125f),
    float3(0.530f, 0.135f, 0.135f),
    float3(0.505f, 0.115f, 0.115f),
    float3(0.505f, 0.125f, 0.145f),
    float3(0.518f, 0.115f, 0.135f),
    float3(0.528f, 0.125f, 0.145f),
    
    // bed (index: 29 - 33)
    float3(0.050f, 0.060f, 0.020f),
    float3(0.030f, 0.040f, 0.010f),
    float3(0.070f, 0.080f, 0.020f),
    float3(0.040f, 0.050f, 0.015f),
    float3(0.020f, 0.030f, 0.005f),
    
    // pillow (index: 34)
    float3(0.839f, 0.776f, 0.694f),
    
    // office (index: 35 - 40)
    float3(1.0f, 0.5f, 0.0f),
    float3(1.0f, 0.45f, 0.0f),
    float3(1.0f, 0.55f, 0.0f),
    float3(0.95f, 0.5f, 0.0f),
    float3(0.95f, 0.55f, 0.05f),
    float3(1.0f, 0.5f, 0.05f),
    
    // office desk (index: 41)
    float3(0.4f, 0.1f, 0.0f),
    
    // office chair (index: 42)
    float3(0.02f, 0.02f, 0.02f),
    
    // gym (index: 43 - 47)
    float3(0.3f, 0.5f, 0.8f),
    float3(0.32f, 0.52f, 0.82f),
    float3(0.28f, 0.48f, 0.78f),
    float3(0.34f, 0.54f, 0.84f),
    float3(0.29f, 0.49f, 0.77f),
    
    // treadmills (index: 48 - 50)
    float3(0.02f, 0.02f, 0.02f),
    float3(0.2f, 0.2f, 0.2f),
    float3(0.4f, 0.4f, 0.4f),
    
    // library (index: 51 - 53)
    float3(0.92f, 0.41f, 0.55f),
    float3(0.84f, 0.36f, 0.57f),
    float3(0.75f, 0.32f, 0.60f),
    
    // bookshelves (index: 54)
    float3(0.51f, 0.18f, 0.69f),
    
    // desk (index: 55)
    float3(0.59f, 0.23f, 0.66f),
    
    // seats (index: 56)
    float3(0.67f, 0.27f, 0.63f),
    
    // fire (index: 57)
    float3(1.0f, 0.0f, 0.0f),
    
    // restaurant (index: 58 - 62)
    float3(0.42f, 0.56f, 0.14f),
    float3(0.43f, 0.58f, 0.15f),
    float3(0.40f, 0.54f, 0.12f),
    float3(0.45f, 0.57f, 0.16f),
    float3(0.41f, 0.55f, 0.13f),
    
    // restaurant furniture (index: 63 - 64)
    float3(0.60f, 0.58f, 0.55f),
    float3(0.80f, 0.75f, 0.70f),
    
    // bar (index: 65 - 69)
    float3(0.45f, 0.25f, 0.15f),
    float3(0.48f, 0.25f, 0.15f),
    float3(0.42f, 0.20f, 0.12f),
    float3(0.45f, 0.30f, 0.20f),
    float3(0.42f, 0.25f, 0.15f),
    
    // bar furniture (index: 70 - 71)
    float3(0.80f, 0.60f, 0.40f),
    float3(0.54f, 0.35f, 0.22f),
    
    // redemption building (index: 72 - 79)
    float3(0.45f, 0.25f, 0.15f),
    float3(0.02f, 0.005f, 0.00f),
    float3(1.00f, 0.90f, 0.78f),
    float3(0.25f, 0.27f, 0.26f),
    float3(0.03f, 0.03f, 0.03f),
    float3(0.07f, 0.20f, 0.34f),
    float3(0.03f, 0.09f, 0.24f),
    float3(0.80f, 0.80f, 0.80f),
    
    // twilight (80 - 81)
    float3(0.64f, 0.84f, 0.98f),
    float3(0.99f, 0.95f, 0.0f),
    
    // morning (82 - 83)
    float3(0.28f, 0.79f, 0.89f),
    float3(0.79f, 0.94f, 0.97f),
    
    // sunset (84 - 85)
    float3(1.0f, 0.73f, 0.03f),
    float3(0.82f, 0.0f, 0.0f),
    
    // night (86 - 87)
    float3(0.0f, 0.03f, 0.08f),
    float3(0.0f, 0.11f, 0.24f),
    
    // sun (88)
    float3(255, 250, 229) / 255.0f,
    
    // moon (89)
    float3(255, 233, 127) / 255.0f,
};

// define the visible character data
struct VisibleCharacterData {
    
    // define the general visible character data
    //  - data.x = sex
    //  - data.w = character node index
    uint4 data;
    
    // define the personalities of the character
    float4 personalities;
    
    // define the indices of the female mesh nodes
    uint4 femaleMeshNodeIndices;
    
    // define the indices of the male mesh nodes
    uint4 maleMeshNodeIndices;
    
    // define the transform of the visible character
    float4x4 transform;
    
    // define the motion controller indices
    int motionControllerIndices[30];
    
    // define the motion controllers
    float4x2 motionControllers[30];
};

// define the node data
struct NodeData {
    int4 node;
    float4x4 matrix;
};

// define the motion controller data
struct MotionControllerData {
    float4x2 controller;
};

// define the camera data
struct CameraData {
    int4 camera;
    float4x4 matrices[3];
    float4 frustums[6];
};

// define the present intermediate data
struct PresentIntermediateData {
    float4 point [[position]];
    float2 coordinate;
};

// define a sphere
struct Sphere {
    float3 center;
    float radius;
};

// define a ray
struct Ray {
    float3 origin;
    float3 direction;
};

// define the function that update the nodes based on the visible characters
kernel void UpdateFunction(device VisibleCharacterData* characters [[buffer(0)]],
                           device NodeData* nodes [[buffer(1)]],
                           device MotionControllerData* controllers [[buffer(2)]],
                           constant float& time [[buffer(3)]],
                           constant uint& workload [[buffer(4)]],
                           const uint index [[thread_position_in_grid]]) {
    
    // avoid execution when the index exceeds the total number of characters
    if (index >= workload) {
        return;
    }
    
    // acquire the current character
    VisibleCharacterData character = characters[index];
    
    // update the character mesh based on the character sex
    nodes[character.femaleMeshNodeIndices.x].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.femaleMeshNodeIndices.y].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.femaleMeshNodeIndices.z].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.femaleMeshNodeIndices.w].node.w = character.data.x == 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.x].node.w = character.data.x != 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.y].node.w = character.data.x != 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.z].node.w = character.data.x != 0 ? character.data.w : -1;
    nodes[character.maleMeshNodeIndices.w].node.w = character.data.x != 0 ? character.data.w : -1;
    
    // compute the color index
    const uint x = uint((character.personalities.x * 0.5f + 0.5f) * 39.0f);
    const uint y = uint((character.personalities.y * 0.5f + 0.5f) * 39.0f);
    const uint z = uint((character.personalities.z * 0.5f + 0.5f) * 39.0f);
    const uint colorIndex = x + y * 40 + z * 40 * 40 + 1000;
    
    // update the character mesh color
    nodes[character.femaleMeshNodeIndices.x].node.z = colorIndex;
    nodes[character.femaleMeshNodeIndices.y].node.z = colorIndex;
    nodes[character.femaleMeshNodeIndices.z].node.z = colorIndex;
    nodes[character.femaleMeshNodeIndices.w].node.z = colorIndex;
    nodes[character.maleMeshNodeIndices.x].node.z = colorIndex;
    nodes[character.maleMeshNodeIndices.y].node.z = colorIndex;
    nodes[character.maleMeshNodeIndices.z].node.z = colorIndex;
    nodes[character.maleMeshNodeIndices.w].node.z = colorIndex;
    
    // update the character node
    nodes[character.data.w].matrix = character.transform;
    
    // update the motions
    for (int i = 0; i < 30; i += 1) {
        const int motionControllerIndex = character.motionControllerIndices[i];
        if (motionControllerIndex > -1) {
            controllers[motionControllerIndex].controller = character.motionControllers[i];
        }
    }
}

float3 hash(float3 p) {
    p = float3(dot(p, float3(127.1f, 311.7f, 74.7f)),
               dot(p, float3(269.5f, 183.3f, 246.1f)),
               dot(p, float3(113.5f, 271.9f, 124.6f)));
    return -1.0f + 2.0f * fract(sin(p) * 43758.5453123f);
}

float noise(const float3 p) {
    const float3 i = floor(p);
    const float3 f = fract(p);
    const float3 u = f * f * (3.0f - 2.0f * f);
    return mix(mix(mix(dot(hash(i + float3(0.0f, 0.0f, 0.0f)), f - float3(0.0f, 0.0f, 0.0f)),
                       dot(hash(i + float3(1.0f, 0.0f, 0.0f)), f - float3(1.0f, 0.0f, 0.0f)), u.x),
                    mix(dot(hash(i + float3(0.0f, 1.0f, 0.0f)), f - float3(0.0f, 1.0f, 0.0f)),
                        dot(hash(i + float3(1.0f, 1.0f, 0.0f)), f - float3(1.0f, 1.0f, 0.0f)), u.x), u.y),
               mix(mix(dot(hash(i + float3(0.0f, 0.0f, 1.0f)), f - float3(0.0f, 0.0f, 1.0f)),
                        dot(hash(i + float3(1.0f, 0.0f, 1.0f)), f - float3(1.0f, 0.0f, 1.0f)), u.x),
                   mix(dot(hash(i + float3(0.0f, 1.0f, 1.0f)), f - float3(0.0f, 1.0f, 1.0f)),
                       dot(hash(i + float3(1.0f, 1.0f, 1.0f)), f - float3(1.0f, 1.0f, 1.0f)), u.x), u.y), u.z);
}

float2 moveInEllipse(const float t, const float a, const float b) {
    const float x = a * cos(t);
    const float y = b * sin(t);
    return float2(x, y);
}

// Function to calculate ray-sphere intersection
// Returns the distance to the closest intersection or -1 if no intersection
float raySphereIntersection(const Ray ray, const Sphere sphere) {
    float3 oc = ray.origin - sphere.center;
    float a = dot(ray.direction, ray.direction);
    float b = 2.0 * dot(oc, ray.direction);
    float c = dot(oc, oc) - sphere.radius * sphere.radius;
    float discriminant = b * b - 4.0 * a * c;

    if (discriminant < 0.0) {
        return -1.0;
    } else {
        float t1 = (-b - sqrt(discriminant)) / (2.0 * a);
        float t2 = (-b + sqrt(discriminant)) / (2.0 * a);

        // Return the closest positive intersection
        if (t1 > 0.0 && t2 > 0.0) {
            return min(t1, t2);
        } else if (t1 > 0.0) {
            return t1;
        } else if (t2 > 0.0) {
            return t2;
        } else {
            return -1.0; // Both intersections are behind the ray
        }
    }
}

float3 getSkyColor(float sunAngle, const float3 skyColors[4], const float transitionAngles[4]) {
    float3 result = float3(0.0f);
    int startIndex = -1;
    float t = 0.0f;
    
    // Determine which segment the sunAngle falls into
    if (sunAngle >= transitionAngles[0] && sunAngle < transitionAngles[1]) {
        startIndex = 0;
        t = (sunAngle - transitionAngles[0]) / (transitionAngles[1] - transitionAngles[0]);
    } else if (sunAngle >= transitionAngles[1] && sunAngle < transitionAngles[2]) {
        startIndex = 1;
        t = (sunAngle - transitionAngles[1]) / (transitionAngles[2] - transitionAngles[1]);
    } else if (sunAngle >= transitionAngles[2] && sunAngle <= M_PI_F) {
        startIndex = 2;
        t = (sunAngle - transitionAngles[2]) / (M_PI_F - transitionAngles[2]);
    } else if (sunAngle >= transitionAngles[3] && sunAngle < transitionAngles[0]) {
        startIndex = 3;
        t = (sunAngle - transitionAngles[3]) / (transitionAngles[0] - transitionAngles[3]);
    }
    if (startIndex != -1) {
        result = skyColors[startIndex] + t * (skyColors[(startIndex + 1) % 4] - skyColors[startIndex]);
    } else {
        result = skyColors[3];
    }
    return result;
}

// define the present fragment function
fragment float4 PresentFragmentFunction(const PresentIntermediateData data [[stage_in]],
                                        const device CameraData* cameras [[buffer(0)]],
                                        constant float& time [[buffer(1)]],
                                        const texture2d<float> color [[texture(0)]],
                                        const texture2d<float> depth [[texture(1)]]) {
    
    // compute the fragment world position
    const CameraData camera = cameras[0];
    const float4 buffer = color.sample(sampler(filter::nearest), data.coordinate);
    const uint b = as_type<uint>(buffer.b);
    const float normal0 = float(b & 255) / 255.0f;
    const float normal1 = float((b >> 8) & 255) / 255.0f;
    const float normal2 = float((b >> 16) & 255) / 255.0;
    const float3 normal = float3(normal0, normal1, normal2) * 2.0f - 1.0f;
    const float r = depth.sample(sampler(filter::nearest), data.coordinate).r;
    float4 point = float4(data.coordinate.x * 2.0f - 1.0f, 1.0f - data.coordinate.y * 2.0f, r, 1.0f);
    point = camera.matrices[1] * point;
    point /= point.w;
    point = camera.matrices[2] * point;
    
    // acquire the material color
    const uint a = as_type<uint>(buffer.a);
    const uint material = (a >> 16) & 65535;
    float3 materialColor;
    if (material >= 1000) {
        uint colorIndex = material - 1000;
        const uint z = colorIndex / (40 * 40);
        colorIndex %= (40 * 40);
        const uint y = colorIndex / 40;
        const uint x = colorIndex % 40;
        materialColor.x = float(x) / 39.0f;
        materialColor.y = float(y) / 39.0f;
        materialColor.z = float(z) / 39.0f;
    } else {
        materialColor = colors[material];
    }
    
    // perform shading
    const float timeScale = 0.05f;
    const float2 bodyCoordinates = moveInEllipse(time * timeScale, 1000.0f, 1000.0f);
    const float4 bodyPositions = float4(bodyCoordinates.x, bodyCoordinates.y, -bodyCoordinates.x, -bodyCoordinates.y);
    const float3 skyColors[4] = {
        mix(mix(colors[80], colors[81], data.coordinate.y), float3(0.0f), 0.8f),
        mix(colors[82], colors[83], data.coordinate.y),
        mix(mix(colors[84], colors[85], data.coordinate.y), float3(0.0f), 0.5f),
        mix(mix(colors[86], colors[87], data.coordinate.y), float3(0.0f), 0.6f),
    };
    const float transitionAngles[4] = {0.0f, 0.5f, 2.84f, -0.1f};
    const float sunAngle = atan2(bodyCoordinates.y, bodyCoordinates.x);
    const float3 view = normalize(camera.matrices[2][3].xyz - point.xyz);
    float4 outColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
    Ray ray;
    ray.origin = camera.matrices[2][3].xyz;
    ray.direction = normalize(point.xyz - ray.origin);
    Sphere sun;
    sun.center = float3(bodyPositions.xy, 0.0f);
    sun.radius = 40.0f;
    Sphere moon;
    moon.center = float3(bodyPositions.zw, 0.0f);
    moon.radius = 30.0f;
    if (raySphereIntersection(ray, sun) != -1.0f) {
        outColor.xyz = colors[88];
    } else if (raySphereIntersection(ray, moon) != -1.0f) {
        outColor.xyz = colors[89];
    } else {
        outColor = float4(getSkyColor(sunAngle, skyColors, transitionAngles), 1.0f);
        const float starThreshold = 8.0f;
        const float starExposure = (1.0f - (normalize(bodyCoordinates).y * 0.5f + 0.5f)) * 200.0f;
        float starColors = pow(clamp(noise(view * 200.0f), 0.0f, 1.0f), starThreshold) * starExposure;
        starColors *= mix(0.4f, 1.4f, noise(view * 100.0f + float3(time)));
        outColor += starColors;
    }
    if (r < 1.0f) {
        const float3 light = normalize(float3(bodyPositions.xy, 0.0f) - point.xyz);
        float lambert = max(dot(normal, light), 0.0f) * 0.8f + max(dot(normal, view), 0.0f) * 0.2f;
        lambert *= (3 <= material && material <= 22) ? 10.0f : 1.0f;
        const float fog = 1.0f - smoothstep(400.0f, 450.0f, length(camera.matrices[2][3].xyz - point.xyz));
        outColor.xyz = mix(outColor.xyz, float3(lambert * 0.8f + 0.2f) * materialColor, fog);
    }
    return outColor;
}
