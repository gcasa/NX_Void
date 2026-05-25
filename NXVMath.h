#ifndef NXV_MATH_H
#define NXV_MATH_H

#include <math.h>

typedef struct {
    float x;
    float y;
    float z;
} NXVVec3;

typedef struct {
    float x;
    float y;
} NXVVec2;

NXVVec3 NXVVec3Make(float x, float y, float z);
NXVVec3 NXVVec3Add(NXVVec3 a, NXVVec3 b);
NXVVec3 NXVVec3Sub(NXVVec3 a, NXVVec3 b);
NXVVec3 NXVVec3Scale(NXVVec3 v, float s);
float NXVVec3Length(NXVVec3 v);
NXVVec3 NXVRotateX(NXVVec3 v, float angle);
NXVVec3 NXVRotateY(NXVVec3 v, float angle);
NXVVec3 NXVRotateZ(NXVVec3 v, float angle);

#endif
