// Magic Software, Inc.
// http://www.magic-software.com
// http://www.wild-magic.com
// Copyright (c) 2004.  All Rights Reserved
//
// The Wild Magic Library (WM3) source code is supplied under the terms of
// the license agreement http://www.wild-magic.com/License/WildMagic3.pdf and
// may not be copied or disclosed except in accordance with the terms of that
// agreement.

#ifndef KEPLERPOLARFORM_H
#define KEPLERPOLARFORM_H

#include "Wm3WindowApplication2.h"
#include "PhysicsModule.h"
using namespace Wm3;

class KeplerPolarForm : public WindowApplication2
{
    WM3_DECLARE_INITIALIZE;

public:
    KeplerPolarForm ();

    virtual bool OnInitialize ();
    virtual void OnDisplay ();

protected:
    PhysicsModule m_kModule;
    std::vector<Vector2d> m_kPosition;
};

WM3_REGISTER_INITIALIZE(KeplerPolarForm);

#endif

