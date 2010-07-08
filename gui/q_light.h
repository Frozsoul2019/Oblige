//------------------------------------------------------------------------
//  QUAKE 1/2 LIGHTING
//------------------------------------------------------------------------
//
//  Oblige Level Maker
//
//  Copyright (C) 2006-2010 Andrew Apted
//
//  This program is free software; you can redistribute it and/or
//  modify it under the terms of the GNU General Public License
//  as published by the Free Software Foundation; either version 2
//  of the License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//------------------------------------------------------------------------

#ifndef __QUAKE_LIGHTING_H__
#define __QUAKE_LIGHTING_H__


class qLightmap_c
{
private:
  int width, height;

  float *samples;

  // when size is 1x1, the sample is stored here
  float flat;

public:
  qLightmap_c(int w, int h, float value = -99);

  ~qLightmap_c();

  inline bool isFlat() const
  {
    return (width == 1) && (height == 1);
  }

  void Fill(float value);

  void Clamp();

  void GetRange(float *low, float *high, float *avg);

  void Add(double x, double y, float value);

  void Flatten(float avg = -99);
};


#endif /* __QUAKE_LIGHTING_H__ */

//--- editor settings ---
// vi:ts=2:sw=2:expandtab
