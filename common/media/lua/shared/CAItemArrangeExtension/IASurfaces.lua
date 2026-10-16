require("IAArrange")
local Utils = require("CAItemArrangeExtension/Utils")

IA = IA or nil

if not IA then return end

local IA = IA

local extend = Utils.extend

--- sprite -> what `IA.surfaces` held before this file first wrote it (false for nothing). every run puts those back
--- first, so a re-run (hot reload) starts from Item Arrange's own surfaces: changed offsets don't stack, and removed
--- or commented-out lines revert.
---@type table<string, table | false>
IA.surfaceOriginals = IA.surfaceOriginals or {}

local originals = IA.surfaceOriginals
local allSurfaces = IA.surfaces

for sprite, original in pairs(originals) do
  allSurfaces[sprite] = original or nil
end

--- `IA.surfaces`, recording the original of every sprite this file writes.
local s = setmetatable({}, {
  __index = allSurfaces,
  __newindex = function (_, sprite, value)
    if originals[sprite] == nil then
      originals[sprite] = allSurfaces[sprite] or false
    end

    allSurfaces[sprite] = value
  end,
})
local sp = IA.surfaceProfile

--- Adds `offsets` to the surface at `index` of a sprite, or to every surface when `index` is nil, see
--- `Utils.modify`. Several calls on one sprite add up: `modifySurfaces("x", { ymin = 0.2, xmax = -0.1 }, 2)`.
---@param sprite  string
---@param offsets table<string, number>
---@param index   integer?
local function modifySurfaces(sprite, offsets, index)
  local current = s[sprite]

  if not current then
    print(string.format("CAItemArrangeExtension: no surfaces to modify for %s", sprite))
    return
  end

  ---@type table<integer, IASurfaceProfile>
  local result = {}
  for i = 1, #current do
    result[i] = (index == nil or index == i) and Utils.modify(current[i], offsets) or current[i]
  end

  s[sprite] = result
end

-- shelves generated from the game's tile geometry, only where nothing above (or Item Arrange) defined a profile.
local generatedSurfaces = require("CAItemArrangeExtension/IASurfaces_Generated")

for spriteName, surfaces in pairs(generatedSurfaces) do
  if not s[spriteName] then
    s[spriteName] = surfaces
  end
end

-- make metal shelves stack just a little bit tighter
sp.metalShelfWEN = {
  [1] = { zmin = 0.041, zmax = 0.35, xmin = 0.25, xmax = 0.90, ymin = 0.35, ymax = 1.00 },
  [2] = { zmin = 0.368, zmax = 0.65, xmin = 0.25, xmax = 0.90, ymin = 0.35, ymax = 1.00 },
  [3] = { zmin = 0.675, zmax = 1.00, xmin = 0.25, xmax = 0.90, ymin = 0.35, ymax = 1.00 },
}
sp.metalShelfWES = {
  [1] = { zmin = 0.041, zmax = 0.35, xmin = 0.25, xmax = 0.90, ymin = 0.00, ymax = 0.95 },
  [2] = { zmin = 0.368, zmax = 0.65, xmin = 0.25, xmax = 0.90, ymin = 0.00, ymax = 0.95 },
  [3] = { zmin = 0.675, zmax = 1.00, xmin = 0.25, xmax = 0.90, ymin = 0.00, ymax = 0.95 },
}
sp.metalShelfNSW = {
  [1] = { zmin = 0.041, zmax = 0.35, xmin = 0.10, xmax = 1.00, ymin = 0.25, ymax = 0.85 },
  [2] = { zmin = 0.368, zmax = 0.65, xmin = 0.10, xmax = 1.00, ymin = 0.25, ymax = 0.85 },
  [3] = { zmin = 0.675, zmax = 1.00, xmin = 0.10, xmax = 1.00, ymin = 0.25, ymax = 0.85 },
}
sp.metalShelfNSE = {
  [1] = { zmin = 0.041, zmax = 0.35, xmin = 0.00, xmax = 0.90, ymin = 0.25, ymax = 0.85 },
  [2] = { zmin = 0.368, zmax = 0.65, xmin = 0.00, xmax = 0.90, ymin = 0.25, ymax = 0.85 },
  [3] = { zmin = 0.675, zmax = 1.00, xmin = 0.00, xmax = 0.90, ymin = 0.25, ymax = 0.85 },
}

