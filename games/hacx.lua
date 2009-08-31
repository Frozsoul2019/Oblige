----------------------------------------------------------------
--  GAME DEFINITION : HacX
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2009 Andrew Apted
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

HACX_THINGS =
{
  --- special stuff ---
  player1 = { id=1, kind="other", r=16,h=56 },
  player2 = { id=2, kind="other", r=16,h=56 },
  player3 = { id=3, kind="other", r=16,h=56 },
  player4 = { id=4, kind="other", r=16,h=56 },

  dm_player     = { id=11, kind="other", r=16,h=56 },
  teleport_spot = { id=14, kind="other", r=16,h=56 },

  --- monsters ---
  thug        = { id=3004, kind="monster", r=21,h=72 },
  android     = { id=   9, kind="monster", r=21,h=70 },
  i_c_e       = { id=3001, kind="monster", r=32,h=56 },
  buzzer      = { id=3002, kind="monster", r=25,h=68 },
  terminatrix = { id=3003, kind="monster", r=32,h=80 },
  d_man       = { id=3006, kind="monster", r=48,h=78 },

  stealth     = { id=58,  kind="monster", r=32,h=68 },
  monstruct   = { id=65,  kind="monster", r=35,h=88 },
  phage       = { id=67,  kind="monster", r=25,h=96 },
  thorn       = { id=68,  kind="monster", r=66,h=96 },
  mecha       = { id=69,  kind="monster", r=24,h=96 },
  majong7     = { id=71,  kind="monster", r=31,h=56 },
  roam_mine   = { id=84,  kind="monster", r=5, h=32 },

  --- pickups ---
  k_password = { id=5,  kind="pickup", r=20,h=16, pass=true },
  k_ckey     = { id=6,  kind="pickup", r=20,h=16, pass=true },

  kz_red     = { id=38, kind="pickup", r=20,h=16, pass=true },
  kz_yellow  = { id=39, kind="pickup", r=20,h=16, pass=true },
  kz_blue    = { id=40, kind="pickup", r=20,h=16, pass=true },

  --- scenery ---
  chair      = { id=35,   kind="scenery", r=24,h=40 },

}


----------------------------------------------------------------

HACX_MATERIALS =
{
  -- special materials --
  _ERROR = { t="HW171", f="DEM1_2" },
  _SKY   = { t="HW171", f="F_SKY1" },

  -- textures --

  BRICK1  = { t="MODWALL3", f="CEIL3_3" },

  -- flats --

  GRASS1 = { t="MARBGRAY", f="TLITE6_1" },
  GRASS2 = { t="MARBGRAY",  f="CONS1_7" },

}


HACX_SANITY_MAP =
{
  -- FIXME
}


----------------------------------------------------------------

HACX_THEMES =
{
  TECH1 =
  {
    building =
    {
      walls =
      {
        BRICK1=50,
      },
      floors =
      {
        BRICK1=50,
      },
      ceilings =
      {
        BRICK1=50,
      },
    },

    ground =
    {
      floors =
      {
        GRASS1=20,
      },
    },
  }, -- TECH
}


------------------------------------------------------------

HACX_MONSTERS =
{
  -- FIXME : HACX_MONSTERS
  thug =
  {
    prob=40,
    health=60, damage=5, attack="hitscan",
  },

  android =
  {
    prob=40,
    health=75, damage=10, attack="hitscan",
  },

  stealth =
  {
    prob=10,
    health=30, damage=25, attack="melee",
  },

  -- this thing just blows up on contact
  roam_mine =
  {
    prob=5,
    health=50, damage=5, attack="hitscan",
  },

  phage =
  {
    prob=40,
    health=150, damage=70, attack="missile",
  },

  buzzer =
  {
    prob=40,
    health=175, damage=25, attack="melee",
  },

  i_c_e =
  {
    prob=40,
    health=225, damage=7, attack="melee", --????
  },

  d_man =
  {
    prob=40,
    health=250, damage=7, attack="melee", --????
  },

  monstruct =
  {
    prob=30,
    health=400, damage=80, attack="missile",
  },

  majong7 =
  {
    prob=20,
    health=400, damage=20, attack="missile",
    density=0.5,
    weap_prefs={ launch=0.2 },
  },

  terminatrix =
  {
    prob=20,
    health=450, damage=40, attack="hitscan",
    density=0.5,
  },

  thorn =
  {
    prob=20,
    health=600, damage=70, attack="missile",
  },

  mecha =
  {
    prob=10,
    health=800, damage=150, attack="missile",
    density=0.2,
  },

}


HACX_WEAPONS =
{
  -- FIXME : HACX_WEAPONS
  boot =
  {
    rate=1.5, damage=10, attack="melee",
  },

  pistol =
  {
    pref=5,
    rate=1.5, damage=10, attack="hitscan",
    ammo="bullet", per=1,
  },

}


HACX_PICKUPS =
{
  -- FIXME : HACX_PICKUPS
}


HACX_PLAYER_MODEL =
{
  danny =
  {
    stats = { health=0, bullet=0, missile=0, grenade=0, cell=0 },

    weapons = { pistol=1, boot=1 },
  }
}


------------------------------------------------------------


function HacX_setup()
  -- nothing needed
end


function HacX_get_levels()
  local EP_NUM  = 1
  local MAP_NUM = 1

  -- FIXME: copy n paste DOOM2 logic
  if OB_CONFIG.length == "few"     then MAP_NUM = 4 end
  if OB_CONFIG.length == "episode" then MAP_NUM = 9 end
  if OB_CONFIG.length == "full"    then MAP_NUM = 9 ; EP_NUM = 3 end

  for episode = 1,EP_NUM do
    for map = 1,MAP_NUM do

      local LEV =
      {
        name = string.format("MAP%d%d", episode-1, map),

        episode  = episode,
        ep_along = map / MAP_NUM,
        ep_info  = { },

        key_list = { "foo" },
        switch_list = { "foo" },
        bar_list = { "foo" },
      }

      table.insert(GAME.all_levels, LEV)
    end -- for map

  end -- for episode
end



------------------------------------------------------------

OB_THEMES["hacx_tech"] =
{
  label = "Tech",
  for_games = { hacx=1 },

  prefix = "TECH",
  name_theme = "TECH",
  use_prob = 50,
}


OB_GAMES["hacx"] =
{
  label = "HacX 1.1",

  setup_func = HacX_setup,
  levels_start_func = HacX_get_levels,

  param =
  {
    format = "doom",

    rails = true,
    switches = true,
    liquids = true,
    teleporters = true,
    noblaze_door = true,

    no_keys = true,

    seed_size = 256,

    max_name_length = 28,

    skip_monsters = { 10,30 },

    time_factor   = 1.0,
    damage_factor = 1.0,
    ammo_factor   = 0.8,
    health_factor = 0.7,
  },

  tables =
  {
    "player_model", HACX_PLAYER_MODEL,
    
    "things",   HACX_THINGS,
    "monsters", HACX_MONSTERS,
    "weapons",  HACX_WEAPONS,
    "pickups",  HACX_PICKUPS,

    "materials", HACX_MATERIALS,
    "themes",    HACX_THEMES,
  },
}

