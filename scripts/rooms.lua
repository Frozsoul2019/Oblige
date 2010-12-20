----------------------------------------------------------------
--  Room Management
----------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2010 Andrew Apted
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

--[[ *** CLASS INFORMATION ***

class ROOM
{
  kind : keyword  -- "normal" (layout-able room)
                  -- "scenic" (unvisitable room)
                  -- "hallway", "stairwell", "small_exit"

  shape : keyword -- "rect" (perfect rectangle)
                  -- "L"  "T"  "U"
                  -- "plus"
                  -- "odd"  (anything else)

  outdoor : bool  -- true for outdoor rooms
  natural : bool  -- true for cave/landscape areas
  scenic  : bool  -- true for scenic (unvisitable) areas

  conns : array(CONN)  -- connections with neighbor rooms
  entry_conn : CONN

  branch_kind : keyword

  hallway : HALLWAY_INFO   -- for hallways and stairwells

  symmetry : keyword   -- symmetry of room, or NIL
                       -- keywords are "x", "y", "xy"

  kx1, ky1, kx2, ky2  -- \ Section range
  kw, kh              -- /

  sections   -- list of all sections of room

  sx1, sy1, sx2, sy2  -- \ Seed range
  sw, sh, svolume     -- /

  quest : QUEST

  purpose : keyword   -- usually NIL, can be "EXIT" etc... (FIXME)

  floor_h, ceil_h : number


  --- plan_sp code only:

  lx1, ly1, lx2, ly2  -- coverage on the Land Map

  group_id : number  -- traversibility group

}


----------------------------------------------------------------]]

require 'defs'
require 'util'


ROOM_CLASS = {}

function ROOM_CLASS.new(shape)
  local id = Plan_alloc_id("room")
  local R = { id=id, kind="normal", shape=shape, conns={}, neighbors={},
              sections={}, middles={}, spaces={} }
  table.set_class(R, ROOM_CLASS)
  table.insert(LEVEL.all_rooms, R)
  return R
end

function ROOM_CLASS.tostr(self)
  return string.format("ROOM_%d", self.id)
end

function ROOM_CLASS.longstr(self)
  return string.format("%s_%s [%d,%d..%d,%d]",
      sel(self.parent, "SUB_ROOM", "ROOM"),
      self.id, self.kx1,self.ky1, self.kx2,self.ky2)
end

function ROOM_CLASS.update_size(self)
  self.sw, self.sh = geom.group_size(self.sx1, self.sy1, self.sx2, self.sy2)
end

function ROOM_CLASS.contains_seed(self, x, y)
  if x < self.sx1 or x > self.sx2 then return false end
  if y < self.sy1 or y > self.sy2 then return false end
  return true
end

function ROOM_CLASS.has_lock(self, lock)
  for _,C in ipairs(self.conns) do
    if C.lock == lock then return true end
  end
  return false
end

function ROOM_CLASS.has_any_lock(self)
  for _,C in ipairs(self.conns) do
    if C.lock then return true end
  end
  return false
end

function ROOM_CLASS.has_lock_kind(self, kind)
  for _,C in ipairs(self.conns) do
    if C.lock and C.lock.kind == kind then return true end
  end
  return false
end

function ROOM_CLASS.has_sky_neighbor(self)
  for _,C in ipairs(self.conns) do
    local N = C:neighbor(self)
    if N.outdoor then return true end
  end
  return false
end

function ROOM_CLASS.has_teleporter(self)
  for _,C in ipairs(self.conns) do
    if C.kind == "teleporter" then return true end
  end
  return false
end

function ROOM_CLASS.dist_to_closest_conn(self, K, side)
  -- TODO: improve this by calculating side coordinates
  local best

  for _,C in ipairs(self.conns) do 
    local K2 = C:section(self)
    if K2 then
      local dist = geom.dist(K.kx, K.ky, K2.kx, K2.ky)

      if not best or dist < best then
        best = dist
      end
    end
  end

  return best
end

function ROOM_CLASS.is_near_exit(self)
  if self.purpose == "EXIT" then return true end
  for _,C in ipairs(self.conns) do
    local N = C:neighbor(self)
    if N.purpose == "EXIT" then return true end
  end
  return false
end


----------------------------------------------------------------


