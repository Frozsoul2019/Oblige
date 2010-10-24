----------------------------------------------------------------
--  WINDOW and FENCE PREFABS
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2010 Andrew Apted
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
----------------------------------------------------------------
--
--  Window and Fence prefabs are relative (in Z coord) to
--  the highest floor on either side.
--
----------------------------------------------------------------

PREFAB.WINDOW =
{
  placement = "fitted",

  x_sizes = { {64,1}, {64,4}, {64,1} },

  defaults =
  {
    track = "?wall",
  },

  brushes =
  {
    -- right side
    {
      { x =  0, y =  0, mat = "?outer" },
      { x = 64, y =  0, mat = "?track" },
      { x = 64, y = 32, mat = "?wall" },
      { x =  0, y = 32, mat = "?wall" },
    },

    -- left side
    {
      { x = 128, y =  0, mat = "?outer" },
      { x = 192, y =  0, mat = "?wall" },
      { x = 192, y = 32, mat = "?wall" },
      { x = 128, y = 32, mat = "?track" },
    },

    -- bottom
    {
      { x =  64, y =  0, mat = "?outer" },
      { x = 128, y =  0, mat = "?wall" },
      { x = 128, y = 32, mat = "?wall" },
      { x =  64, y = 32, mat = "?wall" },
      { t = 0, mat = "?outer" },
    },

    -- top
    {
      { x =  64, y =  0, mat = "?outer" },
      { x = 128, y =  0, mat = "?wall" },
      { x = 128, y = 32, mat = "?wall" },
      { x =  64, y = 32, mat = "?wall" },
      { b = 64, mat = "?outer" },
    },
  },
}


PREFAB.WINDOW_W_BARS =
{
  placement = "fitted",

  x_sizes = { {64,1}, {64,2}, {64,1} },

  repeat_width = 256,

  defaults =
  {
    track = "?wall",
  },

  brushes =
  {
    -- right side
    {
      { x =  0, y =  0, mat = "?outer" },
      { x = 64, y =  0, mat = "?track" },
      { x = 64, y = 32, mat = "?wall" },
      { x =  0, y = 32, mat = "?wall" },
    },

    -- left side
    {
      { x = 128, y =  0, mat = "?outer" },
      { x = 192, y =  0, mat = "?wall" },
      { x = 192, y = 32, mat = "?wall" },
      { x = 128, y = 32, mat = "?track" },
    },

    -- bottom
    {
      { x =  64, y =  0, mat = "?outer" },
      { x = 128, y =  0, mat = "?wall" },
      { x = 128, y = 32, mat = "?wall" },
      { x =  64, y = 32, mat = "?wall" },
      { t = 0, mat = "?outer" },
    },

    -- top
    {
      { x =  64, y =  0, mat = "?outer" },
      { x = 128, y =  0, mat = "?wall" },
      { x = 128, y = 32, mat = "?wall" },
      { x =  64, y = 32, mat = "?wall" },
      { b = 96, mat = "?outer" },
    },

    -- bars
    {
      { x =  94, y = 12, mat = "?frame" },
      { x =  98, y = 12, mat = "?frame" },
      { x =  98, y = 20, mat = "?frame" },
      { x =  94, y = 20, mat = "?frame" },
    },
    {
      { x =  76, y = 12, mat = "?frame" },
      { x =  80, y = 12, mat = "?frame" },
      { x =  80, y = 20, mat = "?frame" },
      { x =  76, y = 20, mat = "?frame" },
    },
    {
      { x = 112, y = 12, mat = "?frame" },
      { x = 116, y = 12, mat = "?frame" },
      { x = 116, y = 20, mat = "?frame" },
      { x = 112, y = 20, mat = "?frame" },
    },
  },
}


PREFAB.WINDOW_W_CROSS =
{
  placement = "fitted",

  x_sizes = { {64,1}, {64,1}, {64,1} },

  repeat_width = 256,

  defaults =
  {
    track = "?wall",
  },

  brushes =
  {
    -- right side
    {
      { x =  0, y =  0, mat = "?outer" },
      { x = 64, y =  0, mat = "?track" },
      { x = 64, y = 32, mat = "?wall" },
      { x =  0, y = 32, mat = "?wall" },
    },

    -- left side
    {
      { x = 128, y =  0, mat = "?outer" },
      { x = 192, y =  0, mat = "?wall" },
      { x = 192, y = 32, mat = "?wall" },
      { x = 128, y = 32, mat = "?track" },
    },

    -- bottom
    {
      { x =  64, y =  0, mat = "?outer" },
      { x = 128, y =  0, mat = "?wall" },
      { x = 128, y = 32, mat = "?wall" },
      { x =  64, y = 32, mat = "?wall" },
      { t = 0, mat = "?outer" },
    },

    -- top
    {
      { x =  64, y =  0, mat = "?outer" },
      { x = 128, y =  0, mat = "?wall" },
      { x = 128, y = 32, mat = "?wall" },
      { x =  64, y = 32, mat = "?wall" },
      { b = 128, mat = "?outer" },
    },

    -- cross
    {
      { x =  92, y = 12, mat = "?frame" },
      { x = 100, y = 12, mat = "?frame" },
      { x = 100, y = 20, mat = "?frame" },
      { x =  92, y = 20, mat = "?frame" },
    },
    {
      { x =  64, y = 12, mat = "?frame" },
      { x = 128, y = 12, mat = "?frame" },
      { x = 128, y = 20, mat = "?frame" },
      { x =  64, y = 20, mat = "?frame" },
      { b =  60, mat = "?frame" },
      { t =  68, mat = "?frame" },
    },
  },
}


