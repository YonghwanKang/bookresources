#ifndef __MTH_ANGLE_DEF_H__
#define __MTH_ANGLE_DEF_H__
//----------------------------------------------------------------------------
//
//mth_angle.h
//
//Copyright � Rishi Ramraj, 2004
//Standard trig angle definitions
//----------------------------------------------------------------------------

//��������������������������������������������������������������������������//
//    header :: Inclusions
//��������������������������������������������������������������������������//

//��������������������������������������������������������������������������//
//    header :: Definitions
//��������������������������������������������������������������������������//

#define MTH_360 360
#define MTH_180 180
#define MTH_PI 3.141593f
#define MTH_TWO_PI 6.283186f
#define MTH_D_TO_R 0.0174533f
#define MTH_R_TO_D 57.2957732f

//��������������������������������������������������������������������������//
//    header :: Structures
//��������������������������������������������������������������������������//

//��������������������������������������������������������������������������//
//    header :: Class Defs
//��������������������������������������������������������������������������//

//��������������������������������������������������������������������������//
//    header :: Function Defs
//��������������������������������������������������������������������������//

//reduces between 0 and pi or 0 and 360
float mth_reduce_deg(float deg);
float mth_reduce_rad(float rad);

//----------------------------------------------------------------------------
//mth_angle.h
//Copyright � Rishi Ramraj, 2004
//----------------------------------------------------------------------------
#endif //__MTH_ANGLE_DEF_H__