function Rooms_setup_theme(R)
  R.skin = {}

  R.skin.spike_group = "spike" .. tostring(R.id)

  if not R.outdoor then
    R.main_tex = rand.pick(LEVEL.building_walls)
    R.skin.wall = R.main_tex
    return
  end

  if not R.quest.courtyard_floor then
    R.quest.courtyard_floor = rand.pick(LEVEL.courtyard_floors)
  end

  R.main_tex = R.quest.courtyard_floor

  R.skin.wall = R.main_tex
  R.skin.fence = "ICKWALL7"
end


function Rooms_setup_theme_Scenic(R)
  -- TODO
  R.outdoor = true
  Rooms_setup_theme(R)
end


function Rooms_assign_facades()
  for i = 1,#LEVEL.all_rooms,4 do
    local R = LEVEL.all_rooms[i]
    R.facade = rand.pick(LEVEL.building_facades)
  end

  local visits = table.copy(LEVEL.all_rooms)

  for loop = 1,10 do
    local changes = false

    rand.shuffle(visits);

    for _,R in ipairs(visits) do
      if R.facade then
        for _,N in ipairs(R.neighbors) do
          if not N.facade then 
            N.facade = R.facade
            changes = true
          end
        end -- for N
      elseif rand.odds(loop * loop) then
        R.facade = rand.pick(LEVEL.building_facades)
      end
    end -- for R
  end -- for loop

  for _,R in ipairs(LEVEL.all_rooms) do
    assert(R.facade)
  end

  for _,R in ipairs(LEVEL.scenic_rooms) do
    if not R.facade then
      R.facade = rand.pick(LEVEL.building_facades)
    end
  end
end


function Rooms_choose_themes()
  for _,R in ipairs(LEVEL.all_rooms) do
    Rooms_setup_theme(R)
  end

  for _,R in ipairs(LEVEL.scenic_rooms) do
    Rooms_setup_theme_Scenic(R)
  end
end


function Rooms_setup_symmetry()
  -- The 'symmetry' field of each room already has a value
  -- (from the big-branch connection system).  Here we choose
  -- whether to keep that, expand it (rare) or discard it.
  --
  -- The new value applies to everything made in the room
  -- (as much as possible) from now on.

  local function prob_for_match(old_sym, new_sym)
    if old_sym == new_sym then
      return sel(old_sym == "xy", 8000, 400)

    elseif new_sym == "xy" then
      -- rarely upgrade from NONE --> XY symmetry
      return sel(old_sym, 30, 3)

    elseif old_sym == "xy" then
      return 150

    else
      -- rarely change from X --> Y or vice versa
      return sel(old_sym, 6, 60)
    end
  end


  local function prob_for_size(R, new_sym)
    local prob = 200

    if new_sym == "x" or new_sym == "xy" then
      if R.sw <= 2 then return 0 end
      if R.sw <= 4 then prob = prob / 2 end

      if R.sw > R.sh * 3.1 then return 0 end
      if R.sw > R.sh * 2.1 then prob = prob / 3 end
    end

    if new_sym == "y" or new_sym == "xy" then
      if R.sh <= 2 then return 0 end
      if R.sh <= 4 then prob = prob / 2 end

      if R.sh > R.sw * 3.1 then return 0 end
      if R.sh > R.sw * 2.1 then prob = prob / 3 end
    end

    return prob
  end


  local function decide_layout_symmetry(R)
    R.conn_symmetry = R.symmetry

    -- We discard 'R' rotate and 'T' transpose symmetry (for now...)
    if not (R.symmetry == "x" or R.symmetry == "y" or R.symmetry == "xy") then
      R.symmetry = nil
    end

    if STYLE.symmetry == "none" then return end

    local SYM_LIST = { "x", "y", "xy" }

    local syms  = { "none" }
    local probs = { 100 }

    if STYLE.symmetry == "few"   then probs[1] = 500 end
    if STYLE.symmetry == "heaps" then probs[1] = 10  end

    for _,sym in ipairs(SYM_LIST) do
      local p1 = prob_for_size(R, sym)
      local p2 = prob_for_match(R.symmetry, sym)

      if p1 > 0 and p2 > 0 then
        table.insert(syms, sym)
        table.insert(probs, p1*p2/100)
      end
    end

    local index = rand.index_by_probs(probs)

    R.symmetry = sel(index > 1, syms[index], nil)
  end


  --| Rooms_setup_symmetry |--

  for _,R in ipairs(LEVEL.all_rooms) do
    decide_layout_symmetry(R)

    gui.debugf("Final symmetry @ %s : %s --> %s\n", R:tostr(),
               tostring(R.conn_symmetry), tostring(R.symmetry))

    if R.symmetry == "x" or R.symmetry == "xy" then
      R.mirror_x = true
    end

    if R.symmetry == "y" or R.symmetry == "xy" then
      R.mirror_y = true
    end
  end
