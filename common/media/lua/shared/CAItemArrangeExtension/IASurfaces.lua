require("IAArrange")
local Utils = require("CAItemArrangeExtension/Utils")

IA = IA or nil

if not IA then
  return
end

local IA = IA

local extend = Utils.extend
local modifySurfaces = Utils.modifySurfaces

--- `IA.surfaces`, writing through `Utils.setSurfaces`.
local s = setmetatable({}, {
  __index = IA.surfaces,
  __newindex = function(_, sprite, value)
    Utils.setSurfaces(sprite, value)
  end,
})
local sp = IA.surfaceProfile

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

-- military crates have a slightly taller appearance, at the lid height measured from the tile geometry
local boxMilitary = { [1] = extend(sp.box[1], { zmin = 0.371 }) }
s["location_military_generic_01_0"] = boxMilitary
s["location_military_generic_01_1"] = boxMilitary
s["location_military_generic_01_8"] = boxMilitary
s["location_military_generic_01_9"] = boxMilitary
-- crafted metal crates
s["constructedobjects_01_44"] = sp.box
s["constructedobjects_01_45"] = sp.box
s["constructedobjects_01_46"] = sp.box
s["constructedobjects_01_47"] = sp.box
-- fancy crafted metal crate. 45 and 46 are two and three of them stacked in one sprite, which keep their generated
-- heights
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
modifySurfaces("furniture_tables_low_01_2", { zmin = -0.0032, ymin = 0.1, xmin = 0.05, ymax = -0.05 })

-- tv console
modifySurfaces("furniture_tables_low_01_12", { zmin = -0.005, ymin = 0.08, xmin = 0.05, ymax = -0.02, xmax = -0.02 })

-- bathroom cabinet with mirror
modifySurfaces("fixtures_bathroom_01_29", { zmin = -0.022, xmax = -0.1, ymax = -0.05 })

-- crate-sized cardboard boxes, at the lid height measured from the tile geometry. the game's own surface offset
-- is a bit below the lid, so items would clip into it
local boxCardboard = { [1] = extend(sp.box[1], { zmin = 0.363 }) }
s["furniture_storage_02_16"] = boxCardboard
s["furniture_storage_02_17"] = boxCardboard
s["furniture_storage_02_18"] = boxCardboard
s["furniture_storage_02_19"] = boxCardboard

modifySurfaces(
  "location_community_medical_01_48",
  { xmin = 0.082, xmax = -0.006, ymin = 0.154, ymax = -0.016, zmin = -0.003 }
)
modifySurfaces(
  "location_community_medical_01_50",
  { xmin = 0.082, xmax = -0.006, ymin = 0.154, ymax = -0.016, zmin = -0.003 }
)
--modifySurfaces("location_community_medical_01_49", { xmin = 0.12, xmax = 0.11, ymin = 0.1, ymax = 0.08, zmin = 0.023 })
--modifySurfaces("location_community_medical_01_51", { xmin = 0.12, xmax = 0.11, ymin = 0.1, ymax = 0.08, zmin = 0.023 })
modifySurfaces(
  "location_community_medical_01_49",
  { xmin = 0.21, xmax = 0.01, ymin = 0.13, ymax = 0.03, zmin = -0.003 }
)
modifySurfaces(
  "location_community_medical_01_51",
  { xmin = 0.21, xmax = 0.01, ymin = 0.13, ymax = 0.03, zmin = -0.003 }
)

modifySurfaces("furniture_storage_02_28", { xmin = 0.02, xmax = -0.023, ymin = 0.022, ymax = -0.016, zmin = -0.01 })
modifySurfaces("furniture_storage_02_29", { xmin = 0.001, xmax = -0.037, ymin = 0.028, zmin = -0.006 })
modifySurfaces("furniture_storage_02_30", { xmin = 0.02, xmax = -0.023, ymin = 0.022, ymax = -0.016, zmin = -0.01 })
modifySurfaces("furniture_storage_02_31", { xmin = 0.001, xmax = -0.037, ymin = 0.028, zmin = -0.006 })

-- blue comfy chair
s["furniture_seating_indoor_03_24"] = {
  { zmin = 0.192, zmax = 1, xmin = 0.401, xmax = 0.828, ymin = 0.183, ymax = 0.707 },
}
s["furniture_seating_indoor_03_25"] = {
  { zmin = 0.192, zmax = 1, xmin = 0.201, xmax = 0.742, ymin = 0.415, ymax = 0.877 },
}
s["furniture_seating_indoor_03_27"] = {
  { zmin = 0.192, zmax = 1, xmin = 0.28, xmax = 0.75, ymin = 0.2, ymax = 0.63 },
}
s["furniture_seating_indoor_03_26"] = {
  { zmin = 0.192, zmax = 1, xmin = 0.2, xmax = 0.715, ymin = 0.28, ymax = 0.75 },
}

