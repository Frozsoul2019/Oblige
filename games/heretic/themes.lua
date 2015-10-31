------------------------------------------------------------------------
--  HERETIC THEMES
------------------------------------------------------------------------
--
--  Copyright (C) 2006-2015 Andrew Apted
--  Copyright (C)      2008 Sam Trenholme
--
--  This program is free software; you can redistribute it and/or
--  modify it under the terms of the GNU General Public License
--  as published by the Free Software Foundation; either version 2
--  of the License, or (at your option) any later version.
--
------------------------------------------------------------------------

HERETIC.THEMES =
{
  DEFAULTS =
  {
    -- Note: there is no way to control the order which keys are used

    keys =
    {
      k_yellow = 70
      k_green  = 50
      k_blue   = 30
    }

    switches =
    {
      sw_metal = 50
    }

    fences =
    {
      BRWNRCKS = 20
    }
  }


  generic_Stairwell =
  {
    kind = "stairwell"

    walls =
    {
      WOODWL = 50
    }

    floors =
    {
      FLOOR03 = 30
    }
  }


  ---- URBAN THEME ---------------------------------

  h_urban =
  {
    liquids =
    {
      water  = 50
      sludge = 15
      lava   = 5
    }

    facades =
    {
      GRSTNPB = 50
    }
  }


  h_urban_House1 =
  {
    kind = "building"

    walls =
    {
      CTYSTCI2 = 20
      CTYSTCI4 = 40
    }

    floors =
    {
      FLOOR03 = 50
      FLOOR06 = 50
      FLOOR10 = 50
    }

    ceilings =
    {
      FLAT521 = 50
      FLAT523 = 50
    }
  }


  h_urban_House2 =
  {
    kind = "building"

    walls =
    {
      CTYSTUC4 = 50
    }

    floors =
    {
      FLOOR03 = 50
      FLOOR06 = 50
      FLOOR10 = 50
    }

    ceilings =
    {
      FLAT521 = 50
      FLAT523 = 50
    }
  }


  h_urban_Stone =
  {
    kind = "building"

    walls =
    {
      GRSTNPB = 50
    }

    floors =
    {
      FLOOR00 = 50
      FLOOR19 = 50
      FLAT522 = 50
      FLAT523 = 50
    }

    ceilings =
    {
      FLAT520 = 50
      FLAT523 = 50
    }
  }


  h_urban_Wood =
  {
    kind = "building"

    walls =
    {
      WOODWL = 50
    }

    floors =
    {
      FLAT508 = 20
      FLOOR11 = 20
      FLOOR03 = 50
      FLOOR06 = 50
    }

    ceilings =
    {
      FLOOR10 = 50
      FLOOR11 = 30
      FLOOR01 = 50
    }
  }


  h_urban_Cave =
  {
    kind = "cave"

    naturals =
    {
      LOOSERCK=20, LAVA1=20, BRWNRCKS=20
    }
  }


  h_urban_Outdoors =
  {
    kind = "outdoors"

    floors =
    {
      FLOOR00=20, FLOOR27=30, FLOOR18=50,
      FLAT522=10, FLAT523=20,
    }

    naturals =
    {
      FLOOR17=50, FLAT509=20, FLAT510=20,
      FLAT513=20, FLAT516=35, 
    }
  }


  ---- CASTLE THEME --------------------------------

  h_castle =
  {
    liquids =
    {
      lava   = 50
      magma  = 20
      sludge = 5
    }

    facades =
    {
      CSTLRCK  = 50
      GRNBLOK1 = 30
    }
  }


  h_castle_Green =
  {
    kind = "building"

    walls =
    {
      GRNBLOK1 = 50
      MOSSRCK1 = 50
    }

    floors =
    {
      FLOOR19 = 20
      FLOOR27 = 50
      FLAT520 = 50
      FLAT521 = 50
    }

    ceilings =
    {
      FLOOR05 = 50
      FLAT512 = 50
    }
  }


  h_castle_Gray =
  {
    kind = "building"

    walls =
    {
      CSTLRCK  = 50
      TRISTON1 = 50
    }

    floors =
    {
      FLAT503 = 50
      FLAT522 = 50
      FLOOR10 = 50
    }

    ceilings =
    {
      FLOOR04 = 50
      FLAT520 = 50
    }
  }


  h_castle_Orange =
  {
    kind = "building"

    walls =
    {
      SQPEB2   = 50
      TRISTON2 = 50
    }

    floors =
    {
      FLOOR01 = 50
      FLOOR03 = 50
      FLOOR06 = 20
    }

    ceilings =
    {
      FLAT523 = 50
      FLOOR17 = 50
    }
  }


  h_castle_Hallway =
  {
    kind = "hallway"

    walls =
    {
      GRSTNPB  = 60
      SANDSQ2  = 20
      SNDCHNKS = 20
    }

    floors =
    {
      FLOOR00 = 50
      FLOOR18 = 50
      FLAT521 = 50
      FLAT506 = 50
    }

    ceilings =
    {
      FLAT523 = 50
    }
  }


  -- TODO : these are same as urban theme, differentiate them!

  h_castle_Cave =
  {
    kind = "cave"

    naturals =
    {
      LOOSERCK=20, LAVA1=20, BRWNRCKS=20
    }
  }


  h_castle_Outdoors =
  {
    kind = "outdoors"

    floors =
    {
      FLOOR00=20, FLOOR27=30, FLOOR18=50,
      FLAT522=10, FLAT523=20,
    }

    naturals =
    {
      FLOOR17=50, FLAT509=20, FLAT510=20,
      FLAT513=20, FLAT516=35, 
    }
  }
}


------------------------------------------------------------------------

HERETIC.NAMES =
{
  -- TODO
}


HERETIC.ROOMS =
{
  GENERIC =
  {
    environment = "any"
  }
}


------------------------------------------------------------------------


OB_THEMES["h_urban"] =
{
  label = "Urban"
  name_theme = "URBAN"
  mixed_prob = 50
}


OB_THEMES["h_castle"] =
{
  label = "Castle"
  name_theme = "GOTHIC"
  mixed_prob = 50
}