end



function Rooms_synchronise_skies()
  -- make sure that any two outdoor rooms which touch have the same sky_h

  for loop = 1,10 do
    local changes = false

    for x = 1,SECTION_W do for y = 1,SECTION_H do
      local K = SECTIONS[x][y]
      if K and K.room and K.room.sky_h then
        for side = 2,8,2 do
          local N = K:neighbor(side)
          if N and N.room and N.room ~= K.room and N.room.sky_h and
             K.room.sky_h ~= N.room.sky_h
          then
            K.room.sky_h = math.max(K.room.sky_h, N.room.sky_h)
            N.room.sky_h = K.room.sky_h
            changes = true
          end
        end -- for side
      end
    end end -- for x, y

    if not changes then break; end
  end -- for loop
end


function Rooms_decide_windows()

  local function add_window(K, N, side)
    gui.printf("Window from %s --> %s\n", K:tostr(), N:tostr())

    local USAGE =
    {
      kind = "window",
      K1 = K, K2 = N, dir = side
    }

    local E1 = K.edges[side]
    local E2 = N.edges[10-side]

    E1.usage = USAGE
    E2.usage = USAGE

    K.room.num_windows = K.room.num_windows + 1
    N.room.num_windows = N.room.num_windows + 1
  end


  local function can_add_window(K, side)
    local N = K:neighbor(side)

    if not N then return false end
    if N.room == K.room then return false end

    local E1 = K.edges[side]
    local E2 = N.edges[10-side]

    if not E1 or not E2 then return false end

    if E1.usage or E2.usage then return false end

    return true
  end


  local function try_add_windows(R, side, prob)
    if STYLE.windows == "few"  and R.num_windows > 0 then return end
    if STYLE.windows == "some" and R.num_windows > 2 then return end

    for _,K in ipairs(R.sections) do
      local N = K:neighbor(side)

      -- FIXME: sometimes make windows from indoor to indoor

      if can_add_window(K, side) and N.room.outdoor
         and rand.odds(prob)
      then
        add_window(K, N, side)      
      end
    end
  end

  
  local function do_windows(R)
    R.num_windows = 0

    if STYLE.windows == "none" then return end

---    if R.outdoor or R.semi_outdoor then return end

    -- TODO: cavey see-through holes
    if R.natural then return end

    local prob = style_sel("windows", 0, 20, 40, 80+19)

    local SIDES = { 2,4,6,8 }
    rand.shuffle(SIDES)

    for _,side in ipairs(SIDES) do
      try_add_windows(R, side, prob)
    end
  end


  ---| Rooms_decide_windows |---

  if STYLE.windows == "none" then return end

  for _,R in ipairs(LEVEL.all_rooms) do
    do_windows(R)
  end
end



function Room_select_picture(R, v_space, index)
  v_space = v_space - 16
  -- FIXME: needs more v_space checking

  if THEME.logos and rand.odds(sel(LEVEL.has_logo,7,40)) then
    LEVEL.has_logo = true
    return rand.key_by_probs(THEME.logos)
  end

  if R.has_liquid and index == 1 and rand.odds(75) then
    if THEME.liquid_pics then
      return rand.key_by_probs(THEME.liquid_pics)
    end
  end

  local pic_tab = {}

  local pictures = THEME.pictures

  if pictures then
    for name,prob in pairs(pictures) do
      local info = GAME.PICTURES[name]
      if info and info.height <= v_space then
        pic_tab[name] = prob
      end
    end
  end

  if not table.empty(pic_tab) then
    return rand.key_by_probs(pic_tab)
  end

  return nil  -- failed
end


------------------------------------------------------------------------