-- wooden toilet hole
modifySurfaces("fixtures_bathroom_02_24", { xmin = 0.016, xmax = -0.014, ymax = -0.109, zmin = -0.016 })
-- crappy crafted wooden shelves
modifySurfaces("carpentry_02_68", { xmin = 0.012, xmax = 0.005, ymin = 0.048, ymax = -0.014, zmin = -0.006 })
modifySurfaces("carpentry_02_69", { xmin = 0.014, xmax = -0.046, ymin = -0.008, ymax = -0.023, zmin = -0.006 })
modifySurfaces("carpentry_02_70", { xmin = 0.03, xmax = -0.01, ymin = 0.02, ymax = 0.01, zmin = -0.006 })
modifySurfaces("carpentry_02_71", { xmin = 0.011, xmax = -0.014, ymin = 0.05, ymax = -0.022, zmin = -0.006 })
--modifySurfaces("carpentry_02_69", { xmin = 0.012, xmax = 0.005, ymin = 0.048, ymax = -0.014, zmin = -0.006 })
--modifySurfaces("carpentry_02_70", { xmin = 0.012, xmax = 0.005, ymin = 0.048, ymax = -0.014, zmin = -0.006 })
--modifySurfaces("carpentry_02_71", { xmin = 0.012, xmax = 0.005, ymin = 0.048, ymax = -0.014, zmin = -0.006 })

-- tall skinny wooden end table
s["furniture_tables_high_01_4"] = {
  { zmin = 0.315, zmax = 1, xmin = 0.06, xmax = 1, ymin = 0.36, ymax = 0.74 },
}

-- bathroom sink nw
s["fixtures_sinks_01_13"] = {
  { zmin = 0.35, zmax = 1, xmin = 0.15, xmax = 0.51, ymin = 0.2, ymax = 0.29 },
  { zmin = 0.35, zmax = 1, xmin = 0.15, xmax = 0.51, ymin = 0.855, ymax = 0.96 },
}

-- metal sink drinky thing
s["fixtures_sinks_01_25"] = {
  { zmin = 0.336, zmax = 1, xmin = 0.174, xmax = 0.3, ymin = 0.309, ymax = 0.754 },
  { zmin = 0.336, zmax = 1, xmin = 0.174, xmax = 0.59, ymin = 0.749, ymax = 0.794 },
}

-- tiny plastic table
s["furniture_tables_low_01_20"] = {
  { zmin = 0.214, zmax = 1, xmin = 0.109, xmax = 1.01, ymin = 0.207, ymax = 0.872 },
}

-- glass table nw
modifySurfaces("furniture_tables_low_01_8", { xmin = 0.24, ymin = 0.16, ymax = 0.013, zmin = -0.009 })
modifySurfaces("furniture_tables_low_01_9", { xmax = -0.13, ymin = 0.17, ymax = 0.09, zmin = -0.009 })

-- log table sw
modifySurfaces("crafted_02_88", { xmin = 0.034, xmax = 0.079, ymax = -0.05, zmin = -0.007 })
modifySurfaces("crafted_02_89", { xmin = 0.092, xmax = 0.129, ymin = 0.175, zmin = -0.007 })

-- doesnt support stacking so just put an extremely tiny surface
-- shop shelves green side
modifySurfaces("location_shop_generic_01_0", { xmin = -0.06, xmax = -0.96, ymin = 0.86, ymax = 0.02, zmin = 0.05 })
modifySurfaces("location_shop_generic_01_1", { xmin = -0.06, xmax = -0.96, ymin = 0.86, ymax = 0.02, zmin = 0.05 })

-- rotated variants of the entries above

-- log table (rotated)
s["crafted_02_90"] = { -- from crafted_02_88
  { zmin = 0.364, zmax = 1, xmin = 0.05, xmax = 1, ymin = 0.084, ymax = 1.079 },
}
s["crafted_02_91"] = { -- from crafted_02_89
  { zmin = 0.364, zmax = 1, xmin = 0, xmax = 0.775, ymin = 0.142, ymax = 1.129 },
}

