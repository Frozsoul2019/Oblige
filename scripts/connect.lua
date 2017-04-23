------------------------------------------------------------------------
--  CONNECTIONS
------------------------------------------------------------------------
--
--  Oblige Level Maker
--
--  Copyright (C) 2006-2017 Andrew Apted
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
------------------------------------------------------------------------


--class CONN
--[[
    kind : keyword  -- "edge", "joiner", "teleporter"

    lock : LOCK

    is_secret : boolean

    id : number  -- debugging aid

    -- The two rooms are the vital (compulsory) information,
    -- especially for the quest system.
    --
    -- For teleporters the edge and area info will be absent.
    -- For joiners, the edges are NOT peered.

    R1 : source ROOM
    R2 : destination ROOM

    E1 : source EDGE
    E2 : destination EDGE

    A1 : source AREA
    A2 : destination AREA

    F1, F2 : EDGE  -- for "split" connections, the other side

    joiner_chunk : CHUNK

    door_h : floor height for doors straddling the connection

    backwards : true if travel from R2 --> R1
--]]



CONN_CLASS = {}


function CONN_CLASS.new(kind, R1, R2)
  local C =
  {
    kind = kind
    id   = alloc_id("conn")
    R1   = R1
    R2   = R2
  }

  C.name = string.format("CONN_%d", C.id)

  table.set_class(C, CONN_CLASS)

  table.insert(LEVEL.conns, C)

  return C
end


function CONN_CLASS.kill_it(C)
  table.remove(LEVEL.conns, C)

  C.name = "DEAD_CONN"
  C.kind = "DEAD"
  C.id   = -1

  C.R1  = nil ; C.A1 = nil
  C.R2  = nil ; C.A2 = nil
  C.dir = nil
end


function CONN_CLASS.tostr(C)
  return assert(C.name)
end


function CONN_CLASS.other_area(C, A)
  if A == C.A1 then return C.A2 end
  if A == C.A2 then return C.A1 end

  error("wrong area for CONN_CLASS.other_area")
end


function CONN_CLASS.other_room(C, R)
  if R == C.R1 then return C.R2 end
  if R == C.R2 then return C.R1 end

  error("wrong room for CONN_CLASS.other_room")
end


function CONN_CLASS.edge_for_room(C, R)
  if R == C.R1 then return C.E1, C.F1 end
  if R == C.R2 then return C.E2, C.F2 end

  error("wrong room for CONN_CLASS.edge_for_room")
end


------------------------------------------------------------------------


function Connect_directly(P)
  local kind = P.kind

  gui.debugf("Connection: %s --> %s (via %s)\n", P.R1.name, P.R2.name, kind)

  local C = CONN_CLASS.new(kind, P.R1, P.R2)

  table.insert(C.R1.conns, C)
  table.insert(C.R2.conns, C)


  local S1   = P.S
  local long = P.long

  if P.split then long = P.split end


  assert(kind != "teleporter")

  if kind == "joiner" then
    C.A1 = assert(P.A1)
    C.A2 = assert(P.A2)

    C.joiner_chunk = assert(P.chunk)
    C.joiner_chunk.conn = C

    local dir1 = assert(P.chunk.from_dir)
    local dir2 = assert(P.chunk.dest_dir)

--[[
stderrf("Connect %s/%s --> %s/%s : from_dir:%d  dest_dir:%d\n",
P.R1.name, C.A1.name,
P.R2.name, C.A2.name, dir1, dir2)
--]]

    local E1 = Seed_create_chunk_edge(P.chunk, dir1, "nothing")
    local E2 = Seed_create_chunk_edge(P.chunk, dir2, "nothing")

    -- TODO : this shape check is hacky
    if P.chunk.shape == "I" then
      E1.is_wallish = true
      E2.is_wallish = true
    end

    C.E1 = E1 ; E1.conn = C
    C.E2 = E2 ; E2.conn = C

  else  -- edge connection

    local E1, E2 = Seed_create_edge_pair(P.S, P.dir, long, "arch", "nothing")

--[[
gui.debugf("E1.S = %s  dir = %d  area = %s\n", E1.S.name, E1.dir, E1.S.area.name)
gui.debugf("E2.S = %s  dir = %d  area = %s\n", E2.S.name, E2.dir, E2.S.area.name)
--]]

    C.E1 = E1 ; E1.conn = C
    C.E2 = E2 ; E2.conn = C

    C.A1 = assert(E1.S.area)
    C.A2 = assert(E2.S.area)
  end

--[[
gui.debugf("Creating conn %s from %s --> %s\n", C.name, C.R1.name, C.R2.name)
gui.debugf("  seed %s  dir:%d  long:%d\n", P.S.name, P.dir, P.long)
gui.debugf("  area %s(%s) of %s --> %s(%s) of %s\n",
C.A1.name, C.A1.mode, C.A1.room.name,
C.A2.name, C.A2.mode, C.A2.room.name)
--]]

  assert(C.A1.room == C.R1)
  assert(C.A2.room == C.R2)


  -- handle split connections
  -- [ FIXME : broken, must be done a different way ]
--[[
  if P.split then
    assert(not S1.diagonal)
    local S2 = S1:raw_neighbor(geom.RIGHT[P.dir], P.long - P.split)
    assert(not S2.diagonal)

    local F1, F2 = Seed_create_edge_pair(S2, P.dir, long, "nothing")

    F1.kind = "arch"

    C.F1 = F1 ; F1.conn = C
    C.F2 = F2 ; F2.conn = C
  end
--]]
end



function Connect_teleporter_rooms(P)
  local R1 = P.R1
  local R2 = P.R2

  gui.debugf("Teleporter connection: %s --> %s\n", R1.name, R2.name)

  local C = CONN_CLASS.new("teleporter", R1, R2)

  table.insert(C.R1.conns, C)
  table.insert(C.R2.conns, C)

  table.insert(C.R1.teleporters, C)
  table.insert(C.R2.teleporters, C)

  -- setup tag information
  C.tele_tag1 = alloc_id("tag")
  C.tele_tag2 = alloc_id("tag")

  R1.used_chunks = R1.used_chunks + 1
  R2.used_chunks = R2.used_chunks + 1
end



function Connect_finalize()
  each P in LEVEL.prelim_conns do
    assert(P.kind)

    if P.kind == "teleporter" then
      Connect_teleporter_rooms(P)
    else
      Connect_directly(P)
    end
  end
end