function Rooms_dists_from_entrance()

  local function spread_entry_dist(R)
    local count = 1
    local total = #R.sections

    local K = R.entry_conn:section(R)

    K.entry_dist = 0

    while count < total do
      for _,K in ipairs(R.sections) do
        for side = 2,8,2 do
          local N = K:neighbor(side)
          if N and N.room == R and N.entry_dist then

            local dist = N.entry_dist + 1
            if not K.entry_dist then
              K.entry_dist = dist
              count = count + 1
            elseif dist < K.entry_dist then
              K.entry_dist = dist
            end

          end
        end
      end
    end
  end

  --| Rooms_dists_from_entrance |--

  for _,R in ipairs(LEVEL.all_rooms) do
    if R.entry_conn then
      spread_entry_dist(R)
    else
      for _,K in ipairs(R.sections) do
        K.entry_dist = 0
      end
    end
  end
end



function Rooms_collect_targets(R)

  local targets =
  {
    edges = {},
    corners = {},
    middles = {},
  }

  local function corner_very_free(C)
    if C.usage then return false end

    -- size check (TODO: probably better elsewhere)
    if (C.K.x2 - C.K.x1) < 512 then return false end
    if (C.K.y2 - C.K.y1) < 512 then return false end

    -- check if the edges touching the corner are also free

    for _,K in ipairs(R.sections) do
      for _,E in pairs(K.edges) do
        if E.corn1 == C and E.usage then return false end
        if E.corn2 == C and E.usage then return false end
      end
    end
  
    return true
  end

  --| Rooms_collect_targets |--

  for _,M in ipairs(R.middles) do
    if not M.usage then
      table.insert(targets.middles, M)
    end
  end

  for _,K in ipairs(R.sections) do
    for _,C in pairs(K.corners) do
      if not C.concave and corner_very_free(C) then
        table.insert(targets.corners, C)
      end
    end

    for _,E in pairs(K.edges) do
      if not E.usage then
        table.insert(targets.edges, E)
      end
    end
  end

  return targets
end


function Rooms_sort_targets(targets, entry_factor, conn_factor, busy_factor)
  for _,listname in ipairs { "edges", "corners", "middles" } do
    local list = targets[listname]
    if list then
      for _,E in ipairs(list) do
        E.free_score = E.K.entry_dist * entry_factor +
                       E.K.num_conn   * conn_factor  +
                       E.K.num_busy   * busy_factor  +
                       gui.random()   * 0.1
      end

      table.sort(list, function(A, B) return A.free_score > B.free_score end)
    end
  end
end


function Rooms_place_importants()

  local function clear_busyness(R)
    for _,K in ipairs(R.sections) do
      K.num_busy = 0
    end
  end


  local function pick_target(R, usage)
    local prob_tab = {}

    if #R.targets.edges > 0 and usage.edge_fabs then
      prob_tab["edge"] = #R.targets.edges * 5
    end
    if #R.targets.corners > 0 and usage.corner_fabs then
      prob_tab["corner"] = #R.targets.corners * 3
    end
    if #R.targets.middles > 0 and usage.middle_fabs then
      prob_tab["middle"] = #R.targets.middles * 11
    end

    if table.empty(prob_tab) then
      error("could not place important stuff in room!")
    end

    local what = rand.key_by_probs(prob_tab)

    if what == "edge" then

      local edge = table.remove(R.targets.edges, 1)
      edge.usage = usage

