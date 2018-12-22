// Magic Software, Inc.
// http://www.magic-software.com
// http://www.wild-magic.com
// Copyright (c) 2004.  All Rights Reserved
//
// The Wild Magic Library (WM3) source code is supplied under the terms of
// the license agreement http://www.wild-magic.com/License/WildMagic3.pdf and
// may not be copied or disclosed except in accordance with the terms of that
// agreement.

#ifndef WM3INTRRAY2BOX2_H
#define WM3INTRRAY2BOX2_H

#include "Wm3Intersector.h"
#include "Wm3Ray2.h"
#include "Wm3Box2.h"

namespace Wm3
{

template <class Real>
class WM3_ITEM IntrRay2Box2 : public Intersector<Real,Vector2<Real> >
{
public:
    IntrRay2Box2 (const Ray2<Real>& rkRay, const Box2<Real>& rkBox);

    // object access
    const Ray2<Real>& GetRay () const;
    const Box2<Real>& GetBox () const;

    // static intersection queries
    virtual bool Test ();
    virtual bool Find ();

    // the intersection set
    int GetQuantity () const;
    const Vector2<Real>& GetPoint (int i) const;

private:
    // the objects to intersect
    const Ray2<Real>& m_rkRay;
    const Box2<Real>& m_rkBox;

    // information about the intersection set
    int m_iQuantity;
    Vector2<Real> m_akPoint[2];
};

typedef IntrRay2Box2<float> IntrRay2Box2f;
typedef IntrRay2Box2<double> IntrRay2Box2d;

}

#endif