PREFAB.QUAKE_WINDOW =
{
  placement = "fitted",

  x_sizes = { {64,1}, {64,1}, {64,1} },

  repeat_width = 192,

  brushes =
  {
    -- right side
    {
      { x =  0, y =  8, mat = "?outer" },
      { x = 56, y =  8, mat = "?wall" },
      { x = 56, y = 24, mat = "?wall" },
      { x =  0, y = 24, mat = "?wall" },
    },

    -- left side
    {
      { x = 136, y =  8, mat = "?outer" },
      { x = 192, y =  8, mat = "?wall" },
      { x = 192, y = 24, mat = "?wall" },
      { x = 132, y = 24, mat = "?wall" },
    },

    -- bottom
    {
      { x =  56, y =  8, mat = "?outer" },
      { x = 136, y =  8, mat = "?wall" },
      { x = 136, y = 24, mat = "?wall" },
      { x =  56, y = 24, mat = "?wall" },
      { t = 0, mat = "?outer" },
    },

    -- top
    {
      { x =  56, y =  8, mat = "?outer" },
      { x = 136, y =  8, mat = "?wall" },
      { x = 136, y = 24, mat = "?wall" },
      { x =  56, y = 24, mat = "?wall" },
      { b = 128, mat = "?outer" },
    },

    ---- 3D frame ----

    -- left
    {
      { x =  56, y =  0, mat = "?frame" },
      { x =  64, y =  0, mat = "?frame" },
      { x =  64, y = 32, mat = "?frame" },
      { x =  56, y = 32, mat = "?frame" },
      { b =   0, mat = "?frame" },
      { t = 128, mat = "?frame" },
    },

    -- right
    {
      { x = 128, y =  0, mat = "?frame" },
      { x = 136, y =  0, mat = "?frame" },
      { x = 136, y = 32, mat = "?frame" },
      { x = 128, y = 32, mat = "?frame" },
      { b =   0, mat = "?frame" },
      { t = 128, mat = "?frame" },
    },

    -- top
    {
      { x =  64, y =  0, mat = "?frame" },
      { x = 128, y =  0, mat = "?frame" },
      { x = 128, y = 32, mat = "?frame" },
      { x =  64, y = 32, mat = "?frame" },
      { b = 120, mat = "?frame" },
      { t = 128, mat = "?frame" },
    },

    -- bottom
    {
      { x =  64, y =  0, mat = "?frame" },
      { x = 128, y =  0, mat = "?frame" },
      { x = 128, y = 32, mat = "?frame" },
      { x =  64, y = 32, mat = "?frame" },
      { b = 0, mat = "?frame" },
      { t = 8, mat = "?frame" },
    },
  },
}


PREFAB.FENCE =
{
  placement = "fitted",

  brushes =
  {
    {
      { x =   0, y =  0, mat = "?fence" },
      { x = 192, y =  0, mat = "?fence" },
      { x = 192, y = 32, mat = "?fence" },
      { x =   0, y = 32, mat = "?fence" },
      { t = 32, mat = "?fence" },
    },
  },
}


PREFAB.FENCE_W_GAP =
{
  placement = "fitted",

  x_sizes = { {80,1}, {32,0}, {80,1} },

  repeat_width = 192,

  brushes =
  {
    {
      { x =   0, y =  0, mat = "?fence" },
      { x =  80, y =  0, mat = "?fence" },
      { x =  80, y = 32, mat = "?fence" },
      { x =   0, y = 32, mat = "?fence" },
      { t = 32, mat = "?fence" },
    },

    {
      { x =  80, y =  8, mat = "?metal", blocked=1 },
      { x = 112, y =  8, mat = "?metal", blocked=1 },
      { x = 112, y = 24, mat = "?metal", blocked=1 },
      { x =  80, y = 24, mat = "?metal", blocked=1 },
      { t = 16, mat = "?metal" },
    },

    {
      { x = 112, y =  0, mat = "?fence" },
      { x = 192, y =  0, mat = "?fence" },
      { x = 192, y = 32, mat = "?fence" },
      { x = 112, y = 32, mat = "?fence" },
      { t = 32, mat = "?fence" },
    },
  },
}