--stderrf("EDGE %s:%d ---> USAGE %s %s\n", edge.K:tostr(), edge.side, usage.kind, usage.sub or "-")

      edge.K.num_busy = edge.K.num_busy + 1

    elseif what == "corner" then

      local corner = table.remove(R.targets.corners, 1)
      corner.usage = usage

      corner.K.num_busy = corner.K.num_busy + 1

    else assert(what == "middle")

      local middle = table.remove(R.targets.middles, 1)
      middle.usage = usage

      middle.K.num_busy = middle.K.num_busy + 1

    end
  end


  local function place_importants(R)
    -- determine available places
    R.targets = Rooms_collect_targets(R, edges, corners, middles)

    if R.purpose then
      Rooms_sort_targets(R.targets, 1, -0.6, -0.2)

      local USAGE =
      {
        kind = "important",
        sub  = R.purpose,
        lock = R.purpose_lock,
      }

      local list

      if R.purpose == "START" then
        list = THEME.starts

      elseif R.purpose == "EXIT" then
        list = THEME.exits

      elseif R.purpose == "SOLUTION" then

        if R.purpose_lock.kind == "KEY" then
          list = THEME.pedestals
        elseif R.purpose_lock.kind == "SWITCH" then
          -- Umm WTF ??
          list = "SWITCH"
        else
          error("Unknown purpose_lock.kind: " .. tostring(R.purpose_lock.kind))
        end

      else
        error("Unknown room purpose: " .. tostring(R.purpose))
      end

      Layout_possible_fab_group(USAGE, list)

      pick_target(R, USAGE)

      -- FIXME: cheap hack, should just remove the invalidated targets
      --        (a bit complicated since corners use the nearby edges
      --         and hence one can invalidate the other)
      R.targets = Rooms_collect_targets(R, edges, corners, middles)
    end

    Rooms_sort_targets(R.targets, 0.4, -1, -0.8)

    if R:has_teleporter() then
      local USAGE =
      {
        kind = "important",
        sub  = "teleporter",
      }

      Layout_possible_fab_group(USAGE, THEME.teleporters)

      pick_target(R, USAGE)

      R.targets = Rooms_collect_targets(R, edges, corners, middles)
    end


    -- ??? TODO: weapon (currently added by pickup code)

  end


  --| Rooms_place_importants |--

  Rooms_dists_from_entrance()

  for _,R in ipairs(LEVEL.all_rooms) do
    clear_busyness(R)
    place_importants(R)
  end
end



function Rooms_extra_room_stuff()

  -- this function is meant to ensure good traversibility in a room.
  -- e.g. put a nice item in sections without any connections or
  -- importants, or if the exit is close to the entrance then make
  -- the exit door require a far-away switch to open it.

  local function extra_stuff(R)
    -- TODO
  end


  --| Rooms_extra_room_stuff |--

  for _,R in ipairs(LEVEL.all_rooms) do
    extra_stuff(R)
  end
end




------------------------------------------------------------------------


function Rooms_build_cave(R)

do return end --!!!!!!!!!  FIXME CAVES

  local cave  = R.cave

  local w_tex  = R.cave_tex
  local w_info = get_mat(w_tex)
  local high_z = EXTREME_H

  local base_x = SECTIONS[R.kx1][R.ky1].x1
  local base_y = SECTIONS[R.kx1][R.ky1].y1

  local function WALL_brush(data, coords)
    if data.shadow_info then
      local sh_coords = shadowify_brush(coords, 40)
--!!!!      Trans.old_brush(data.shadow_info, sh_coords, -EXTREME_H, (data.z2 or EXTREME_H) - 4)
    end

    if data.f_z then table.insert(coords, { t=data.f_z, delta_z=data.delta_f }) end
    if data.c_z then table.insert(coords, { b=data.c_z, delta_z=data.delta_c }) end

    Trans.set_mat(coords, data.wtex, data.ftex)

    Trans.brush(coords)
  end

  local function FC_brush(data, coords)
    if data.f_info then
      local coord2 = table.deep_copy(coords)
      table.insert(coord2, { t=data.f_z, delta_z=data.delta_f })

      Trans.set_mat(coord2, data.wtex, data.ftex)
      Trans.brush(coord2)
    end

    if data.c_info then
      local coord2 = table.deep_copy(coords)
      table.insert(coord2, { b=data.c_z, delta_z=data.delta_c })

      Trans.set_mat(coords, data.wtex, data.ctex)
      Trans.brush(coord2)
    end
  end

  local function choose_tex(last, tab)
    local tex = rand.key_by_probs(tab)

    if last then
      for loop = 1,5 do
        if not Mat_similar(last, tex) then break; end
        tex = rand.key_by_probs(tab)
      end
    end

    return tex
  end

  -- DO WALLS --

  local data = { info=w_info, wtex=w_tex, ftex=w_tex, ctex=w_tex }

  if R.is_lake then
    data.info = Mat_liquid()
    data.delta_f = rand.sel(70, -48, -72)
    data.f_z = R.cave_floor_h + 8
    data.ftex = data.info.t_face.tex -- TEMP CRUD
  end

  if R.outdoor and not R.is_lake and R.cave_floor_h + 144 < SKY_H and rand.odds(88) then
    data.f_z = R.cave_floor_h + rand.sel(65, 80, 144)
  end

  if PARAM.outdoor_shadows and R.outdoor and not R.is_lake then