s["furniture_shelving_01_24"] = sp.metalShelfWES
s["furniture_shelving_01_25"] = sp.metalShelfWEN
s["furniture_shelving_01_26"] = sp.metalShelfNSW
s["furniture_shelving_01_27"] = sp.metalShelfNSE

-- military crates have a slightly taller appearance
local boxMilitary = { [1] = extend(sp.box[1], { zmin = 0.36 }) }
s["location_military_generic_01_0"] = boxMilitary
s["location_military_generic_01_1"] = boxMilitary
s["location_military_generic_01_8"] = boxMilitary
s["location_military_generic_01_9"] = boxMilitary
-- crafted metal crates
s["constructedobjects_01_44"] = sp.box
s["constructedobjects_01_45"] = sp.box
s["constructedobjects_01_46"] = sp.box
s["constructedobjects_01_47"] = sp.box
-- fancy crafted metal crates
s["crafted_05_44"] = sp.box
s["crafted_05_44"] = sp.box
s["crafted_05_44"] = sp.box
s["crafted_05_44"] = sp.box

-- wood shelves
sp.woodShelvesE = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.07, xmax = 0.43, ymin = 0.10, ymax = 1.00 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.07, xmax = 0.43, ymin = 0.10, ymax = 1.00 },
}
sp.woodShelvesW = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.74, xmax = 0.99, ymin = 0.10, ymax = 1.00 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.74, xmax = 0.99, ymin = 0.10, ymax = 1.00 },
}
sp.woodShelvesS = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.10, xmax = 1.00, ymin = 0.13, ymax = 0.49 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.10, xmax = 1.00, ymin = 0.13, ymax = 0.49 },
}
sp.woodShelvesN = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.10, xmax = 1.00, ymin = 0.63, ymax = 0.99 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.10, xmax = 1.00, ymin = 0.63, ymax = 0.99 },
}

s["furniture_shelving_01_1"] = sp.woodShelvesS
s["furniture_shelving_01_2"] = sp.woodShelvesE
s["furniture_shelving_01_3"] = sp.woodShelvesW
s["furniture_shelving_01_4"] = sp.woodShelvesN

--
sp.largeWallShelvesS = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.12, xmax = 1, ymin = 0.15, ymax = 0.45 },
  [2] = { zmin = 0.379, zmax = 0.60, xmin = 0.12, xmax = 1, ymin = 0.155, ymax = 0.45 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.12, xmax = 1, ymin = 0.17, ymax = 0.45 },
}
sp.largeWallShelvesE = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.19, xmax = 0.45, ymin = 0.15, ymax = 1 },
  [2] = { zmin = 0.382, zmax = 0.60, xmin = 0.19, xmax = 0.45, ymin = 0.15, ymax = 1 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.19, xmax = 0.45, ymin = 0.15, ymax = 1 },
}
sp.largeWallShelvesW = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.55, xmax = 0.81, ymin = 0.00, ymax = 0.85 },
  [2] = { zmin = 0.382, zmax = 0.60, xmin = 0.55, xmax = 0.81, ymin = 0.00, ymax = 0.85 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.55, xmax = 0.81, ymin = 0.00, ymax = 0.85 },
}
sp.largeWallShelvesN = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.00, xmax = 1.00, ymin = 0.55, ymax = 0.85 },
  [2] = { zmin = 0.379, zmax = 0.60, xmin = 0.00, xmax = 1.00, ymin = 0.55, ymax = 0.845 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.00, xmax = 1.00, ymin = 0.55, ymax = 0.83 },
}

s["furniture_shelving_01_9"] = sp.largeWallShelvesS
s["furniture_shelving_01_10"] = sp.largeWallShelvesE
s["furniture_shelving_01_11"] = sp.largeWallShelvesN
s["furniture_shelving_01_12"] = sp.largeWallShelvesW