PREFAB.FENCE_W_BOLLARD =
{
  placement = "fitted",

  x_sizes = { {56,1}, {16,0}, {56,1} },
  y_sizes = { {8,0},  {16,1}, {8,0}  },

  repeat_width = 128,

  brushes =
  {
    {
      { x =   0, y =  8, mat = "?fence" },
      { x =  56, y =  8, mat = "?fence" },
      { x =  56, y = 24, mat = "?fence" },
      { x =   0, y = 24, mat = "?fence" },
      { t = 32, mat = "?fence" },
    },

    {
      { x =  56, y =  0, mat = "?metal" },
      { x =  72, y =  0, mat = "?metal" },
      { x =  72, y = 32, mat = "?metal" },
      { x =  56, y = 32, mat = "?metal" },
      { t = 48, mat = "?metal" },
    },

    {
      { x =  72, y =  8, mat = "?fence" },
      { x = 128, y =  8, mat = "?fence" },
      { x = 128, y = 24, mat = "?fence" },
      { x =  72, y = 24, mat = "?fence" },
      { t = 32, mat = "?fence" },
    },
  },
}



PREFAB.FENCE_W_INSET =
{
  placement = "fitted",

  x_sizes = { {16,0}, {96,1}, {16,0} },
  y_sizes = { {12,1}, { 8,0}, {12,1} },

  repeat_width = 128,

  brushes =
  {
    {
      { x =   0, y =  0, mat = "?fence" },
      { x =  16, y =  0, mat = "?fence" },
      { x =  16, y = 32, mat = "?fence" },
      { x =   0, y = 32, mat = "?fence" },
      { t = 72, mat = "?fence" },
    },

    {
      { x =  16, y =  0, mat = "?fence" },
      { x = 112, y =  0, mat = "?fence" },
      { x = 112, y = 32, mat = "?fence" },
      { x =  16, y = 32, mat = "?fence" },
      { t = 8, mat = "?fence" },
    },

    {
      { x =  16, y = 12, mat = "?metal" },
      { x = 112, y = 12, mat = "?metal" },
      { x = 112, y = 20, mat = "?metal" },
      { x =  16, y = 20, mat = "?metal" },
      { t = 48, mat = "?metal" },
    },

    {
      { x = 112, y =  0, mat = "?fence" },
      { x = 128, y =  0, mat = "?fence" },
      { x = 128, y = 32, mat = "?fence" },
      { x = 112, y = 32, mat = "?fence" },
      { t = 72, mat = "?fence" },
    },
  },
}


PREFAB.FENCE_W_RAIL_INSET =
{
  placement = "fitted",

  x_sizes = { {16,0}, {96,1}, {16,0} },

  repeat_width = 96,

  brushes =
  {
    {
      { x =   0, y =  0, mat = "?fence" },
      { x =  16, y =  0, mat = "?fence" },
      { x =  16, y = 32, mat = "?fence" },
      { x =   0, y = 32, mat = "?fence" },
      { t = 96, mat = "?fence" },
    },

    {
      { x =  16, y =  0, mat = "?fence" },
      { x = 112, y =  0, mat = "?fence" },
      { x = 112, y = 32, mat = "?fence" },
      { x =  16, y = 32, mat = "?fence" },
      { t = 16, mat = "?fence" },
    },

    {
      { m = "rail" },
      { x =  16, y = 16, mat = "?rail", blocked=1 },
      { x = 112, y = 16 },
      { x = 112, y = 32 },
      { x =  16, y = 32 },
      { b = 16 },
      { t = 80 },
    },

    {
      { x = 112, y =  0, mat = "?fence" },
      { x = 128, y =  0, mat = "?fence" },
      { x = 128, y = 32, mat = "?fence" },
      { x = 112, y = 32, mat = "?fence" },
      { t = 96, mat = "?fence" },
    },
  },
}


PREFAB.FENCE_W_TORCHES =
{
  placement = "fitted",

  x_sizes = { {16,0}, {96,1}, {16,0} },

  repeat_width = 128,

  brushes =
  {
    {
      { x =   0, y =  0, mat = "?fence" },
      { x =  16, y =  0, mat = "?fence" },
      { x =  16, y = 32, mat = "?fence" },
      { x =   0, y = 32, mat = "?fence" },
      { t = 72, mat = "?fence" },
    },

    {
      { x =  16, y =  0, mat = "?fence" },
      { x = 112, y =  0, mat = "?fence" },
      { x = 112, y = 32, mat = "?fence" },
      { x =  16, y = 32, mat = "?fence" },
      { t = 32, mat = "?fence" },
    },

    {
      { x = 112, y =  0, mat = "?fence" },
      { x = 128, y =  0, mat = "?fence" },
      { x = 128, y = 32, mat = "?fence" },
      { x = 112, y = 32, mat = "?fence" },
      { t = 72, mat = "?fence" },
    },
  },

  entities =
  {
    { x = 46, y = 16, z = 32, ent = "?torch", angle = 90 },
    { x = 82, y = 16, z = 32, ent = "?torch", angle = 90 },
  },
}