--!!!!!    data.shadow_info = get_light(-1)
  end

  -- grab walkway now (before main cave is modified)

  local walkway = cave:copy_island(cave.empty_id)


  -- handle islands first

  for _,island in ipairs(cave.islands) do

    -- FIXME
    if LEVEL.liquid and not R.is_lake and --[[ reg.cells > 4 and --]]
       rand.odds(50)
    then

      -- create a lava/nukage pit
      local pit = Mat_liquid()

      island:render(base_x, base_y, WALL_brush,
                    { f_z=R.cave_floor_h+8, ftex=pit.t_face.tex,
                      delta_f=rand.sel(70, -52, -76) })

      cave:subtract(island)
    end
  end


  cave:render(base_x, base_y, WALL_brush, data, THEME.square_caves)


  if R.is_lake then return end
  if THEME.square_caves then return end
  if PARAM.simple_caves then return end


  local ceil_h = R.cave_floor_h + R.cave_h

  -- TODO: @ pass 3, 4 : come back up (ESP with liquid)

  local last_ftex = R.cave_tex

  for i = 1,rand.index_by_probs({ 10,10,70 })-1 do
    walkway:shrink(false)

---???    if rand.odds(sel(i==1, 20, 50)) then
---???      walkway:shrink(false)
---???    end

    walkway:remove_dots()

    -- DO FLOOR and CEILING --

    data = {}


    if R.outdoor then
      data.ftex = choose_tex(last_ftex, THEME.landscape_trims or THEME.landscape_walls)
    else
      data.ftex = choose_tex(last_ftex, THEME.cave_trims or THEME.cave_walls)
    end

    last_ftex = data.ftex

    data.f_info = get_mat(data.ftex)

    if LEVEL.liquid and i==2 and rand.odds(60) then  -- TODO: theme specific prob
      data.f_info = get_liquid()

      -- FIXME: this bugs up monster/pickup/key spots
      if rand.odds(0) then
        data.delta_f = -(i * 10 + 40)
      end
    end

    if true then
      data.delta_f = -(i * 10)
    end

    data.f_z = R.cave_floor_h + i
    data.ftex = data.f_info.t_face.tex

    data.c_info = nil

    if not R.outdoor then
      data.c_info = w_info

      if i==2 and rand.odds(60) then
        data.c_info = Mat_sky()
      elseif rand.odds(50) then
        data.c_info = get_mat(data.ftex)
      elseif rand.odds(80) then
        data.ctex = choose_tex(data.ctex, THEME.cave_trims or THEME.cave_walls)
        data.c_info = get_mat(data.ctex)
      end

      data.delta_c = int((0.6 + (i-1)*0.3) * R.cave_h)

      data.c_z = ceil_h - i
    end


    walkway:render(base_x, base_y, FC_brush, data)
  end
end


function Rooms_do_small_exit()
  local C = R.conns[1]
  local T = C:seed(C:neighbor(R))
  local out_combo = T.room.main_tex
  if T.room.outdoor then out_combo = R.main_tex end

  -- FIXME: use single one over a whole episode
  local skin_name = rand.key_by_probs(THEME.small_exits)
  local skin = assert(GAME.EXITS[skin_name])

  local skin2 =
  {
    wall = out_combo,
    floor = T.f_tex or C.conn_ftex,
    ceil = out_combo,
  }

  assert(THEME.exit.switches)
  -- FIXME: hacky
  skin.switch = rand.key_by_probs(THEME.exit.switches)

--!!!!!!  Build.small_exit(R, THEME.exit, skin, skin2)

  local skin = table.copy(assert(GAME.EXITS["tech_small"]))
  skin.inner = w_tex
  skin.outer = o_tex

  local T = Trans.doorway_transform(S, z1, 8)
  Trans.modify("scale_x", 192 / 256)
  Trans.modify("scale_y", 192 / 256)

  ttfn_fabricate("SMALL_EXIT", T, { skin })

  return
end



function Rooms_player_angle(S)
  if R.sh > R.sw then
    if S.sy > (R.sy1 + R.sy2) / 2 then 
      return 270
    else
      return 90
    end
  else
    if S.sx > (R.sx1 + R.sx2) / 2 then 
      return 180
    else
      return 0
    end
  end
end



function Rooms_setup_bits(R)
  R.num_windows = 0

  R.cage_spots = {}
  R.trap_spots = {}
  R.mon_spots  = {}
  R.item_spots = {}

  R.prefabs = {}
  R.blocks  = {}
  R.decor   = {}