sp.bigWallCornerShelvesS = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.16, xmax = 0.45, ymin = 0.25, ymax = 1 },
  [2] = { zmin = 0.379, zmax = 0.6, xmin = 0.16, xmax = 0.45, ymin = 0.25, ymax = 1 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.16, xmax = 0.45, ymin = 0.25, ymax = 1 },
}
sp.bigWallCornerShelvesN = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [2] = { zmin = 0.379, zmax = 0.6, xmin = 0, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
}
sp.bigWallCornerShelvesW = {
  [1] = { zmin = 0.05, zmax = 0.34, xmin = 0.68, xmax = 0.95, ymin = 0.15, ymax = 1 },
  [2] = { zmin = 0.35, zmax = 0.6, xmin = 0.65, xmax = 0.95, ymin = 0.15, ymax = 1 },
  [3] = { zmin = 0.64, zmax = 1, xmin = 0.65, xmax = 0.95, ymin = 0.15, ymax = 1 },
}
sp.bigWallCornerShelvesE = {
  [1] = { zmin = 0.059, zmax = 0.34, xmin = 0.15, xmax = 1, ymin = 0.68, ymax = 0.96 },
  [2] = { zmin = 0.379, zmax = 0.6, xmin = 0.15, xmax = 1, ymin = 0.68, ymax = 0.96 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.15, xmax = 1, ymin = 0.68, ymax = 0.96 },
}

-- corners
s["furniture_shelving_01_8"] = sp.bigWallCornerShelvesS -- ^
s["furniture_shelving_01_13"] = sp.bigWallCornerShelvesN -- v
s["furniture_shelving_01_14"] = sp.bigWallCornerShelvesW -- >
s["furniture_shelving_01_15"] = sp.bigWallCornerShelvesE -- <

