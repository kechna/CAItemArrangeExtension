require("IAArrange")

local IA = IA or nil

if not IA then return end

-- boards on a wall that items can be shift+dropped onto, per sprite in the square's own coordinates. extents are of
-- the board as drawn on the wall, measured from the sprite's texture inside its frame

---@class IAWallSurface
---@field wall  "N" | "W" the wall the board hangs on, facing S or E
---@field plane number how far in front of the wall items hang. the wall sprite hides 3d items closer than ~0.13 to it
---@field min   number extent along the wall (x for N, y for W)
---@field max   number
---@field zmin  number bottom
---@field zmax  number top
---@field depth number how far stacks may stick out of the board

---@type table<string, IAWallSurface>
local w = {}

local function board(wall, plane, min, max, zmin, zmax, depth)
  return { wall = wall, plane = plane, min = min, max = max, zmin = zmin, zmax = zmax, depth = depth or 0.08 }
end

-- cork notice boards
w["location_business_office_generic_01_7"] = board("N", 0.15, -0.02, 0.87, 0.41, 0.65)
w["location_business_office_generic_01_38"] = board("N", 0.15, 0.24, 0.9, 0.37, 0.71)
w["location_business_office_generic_01_39"] = board("N", 0.15, -0.07, 0.63, 0.37, 0.71)
w["location_business_office_generic_01_15"] = board("W", 0.15, 0.01, 0.88, 0.42, 0.66)
w["location_business_office_generic_01_36"] = board("W", 0.15, -0.04, 0.66, 0.37, 0.71)
w["location_business_office_generic_01_37"] = board("W", 0.15, 0.27, 0.93, 0.37, 0.71)

-- wood pegboards, two tiles wide
w["location_business_machinery_01_24"] = board("N", 0.15, 0.24, 0.92, 0.39, 0.68)
w["location_business_machinery_01_25"] = board("N", 0.15, -0.04, 0.79, 0.39, 0.68)
w["location_business_machinery_01_27"] = board("W", 0.15, 0.27, 0.95, 0.39, 0.68)
w["location_business_machinery_01_26"] = board("W", 0.15, -0.01, 0.82, 0.39, 0.68)

IA.wallSurfaces = w