end



function Rooms_add_sun()
  if GAME.format == "doom" then
    return
  end

  local sun_r = 25000
  local sun_h = 40000

  -- nine lights in the sky, one is "the sun" and the rest are
  -- to keep outdoor areas from getting too dark.

  for i = 1,8 do
    local angle = i * 45 - 22.5

    local x = math.sin(angle * math.pi / 180.0) * sun_r
    local y = math.cos(angle * math.pi / 180.0) * sun_r

    local level = sel(i == 1, 32, 6)

    Trans.entity("sun", x, y, sun_h, { light=level })
  end

  Trans.entity("sun", 0, 0, sun_h, { light=12 })
end



function Rooms_intermission_camera()
  if GAME.format ~= "quake" then return end

  -- determine the room (biggest one, excluding starts and exits)
  local room

  for _,R in ipairs(LEVEL.all_rooms) do
    if R.purpose ~= "START" and R.purpose ~= "EXIT" then
      if not room or (R.kvolume > room.kvolume) then
        room = R
      end
    end
  end

  if not room then return end

  -- determine place in room
  local K
  local dir

  local SIDES = { 1,3,7,9 }
  rand.shuffle(SIDES)

  for _,side in pairs(SIDES) do
    local kx = sel(side == 1 or side == 7, room.kx1, room.kx2)
    local ky = sel(side == 1 or side == 3, room.ky1, room.ky2)

    if SECTIONS[kx][ky].room == room then
      K = SECTIONS[kx][ky]
      dir = 10 - side
      break;
    end
  end

  if not K then
    K = room.sections[1]
    dir = 1

    if K:same_room(6) then dir = 3 end
    if K:same_room(8) then dir = dir + 6 end
  end

  gui.printf("Camera @ %s dir:%d\n", K:tostr(), dir)

  local z1
  local z2 = room.entry_floor_h

  if room.ceil_h then z1 = room.ceil_h - 64
  elseif room.sky_h then z1 = room.sky_h - 96
  else z1 = room.entry_floor_h + 128
  end

  local K2 = K

      if (dir == 3 or dir == 9) and K2:same_room(6) then K2 = K2:neighbor(6)
  elseif (dir == 7 or dir == 9) and K2:same_room(8) then K2 = K2:neighbor(8)
  elseif (dir == 1 or dir == 3) and K2:same_room(2) then K2 = K2:neighbor(2)
  elseif (dir == 1 or dir == 7) and K2:same_room(4) then K2 = K2:neighbor(4)
  end

  local x1 = math.min(K.x1, K2.x1)
  local y1 = math.min(K.y1, K2.y1)
  local x2 = math.max(K.x2, K2.x2)
  local y2 = math.max(K.y2, K2.y2)
  
  local W = x2 - x1
  local H = y2 - y1

  x1 = x1 + int(W / 3) ; x2 = x2 - int(W / 3)
  y1 = y1 + int(H / 3) ; y2 = y2 - int(H / 3)

  if dir == 1 or dir == 7 then x1,x2 = x2,x1 end
  if dir == 1 or dir == 3 then y1,y2 = y2,y1 end

  local dist  = geom.dist(x1,y1, x2,y2)
  local angle = geom.calc_angle(x2 - x1, y2 - y1)
  local mlook = geom.calc_angle(dist, z1 - z2)

  local mangle = string.format("%d %d 0", mlook, angle)

  Trans.entity("camera", x1, y1, z1, { mangle=mangle })
end



function Rooms_build_all()

  gui.printf("\n--==| Build Rooms |==--\n\n")

  Rooms_choose_themes()
  Rooms_assign_facades()

  Rooms_setup_symmetry()

  for _,R in ipairs(LEVEL.all_rooms) do
    Rooms_setup_bits(R)
    Layout_monotonic_spaces(R)
  end

  if PARAM.tiled then
    -- this is as far as we go for TILE based games
    Tiler_layout_all()
    return
  end


  Rooms_place_importants()
  Rooms_decide_windows()
  Rooms_extra_room_stuff()

  Layout_all_walls()
  Layout_all_floors()
  Layout_all_ceilings()

  -- scenic rooms ??

  Rooms_add_sun()
  Rooms_intermission_camera()
end