-- brown fancy wooden bookshelf
sp.bookshelfE = {
  [1] = { zmin = 0.05, zmax = 0.22, xmin = 0.18, xmax = 0.50, ymin = 0.19, ymax = 0.95 },
  [2] = { zmin = 0.344, zmax = 0.50, xmin = 0.25, xmax = 0.50, ymin = 0.19, ymax = 0.95 },
  [3] = { zmin = 0.618, zmax = 0.77, xmin = 0.25, xmax = 0.50, ymin = 0.19, ymax = 0.95 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.15, xmax = 0.50, ymin = 0.15, ymax = 0.95 },
}
sp.bookshelfW = {
  [1] = { zmin = 0.05, zmax = 0.22, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
  [2] = { zmin = 0.32, zmax = 0.49, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
  [3] = { zmin = 0.59, zmax = 0.76, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
}
sp.bookshelfS = {
  [1] = { zmin = 0.055, zmax = 0.22, xmin = 0.096, xmax = 0.95, ymin = 0.18, ymax = 0.55 },
  [2] = { zmin = 0.333, zmax = 0.50, xmin = 0.12, xmax = 0.95, ymin = 0.25, ymax = 0.55 },
  [3] = { zmin = 0.61, zmax = 0.77, xmin = 0.13, xmax = 0.95, ymin = 0.25, ymax = 0.55 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.13, xmax = 0.95, ymin = 0.18, ymax = 0.55 },
}
sp.bookshelfN = {
  [1] = { zmin = 0.05, zmax = 0.22, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [2] = { zmin = 0.32, zmax = 0.49, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [3] = { zmin = 0.59, zmax = 0.76, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
}

s["furniture_shelving_01_40"] = sp.bookshelfS
s["furniture_shelving_01_41"] = sp.bookshelfE
s["furniture_shelving_01_42"] = sp.bookshelfW
s["furniture_shelving_01_43"] = sp.bookshelfN
--
-- this was assigned fridge but this is the white fancy wooden bookshelf
s["furniture_shelving_01_44"] = sp.bookshelfS
s["furniture_shelving_01_45"] = sp.bookshelfE
s["furniture_shelving_01_46"] = sp.bookshelfW
s["furniture_shelving_01_47"] = sp.bookshelfN

---- crafted branch shelves
--sp.craftedBookshelfS = {
--  [1] = { zmin = 0.09, zmax = 0.26, xmin = 0.15, xmax = 0.85, ymin = 0.2, ymax = 0.45 },
--  [2] = { zmin = 0.36, zmax = 0.55, xmin = 0.15, xmax = 0.85, ymin = 0.2, ymax = 0.45 },
--  [3] = { zmin = 0.62, zmax = 0.79, xmin = 0.15, xmax = 0.85, ymin = 0.2, ymax = 0.45 },
--  [4] = { zmin = 0.83, zmax = 1.00, xmin = 0.18, xmax = 0.85, ymin = 0.13, ymax = 0.45 },
--}
--sp.craftedBookshelfW = {
--  [1] = { zmin = 0.09, zmax = 0.26, xmin = 0.55, xmax = 0.80, ymin = 0.15, ymax = 0.85 },
--  [2] = { zmin = 0.36, zmax = 0.55, xmin = 0.55, xmax = 0.80, ymin = 0.15, ymax = 0.85 },
--  [3] = { zmin = 0.62, zmax = 0.79, xmin = 0.55, xmax = 0.80, ymin = 0.15, ymax = 0.85 },
--  [4] = { zmin = 0.83, zmax = 1.00, xmin = 0.55, xmax = 0.87, ymin = 0.18, ymax = 0.85 },
--}
--sp.craftedBookshelfN = {
--  [1] = { zmin = 0.09, zmax = 0.26, xmin = 0.15, xmax = 0.85, ymin = 0.55, ymax = 0.80 },
--  [2] = { zmin = 0.36, zmax = 0.55, xmin = 0.15, xmax = 0.85, ymin = 0.55, ymax = 0.80 },
--  [3] = { zmin = 0.62, zmax = 0.79, xmin = 0.15, xmax = 0.85, ymin = 0.55, ymax = 0.80 },
--  [4] = { zmin = 0.83, zmax = 1.00, xmin = 0.15, xmax = 0.82, ymin = 0.55, ymax = 0.87 },
--}
--sp.craftedBookshelfE = {
--  [1] = { zmin = 0.09, zmax = 0.26, xmin = 0.20, xmax = 0.45, ymin = 0.15, ymax = 0.85 },
--  [2] = { zmin = 0.36, zmax = 0.55, xmin = 0.20, xmax = 0.45, ymin = 0.15, ymax = 0.85 },
--  [3] = { zmin = 0.62, zmax = 0.79, xmin = 0.20, xmax = 0.45, ymin = 0.15, ymax = 0.85 },
--  [4] = { zmin = 0.83, zmax = 1.00, xmin = 0.13, xmax = 0.45, ymin = 0.15, ymax = 0.82 },
--}
--
--s["crafted_04_92"] = sp.craftedBookshelfS
--s["crafted_04_94"] = sp.craftedBookshelfW
--s["crafted_04_93"] = sp.craftedBookshelfN
--s["crafted_04_95"] = sp.craftedBookshelfE


sp.bedsideStandS = {
  [1] = { zmin = 0.355, zmax = 1.000, xmin = 0.18, xmax = 0.9, ymin = 0.15, ymax = 0.65 },
}
sp.bedsideStandE = {
  [1] = { zmin = 0.355, zmax = 1.000, xmin = 0.15, xmax = 0.65, ymin = 0.18, ymax = 0.9 },
}
sp.bedsideStandW = {
  [1] = { zmin = 0.355, zmax = 1.000, xmin = 0.4, xmax = 0.9, ymin = 0.18, ymax = 0.9 },
}
sp.bedsideStandN = {
  [1] = { zmin = 0.355, zmax = 1.000, xmin = 0.18, xmax = 0.9, ymin = 0.4, ymax = 0.9 },
}

-- bedside stand
s["furniture_storage_01_48"] = sp.bedsideStandS
s["furniture_storage_01_49"] = sp.bedsideStandE
s["furniture_storage_01_50"] = sp.bedsideStandW
s["furniture_storage_01_51"] = sp.bedsideStandN

sp.roundTable = {
  [1] = { zmin = 0.281, zmax = 1.000, xmin = 0.2, xmax = 0.87, ymin = 0.2, ymax = 0.9 },
}

s["furniture_tables_high_01_6"] = sp.roundTable
s["furniture_tables_high_01_7"] = sp.roundTable
s["furniture_tables_high_01_14"] = sp.roundTable
s["furniture_tables_high_01_23"] = sp.roundTable

-- toilet
s["fixtures_bathroom_01_0"] = {
  [1] = { zmin = 0.401, zmax = 1.000, xmin = 0.166, xmax = 0.846, ymin = 0.114, ymax = 0.393 },
}

s["fixtures_bathroom_01_1"] = {
  [1] = { zmin = 0.368, zmax = 1.000, xmin = 0.06, xmax = 0.33, ymin = 0.2, ymax = 0.7 },
}

-- bathtub
-- the other orientations mirror (x) or transpose (x <-> y) the 1_26/1_27 pair
-- 25 (faucet end, north) + 24 (end, south): transposed 26/27
s["fixtures_bathroom_01_24"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0.100, xmax = 0.22, ymin = 0, ymax = 0.95 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0.23, xmax = 0.87, ymin = 0.87, ymax = 1 },
  [3] = { zmin = 0.205, zmax = 1.000, xmin = 0.88, xmax = 1, ymin = 0, ymax = 0.95 },
}
s["fixtures_bathroom_01_25"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0.100, xmax = 0.22, ymin = 0.1, ymax = 1 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0.85, xmax = 1, ymin = 0.25, ymax = 1 },
}
-- side with water fixtures on the NE wall
s["fixtures_bathroom_01_26"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0.1, xmax = 1, ymin = 0.100, ymax = 0.22 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0.25, xmax = 1, ymin = 0.85, ymax = 1 },
}
-- end side on the SW wall (opposite 1_26)
s["fixtures_bathroom_01_27"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0, xmax = 0.95, ymin = 0.100, ymax = 0.22 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0.87, xmax = 1, ymin = 0.23, ymax = 0.87 },
  [3] = { zmin = 0.205, zmax = 1.000, xmin = 0, xmax = 0.95, ymin = 0.88, ymax = 1 },
}

-- 52 (faucet end, south) + 53 (end, north): transposed 55/54
s["fixtures_bathroom_01_52"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0.100, xmax = 0.22, ymin = 0, ymax = 0.9 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0.85, xmax = 1, ymin = 0, ymax = 0.75 },
}
s["fixtures_bathroom_01_53"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0.100, xmax = 0.22, ymin = 0.05, ymax = 1 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0.23, xmax = 0.87, ymin = 0, ymax = 0.13 },
  [3] = { zmin = 0.205, zmax = 1.000, xmin = 0.88, xmax = 1, ymin = 0.05, ymax = 1 },
}