-- bathroom cabinet with mirror (rotated)
s["fixtures_bathroom_01_28"] = { -- from fixtures_bathroom_01_29
  { zmin = 0.872, zmax = 1, xmin = 0.14, xmax = 0.773, ymin = 0.055, ymax = 0.408 },
}
s["fixtures_bathroom_01_37"] = { -- from fixtures_bathroom_01_29
  { zmin = 0.872, zmax = 1, xmin = 0.227, xmax = 0.86, ymin = 0.592, ymax = 0.945 },
}

-- wooden toilet hole (rotated)
s["fixtures_bathroom_02_25"] = { -- from fixtures_bathroom_02_24
  { zmin = 0.229, zmax = 1, xmin = 0.109, xmax = 1, ymin = 0.062, ymax = 0.57 },
}
s["fixtures_bathroom_02_26"] = { -- from fixtures_bathroom_02_24
  { zmin = 0.229, zmax = 1, xmin = 0.43, xmax = 0.938, ymin = 0.109, ymax = 1 },
}
s["fixtures_bathroom_02_27"] = { -- from fixtures_bathroom_02_24
  { zmin = 0.229, zmax = 1, xmin = 0, xmax = 0.891, ymin = 0.43, ymax = 0.938 },
}

-- bathroom sink (rotated)
s["fixtures_sinks_01_12"] = { -- from fixtures_sinks_01_13
  { zmin = 0.35, zmax = 1, xmin = 0.71, xmax = 0.8, ymin = 0.15, ymax = 0.51 },
  { zmin = 0.35, zmax = 1, xmin = 0.04, xmax = 0.145, ymin = 0.15, ymax = 0.51 },
}

-- metal sink drinky thing (rotated)
s["fixtures_sinks_01_24"] = { -- from fixtures_sinks_01_25
  { zmin = 0.336, zmax = 1, xmin = 0.246, xmax = 0.691, ymin = 0.174, ymax = 0.3 },
  { zmin = 0.336, zmax = 1, xmin = 0.206, xmax = 0.251, ymin = 0.174, ymax = 0.59 },
}

-- tall skinny wooden end table (rotated)
s["furniture_tables_high_01_5"] = { -- from furniture_tables_high_01_4
  { zmin = 0.315, zmax = 1, xmin = 0.36, xmax = 0.74, ymin = 0, ymax = 0.94 },
}

-- tiny plastic table (rotated)
s["furniture_tables_low_01_21"] = { -- from furniture_tables_low_01_20
  { zmin = 0.214, zmax = 1, xmin = 0.207, xmax = 0.872, ymin = -0.01, ymax = 0.891 },
}

-- glass table (rotated)
s["furniture_tables_low_01_10"] = { -- from furniture_tables_low_01_8
  { zmin = 0.215, zmax = 1, xmin = 0.26, xmax = 0.813, ymin = 0, ymax = 0.41 },
}
s["furniture_tables_low_01_11"] = { -- from furniture_tables_low_01_9
  { zmin = 0.215, zmax = 1, xmin = 0.27, xmax = 0.89, ymin = 0.33, ymax = 1 },
}

-- wall shelves
modifySurfaces("furniture_shelving_01_33", { xmin = 0.07, ymin = 0.04, zmin = -0.008 })
s["furniture_shelving_01_32"] = { -- rotated from furniture_shelving_01_33
  { zmin = 0.592, zmax = 1, xmin = 0.09, xmax = 0.32, ymin = 0, ymax = 0.93 },
}

-- cot
modifySurfaces("furniture_bedding_01_56", { xmin = 0.05, xmax = -0.04, ymax = -0.05, zmin = -0.007 })
s["furniture_bedding_01_59"] = { -- rotated from furniture_bedding_01_56
  { zmin = 0.254, zmax = 1, xmin = 0, xmax = 0.943, ymin = 0.076, ymax = 0.895 },
}

-- bunk bed, both tiles share their heights and y edges
s["furniture_bedding_01_86"] = {
  { zmin = 0.27, zmax = 1, xmin = 0.161, xmax = 1, ymin = 0.16, ymax = 0.99 },
  { zmin = 0.78, zmax = 1, xmin = 0.161, xmax = 1, ymin = 0.16, ymax = 0.99 },
}
s["furniture_bedding_01_87"] = {
  { zmin = 0.27, zmax = 1, xmin = 0, xmax = 0.95, ymin = 0.16, ymax = 0.99 },
  { zmin = 0.78, zmax = 1, xmin = 0, xmax = 0.95, ymin = 0.16, ymax = 0.99 },
}
s["furniture_bedding_01_85"] = { -- rotated from furniture_bedding_01_86
  { zmin = 0.27, zmax = 1, xmin = 0.01, xmax = 0.84, ymin = 0.161, ymax = 1 },
  { zmin = 0.78, zmax = 1, xmin = 0.01, xmax = 0.84, ymin = 0.161, ymax = 1 },
}
s["furniture_bedding_01_84"] = { -- rotated from furniture_bedding_01_87
  { zmin = 0.27, zmax = 1, xmin = 0.01, xmax = 0.84, ymin = 0, ymax = 0.95 },
  { zmin = 0.78, zmax = 1, xmin = 0.01, xmax = 0.84, ymin = 0, ymax = 0.95 },
}

