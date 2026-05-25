#include "NXVMath.h"

NXVVec3 NXVVec3Make(float x, float y, float z)
{
    NXVVec3 v;
    v.x = x;
    v.y = y;
    v.z = z;
    return v;
}

NXVVec3 NXVVec3Add(NXVVec3 a, NXVVec3 b)
{
    return NXVVec3Make(a.x + b.x, a.y + b.y, a.z + b.z);
}

NXVVec3 NXVVec3Sub(NXVVec3 a, NXVVec3 b)
{
    return NXVVec3Make(a.x - b.x, a.y - b.y, a.z - b.z);
}

NXVVec3 NXVVec3Scale(NXVVec3 v, float s)
{
    return NXVVec3Make(v.x * s, v.y * s, v.z * s);
}

float NXVVec3Length(NXVVec3 v)
{
    return sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
}

NXVVec3 NXVRotateX(NXVVec3 v, float angle)
{
    float c = cosf(angle);
    float s = sinf(angle);
    return NXVVec3Make(v.x, v.y * c - v.z * s, v.y * s + v.z * c);
}

NXVVec3 NXVRotateY(NXVVec3 v, float angle)
{
    float c = cosf(angle);
    float s = sinf(angle);
    return NXVVec3Make(v.x * c + v.z * s, v.y, -v.x * s + v.z * c);
}

NXVVec3 NXVRotateZ(NXVVec3 v, float angle)
{
    float c = cosf(angle);
    float s = sinf(angle);
    return NXVVec3Make(v.x * c - v.y * s, v.x * s + v.y * c, v.z);
}