-- 55 (faucet end, east) + 54 (end, west): 26/27 mirrored in x
s["fixtures_bathroom_01_54"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0.05, xmax = 1, ymin = 0.100, ymax = 0.22 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0, xmax = 0.13, ymin = 0.23, ymax = 0.87 },
  [3] = { zmin = 0.205, zmax = 1.000, xmin = 0.05, xmax = 1, ymin = 0.88, ymax = 1 },
}
s["fixtures_bathroom_01_55"] = {
  [1] = { zmin = 0.205, zmax = 1.000, xmin = 0, xmax = 0.9, ymin = 0.100, ymax = 0.22 },
  [2] = { zmin = 0.205, zmax = 1.000, xmin = 0, xmax = 0.75, ymin = 0.85, ymax = 1 },
}

-- gym bench
modifySurfaces("furniture_seating_indoor_03_0", { zmin = -0.004 })
modifySurfaces("furniture_seating_indoor_03_1", { zmin = -0.004 })
modifySurfaces("furniture_seating_indoor_03_2", { zmin = -0.004 })
modifySurfaces("furniture_seating_indoor_03_3", { zmin = -0.004 })

-- tiny wooden table with fancy legs
modifySurfaces("furniture_tables_low_01_2", { zmin = -0.0032, ymin = 0.1, xmin=0.05, ymax = -0.05 })

-- tv console
modifySurfaces("furniture_tables_low_01_12", { zmin = -0.005, ymin = 0.08, xmin=0.05, ymax = -0.02, xmax=-0.02 })

-- bathroom cabinet with mirror
modifySurfaces("fixtures_bathroom_01_29", { zmin = -0.022 })

-- crate-sized cardboard box
modifySurfaces("furniture_storage_02_16", { zmin = -0.001 })