modifySurfaces(
  "furniture_seating_indoor_03_64",
  { xmin = 0.08, xmax = -0.02, ymin = 0.12, ymax = -0.01, zmin = -0.006 }
)
s["furniture_seating_indoor_03_65"] = { -- mirrored from furniture_seating_indoor_03_64, the other half of the bench
  { zmin = 0.186, zmax = 1, xmin = 0.28, xmax = 0.83, ymin = 0.01, ymax = 0.88 },
}
s["furniture_seating_indoor_03_66"] = { -- rotated from furniture_seating_indoor_03_64
  { zmin = 0.186, zmax = 1, xmin = 0.01, xmax = 0.88, ymin = 0.28, ymax = 0.83 },
}
s["furniture_seating_indoor_03_67"] = { -- rotated from furniture_seating_indoor_03_65
  { zmin = 0.186, zmax = 1, xmin = 0.12, xmax = 0.99, ymin = 0.28, ymax = 0.83 },
}

-- beds, all from the blue single bed (furniture_bedding_01_78/79) rotated to each facing, at their own mattress height.
-- the tiles of one bed touch at their inner edges. the oak bed has no measured height, it uses the light wood bed's.
-- Crafted Bed
s["carpentry_02_72"] = { { zmin = 0.226, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["carpentry_02_73"] = { { zmin = 0.226, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["carpentry_02_74"] = { { zmin = 0.226, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["carpentry_02_75"] = { { zmin = 0.226, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }

-- Single Bed with Black Frame
s["furniture_bedding_01_0"] = { { zmin = 0.295, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_1"] = { { zmin = 0.295, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_2"] = { { zmin = 0.295, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_3"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_68"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_69"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }
s["furniture_bedding_01_70"] = { { zmin = 0.295, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_71"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }

-- Double Bed with Black Frame
s["furniture_bedding_01_4"] = { { zmin = 0.295, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_5"] = { { zmin = 0.295, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_6"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_7"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_12"] = { { zmin = 0.295, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_13"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_14"] = { { zmin = 0.295, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_15"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_72"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_73"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 1, ymin = 0.18, ymax = 1 } }
s["furniture_bedding_01_74"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_75"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }
s["furniture_bedding_01_80"] = { { zmin = 0.295, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_81"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_82"] = { { zmin = 0.295, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_83"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }

-- Blue Single Bed
s["furniture_bedding_01_8"] = { { zmin = 0.295, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_9"] = { { zmin = 0.295, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_10"] = { { zmin = 0.295, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_11"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_76"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_77"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }
s["furniture_bedding_01_78"] = { { zmin = 0.295, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_79"] = { { zmin = 0.295, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }

-- Mahogany Double Bed
s["furniture_bedding_01_16"] = { { zmin = 0.293, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_17"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_18"] = { { zmin = 0.293, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_19"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_20"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_21"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 1, ymin = 0.18, ymax = 1 } }
s["furniture_bedding_01_22"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_23"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }
s["furniture_bedding_01_24"] = { { zmin = 0.293, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_25"] = { { zmin = 0.293, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_26"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_27"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_28"] = { { zmin = 0.293, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_29"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_30"] = { { zmin = 0.293, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_31"] = { { zmin = 0.293, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 1 } }

-- Simple Bed
s["furniture_bedding_01_32"] = { { zmin = 0.254, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_33"] = { { zmin = 0.254, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_34"] = { { zmin = 0.254, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_35"] = { { zmin = 0.254, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_60"] = { { zmin = 0.254, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_61"] = { { zmin = 0.254, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_62"] = { { zmin = 0.254, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_63"] = { { zmin = 0.254, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }

-- Maple Double Bed
s["furniture_bedding_01_40"] = { { zmin = 0.301, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_41"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_42"] = { { zmin = 0.301, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_43"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_44"] = { { zmin = 0.301, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_45"] = { { zmin = 0.301, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_46"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_47"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_48"] = { { zmin = 0.301, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_49"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0, ymax = 1 } }
s["furniture_bedding_01_50"] = { { zmin = 0.301, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_51"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_52"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 1, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_53"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 1, ymin = 0.18, ymax = 1 } }
s["furniture_bedding_01_54"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_55"] = { { zmin = 0.301, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }

-- Single Bed with Green Metal Frame
s["furniture_bedding_01_64"] = { { zmin = 0.254, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["furniture_bedding_01_65"] = { { zmin = 0.254, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["furniture_bedding_01_66"] = { { zmin = 0.254, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["furniture_bedding_01_67"] = { { zmin = 0.254, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }

-- Light Wood Bed
s["furniture_bedding_01_88"] = { { zmin = 0.246, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_89"] = { { zmin = 0.246, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_90"] = { { zmin = 0.246, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_91"] = { { zmin = 0.246, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }

-- Oak Bed
s["furniture_bedding_01_92"] = { { zmin = 0.246, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_93"] = { { zmin = 0.246, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }
s["furniture_bedding_01_94"] = { { zmin = 0.246, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["furniture_bedding_01_95"] = { { zmin = 0.246, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }

-- Large Medical Bed
s["location_community_medical_01_16"] = { { zmin = 0.266, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["location_community_medical_01_17"] = { { zmin = 0.266, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["location_community_medical_01_18"] = { { zmin = 0.266, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["location_community_medical_01_19"] = { { zmin = 0.266, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }
s["location_community_medical_01_20"] = { { zmin = 0.266, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["location_community_medical_01_21"] = { { zmin = 0.266, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }
s["location_community_medical_01_22"] = { { zmin = 0.266, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["location_community_medical_01_23"] = { { zmin = 0.266, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }

-- Single Bed with Green Metal Frame
s["location_community_medical_01_72"] = { { zmin = 0.317, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["location_community_medical_01_73"] = { { zmin = 0.317, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["location_community_medical_01_74"] = { { zmin = 0.317, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["location_community_medical_01_75"] = { { zmin = 0.317, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }

-- Prisoner Bed
s["location_community_police_01_24"] = { { zmin = 0.272, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0, ymax = 0.82 } }
s["location_community_police_01_25"] = { { zmin = 0.272, zmax = 1, xmin = 0.15, xmax = 1, ymin = 0.14, ymax = 1 } }
s["location_community_police_01_26"] = { { zmin = 0.272, zmax = 1, xmin = 0.18, xmax = 1, ymin = 0.15, ymax = 1 } }
s["location_community_police_01_27"] = { { zmin = 0.272, zmax = 1, xmin = 0, xmax = 0.86, ymin = 0.15, ymax = 1 } }
s["location_community_police_01_28"] = { { zmin = 0.272, zmax = 1, xmin = 0.14, xmax = 1, ymin = 0, ymax = 0.85 } }
s["location_community_police_01_29"] = { { zmin = 0.272, zmax = 1, xmin = 0, xmax = 0.82, ymin = 0, ymax = 0.85 } }
s["location_community_police_01_30"] = { { zmin = 0.272, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0, ymax = 0.86 } }
s["location_community_police_01_31"] = { { zmin = 0.272, zmax = 1, xmin = 0, xmax = 0.85, ymin = 0.18, ymax = 1 } }

-- countertop soda machine
modifySurfaces("location_shop_accessories_01_9", { xmax = -0.06, ymax = -0.02, zmin = -0.008 })

-- seahorse cafe cooled display fridge, two tiles wide. measured on the left half facing S (the shelf runs 0.16-0.58 from
-- the back, with a 0.08 rim at the outer end); the other halves and angles are that same shelf rotated
-- S: 56 left, 57 right
s["location_restaurant_seahorse_01_56"] = {
  { zmin = 0.416, zmax = 1, xmin = 0.08, xmax = 1, ymin = 0.16, ymax = 0.58 },
}
s["location_restaurant_seahorse_01_57"] = {
  { zmin = 0.416, zmax = 1, xmin = 0, xmax = 0.92, ymin = 0.16, ymax = 0.58 },
}
-- E: 59 north, 58 south
s["location_restaurant_seahorse_01_59"] = {
  { zmin = 0.416, zmax = 1, xmin = 0.16, xmax = 0.58, ymin = 0.08, ymax = 1 },
}
s["location_restaurant_seahorse_01_58"] = {
  { zmin = 0.416, zmax = 1, xmin = 0.16, xmax = 0.58, ymin = 0, ymax = 0.92 },
}
-- W: 61 north, 60 south
s["location_restaurant_seahorse_01_61"] = {
  { zmin = 0.416, zmax = 1, xmin = 0.42, xmax = 0.84, ymin = 0.08, ymax = 1 },
}
s["location_restaurant_seahorse_01_60"] = {
  { zmin = 0.416, zmax = 1, xmin = 0.42, xmax = 0.84, ymin = 0, ymax = 0.92 },
}
-- N: 62 west, 63 east
s["location_restaurant_seahorse_01_62"] = {
  { zmin = 0.416, zmax = 1, xmin = 0.08, xmax = 1, ymin = 0.42, ymax = 0.84 },
}
s["location_restaurant_seahorse_01_63"] = {
  { zmin = 0.416, zmax = 1, xmin = 0, xmax = 0.92, ymin = 0.42, ymax = 0.84 },
}

-- big tall shop fridge, two tiles wide. measured on the left half facing S: 0.01 further out at the outer end, 0.02 off
-- the back, 0.05 off the front and 0.011 lower. the other halves and angles get that same tweak rotated
-- S: 18 left, 19 right
modifySurfaces("appliances_refrigeration_01_18", { xmin = -0.01, ymin = 0.02, ymax = -0.05, zmin = -0.011 })
modifySurfaces("appliances_refrigeration_01_19", { xmax = 0.01, ymin = 0.02, ymax = -0.05, zmin = -0.011 })
-- E: 17 north, 16 south
modifySurfaces("appliances_refrigeration_01_17", { ymin = -0.01, xmin = 0.02, xmax = -0.05, zmin = -0.011 })
modifySurfaces("appliances_refrigeration_01_16", { ymax = 0.01, xmin = 0.02, xmax = -0.05, zmin = -0.011 })
-- W: 45 north, 44 south
modifySurfaces("appliances_refrigeration_01_45", { ymin = -0.01, xmax = -0.02, xmin = 0.05, zmin = -0.011 })
modifySurfaces("appliances_refrigeration_01_44", { ymax = 0.01, xmax = -0.02, xmin = 0.05, zmin = -0.011 })
-- N: 46 west, 47 east
modifySurfaces("appliances_refrigeration_01_46", { xmin = -0.01, ymax = -0.02, ymin = 0.05, zmin = -0.011 })
modifySurfaces("appliances_refrigeration_01_47", { xmax = 0.01, ymax = -0.02, ymin = 0.05, zmin = -0.011 })

-- metal counter S
s["fixtures_counters_01_37"] = {
  { zmin = 0.375, zmax = 1, xmin = 0, xmax = 1, ymin = 0.12, ymax = 0.7, facing = "S" },
  -- floor below
  { zmin = 0.000, zmax = 0.15, xmin = 0, xmax = 1, ymin = 0.12, ymax = 0.61 },
}
-- the other angles are the S counter rotated: the top runs 0.12-0.7 from the back, the floor below 0.12-0.61
s["fixtures_counters_01_33"] = { -- N
  { zmin = 0.375, zmax = 1,    xmin = 0,    xmax = 1,    ymin = 0.3,  ymax = 0.88, facing = "N" },
  { zmin = 0.000, zmax = 0.15, xmin = 0,    xmax = 1,    ymin = 0.39, ymax = 0.88 },
}
s["fixtures_counters_01_35"] = { -- E
  { zmin = 0.375, zmax = 1,    xmin = 0.12, xmax = 0.7,  ymin = 0,    ymax = 1, facing = "E" },
  { zmin = 0.000, zmax = 0.15, xmin = 0.12, xmax = 0.61, ymin = 0,    ymax = 1 },
}
s["fixtures_counters_01_39"] = { -- W
  { zmin = 0.375, zmax = 1,    xmin = 0.3,  xmax = 0.88, ymin = 0,    ymax = 1, facing = "W" },
  { zmin = 0.000, zmax = 0.15, xmin = 0.39, xmax = 0.88, ymin = 0,    ymax = 1 },
}

-- straight counters get the metal counter's top. the counters' fronts overhang their cabinets, so the top runs 0.12-0.7
-- from the back across the whole tile and neighbouring pieces line up. they're all drawn as high as the metal one,
-- even the ones whose Surface property is lower
---@param zmin number
---@return table<string, table<integer, IASurfaceProfile>>
local function counterTops(zmin)
  return {
    S = { { zmin = zmin, xmin = 0, xmax = 1, ymin = 0.12, ymax = 0.7, facing = "S" } },
    N = { { zmin = zmin, xmin = 0, xmax = 1, ymin = 0.3, ymax = 0.88, facing = "N" } },
    E = { { zmin = zmin, xmin = 0.12, xmax = 0.7, ymin = 0, ymax = 1, facing = "E" } },
    W = { { zmin = zmin, xmin = 0.3, xmax = 0.88, ymin = 0, ymax = 1, facing = "W" } },
  }
end

local counterTop = counterTops(0.375)

local NEXT_FACING = { N = "E", E = "S", S = "W", W = "N" }
local BACK_EDGE = { N = "ymax", E = "xmin", S = "ymin", W = "xmax" }
local FRONT_EDGE = { N = "ymin", E = "xmax", S = "ymax", W = "xmin" }

-- a corner joins the top of its own facing to the next facing clockwise: the first runs up to the back of the second,
-- the second fills the rest of the tile in front of the first
---@param tops   table<string, table<integer, IASurfaceProfile>>
---@param facing string
---@return table<integer, IASurfaceProfile>
local function cornerTop(tops, facing)
  local other = NEXT_FACING[facing]
  local front = FRONT_EDGE[facing]
  local result = {}

  for i = 1, #tops[facing] do
    local first = extend(tops[facing][i], {})
    local second = extend(tops[other][i], {})

    first[BACK_EDGE[other]] = second[BACK_EDGE[other]]
    second[BACK_EDGE[facing]] = first[front]
    second[front] = front:sub(2) == "min" and 0 or 1
    second.facing = facing
    result[#result + 1] = first
    result[#result + 1] = second
  end

  return result
end

-- sets of 8 with a corner and a straight piece per facing, the straight one is the odd index. facings in sprite order
local COUNTER_SETS = {
  { "fixtures_counters_01", { 0, 8, 40, 48, 56, 64, 72, 192 }, "NESW" },
  { "carpentry_02", { 16, 24, 32 }, "NESW" },
  { "crafted_05", { 24 }, "NESW" },
  { "location_entertainment_theatre_01", { 8 }, "NESW" },
  { "location_restaurant_diner_01", { 24 }, "NESW" },
  { "location_restaurant_pie_01", { 40 }, "NESW" },
  { "location_restaurant_pizzawhirled_01", { 32 }, "NESW" },
  { "location_restaurant_seahorse_01", { 40 }, "NESW" },
  { "location_restaurant_spiffos_01", { 56 }, "NESW" },
  { "location_shop_fossoil_01", { 16 }, "NESW" },
  { "location_shop_gas2go_01", { 16 }, "NESW" },
  { "location_shop_generic_01", { 16 }, "NESW" },
  { "location_shop_zippee_01", { 16 }, "NESW" },
}

for i = 1, #COUNTER_SETS do
  local sheet, bases, facings = COUNTER_SETS[i][1], COUNTER_SETS[i][2], COUNTER_SETS[i][3]

  for j = 1, #bases do
    for k = 1, 4 do
      local facing = facings:sub(k, k)
      s[sheet .. "_" .. (bases[j] + k * 2 - 2)] = cornerTop(counterTop, facing)
      s[sheet .. "_" .. (bases[j] + k * 2 - 1)] = counterTop[facing]
    end
  end
end

local metalCounter = {
  N = s["fixtures_counters_01_33"],
  E = s["fixtures_counters_01_35"],
  S = s["fixtures_counters_01_37"],
  W = s["fixtures_counters_01_39"],
}

for k, facing in ipairs({ "N", "E", "S", "W" }) do
  s["fixtures_counters_01_" .. (30 + k * 2)] = cornerTop(metalCounter, facing)
end

-- single pieces without corners
s["location_entertainment_theatre_01_0"] = counterTop.E
s["location_entertainment_theatre_01_1"] = counterTop.S
s["location_entertainment_theatre_01_2"] = counterTop.W
s["location_entertainment_theatre_01_3"] = counterTop.N
s["location_entertainment_theatre_01_4"] = counterTop.N
s["location_entertainment_theatre_01_5"] = counterTop.E
s["location_entertainment_theatre_01_6"] = counterTop.S
s["location_entertainment_theatre_01_7"] = counterTop.W
s["location_hospitality_sunstarmotel_02_12"] = counterTop.N
s["location_hospitality_sunstarmotel_02_13"] = counterTop.E
s["location_hospitality_sunstarmotel_02_14"] = counterTop.S
s["location_hospitality_sunstarmotel_02_15"] = counterTop.W
s["location_trailer_02_16"] = counterTop.S
s["location_trailer_02_17"] = counterTop.E
s["location_trailer_02_18"] = counterTop.S
s["location_trailer_02_19"] = counterTop.E
s["location_trailer_02_20"] = counterTop.N
s["location_trailer_02_21"] = counterTop.W

-- the glass display case is drawn on the front half of its tile
s["location_shop_generic_01_97"] = { { zmin = 0.375, xmin = 0, xmax = 1, ymin = 0.48, ymax = 0.98, facing = "S" } }
s["location_shop_generic_01_101"] = { { zmin = 0.375, xmin = 0, xmax = 1, ymin = 0.02, ymax = 0.52, facing = "N" } }
s["location_shop_generic_01_103"] = { { zmin = 0.375, xmin = 0.48, xmax = 0.98, ymin = 0, ymax = 1, facing = "E" } }
s["location_shop_generic_01_99"] = { { zmin = 0.375, xmin = 0.02, xmax = 0.52, ymin = 0, ymax = 1, facing = "W" } }

-- bars are taller, each at its own height
local BAR_SETS = { { 0, 0.478 }, { 16, 0.498 }, { 56, 0.487 } }

for i = 1, #BAR_SETS do
  local tops = counterTops(BAR_SETS[i][2])

  for k, facing in ipairs({ "N", "W", "S", "E" }) do
    s["location_restaurant_bar_01_" .. (BAR_SETS[i][1] + k * 2 - 2)] = cornerTop(tops, facing)
    s["location_restaurant_bar_01_" .. (BAR_SETS[i][1] + k * 2 - 1)] = tops[facing]
  end
end

-- two-tile bank counters, height from the game's tile geometry. the oak tops run behind the panel standing on them,
-- the plain tops only cover the front of their tile. pairs are listed west/north piece first
local BANK_Z = 0.404
local bankTops = {
  -- oak, with panels
  { 26, 27, 0.05, { ymin = 0.08, ymax = 0.8, facing = "S" } },
  { 30, 31, 0.05, { ymin = 0.2, ymax = 0.92, facing = "N" } },
  { 25, 24, 0.05, { xmin = 0.08, xmax = 0.8, facing = "E" } },
  { 29, 28, 0.05, { xmin = 0.2, xmax = 0.92, facing = "W" } },
  -- plain
  { 58, 59, 0.08, { ymin = 0.32, ymax = 1, facing = "S" } },
  { 62, 63, 0.08, { ymin = 0, ymax = 0.68, facing = "N" } },
  { 57, 56, 0.08, { xmin = 0.32, xmax = 1, facing = "E" } },
  { 61, 60, 0.08, { xmin = 0, xmax = 0.68, facing = "W" } },
}

for i = 1, #bankTops do
  local first, second, inset, rect = bankTops[i][1], bankTops[i][2], bankTops[i][3], bankTops[i][4]
  local alongX = rect.ymin ~= nil
  local a = extend({ zmin = BANK_Z }, rect)
  local b = extend({ zmin = BANK_Z }, rect)

  if alongX then
    a.xmin, a.xmax, b.xmin, b.xmax = inset, 1, 0, 1 - inset
  else
    a.ymin, a.ymax, b.ymin, b.ymax = inset, 1, 0, 1 - inset
  end

  s["location_business_bank_01_" .. first] = { a }
  s["location_business_bank_01_" .. second] = { b }
end

-- the other wood finish of each bank counter is drawn the same, 8 sprites away
for i = 24, 31 do
  s["location_business_bank_01_" .. (i + 8)] = s["location_business_bank_01_" .. i]
end

for i = 56, 63 do
  s["location_business_bank_01_" .. (i - 8)] = s["location_business_bank_01_" .. i]
end

s["location_shop_generic_01_13"] = {
  { zmin = 0.333, zmax = 1, xmin = 0.48, xmax = 0.72, ymin = 0, ymax = 1 },
  { zmin = 0.183, zmax = 0.29, xmin = 0.48, xmax = 0.72, ymin = 0, ymax = 1 },
  { zmin = 0.043, zmax = 0.14, xmin = 0.48, xmax = 0.72, ymin = 0, ymax = 1 },
}
s["location_shop_generic_01_14"] = {
  { zmin = 0.333, zmax = 1, xmin = 0.48, xmax = 0.72, ymin = 0, ymax = 1 },
  { zmin = 0.183, zmax = 0.29, xmin = 0.48, xmax = 0.72, ymin = 0, ymax = 1 },
  { zmin = 0.043, zmax = 0.14, xmin = 0.48, xmax = 0.72, ymin = 0, ymax = 1 },
}
