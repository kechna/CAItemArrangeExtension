IA = IA or {}

local IA = IA

local ap = IA.arrangableProfile
local mp = IA.meshProfiles

--- keys this file added to `IA.meshProfiles` and `IA.surfaces` on its last run. they're cleared first, so a hot
--- reload also drops entries that were removed or commented out, and generated surfaces can fill those gaps again.
IAE_DataKeys = IAE_DataKeys or { meshProfiles = {}, surfaces = {} }

---@param target table
---@param keys   table<string, boolean>
local function forgetKeys(target, keys)
  for key in pairs(keys) do
    target[key] = nil
  end
end

---@param target table
---@return table<string, boolean>
local function snapshotKeys(target)
  local keys = {}

  for key in pairs(target) do
    keys[key] = true
  end

  return keys
end

forgetKeys(mp, IAE_DataKeys.meshProfiles)
forgetKeys(IA.surfaces, IAE_DataKeys.surfaces)

-- entries from Item Arrange itself or other mods, never cleared
local foreignMeshProfiles = snapshotKeys(mp)
local foreignSurfaces = snapshotKeys(IA.surfaces)

---@generic T  extends table
---@generic T2 extends T
---@param profile T
---@param fields  Partial<T2>
---@return T
local function extend(profile, fields)
  local newProfile = {}
  for k, v in pairs(profile) do
    newProfile[k] = v
  end
  for k, v in pairs(fields) do
    newProfile[k] = v
  end
  ---@cast newProfile T
  return newProfile
end

--
-- Arrangable profiles
--
ap.anvilMold          = { dx = 0.26, dy = 0.36, dz = 0.075 }
ap.anvilMoldCast      = { dx = 0.26, dy = 0.4, dz = 0.06 }
ap.bagConcretePowder  = { dx = 0.3, dy = 0.18, dz = 0.16, qz = 1 }
ap.bbqSauce           = { dx = 0.15, dy = 0.08, dz = 0.09, qz = 1, fz = -90 }
ap.bigHikingBag       = { dx = 0.32, dy = 0.32, dz = 0.2, qz = 1, fx = -262, fz = 270, mz = 0.11, my = 0.18 }
ap.bleachBottle       = { dx = 0.1, dy = 0.16, dz = 0.11, qz = 1, fz = 180 }
ap.bowl               = { dx = 0.19, dy = 0.19, dz = 0.025, qz = 6 }
ap.bowlFull           = { dx = 0.19, dy = 0.19, dz = 0.04, qz = 1 }
ap.bowlFull2          = { dx = 0.22, dy = 0.22, dz = 0.04, qz = 1 } -- brain tan bowl is slightly bigger
ap.breadSlice         = { dx = 0.038, dy = 0.055, dz = 0.0022, qz = 10, fz = -10 }
ap.breadSlices        = { dx = 0.23, dy = 0.21, dz = 0.0078, qz = 6, fz = -10 }
ap.brochure           = { dx = 0.1, dy = 0.17, dz = 0.03, qz = 1, fx = 90, mz = 0.054, fy = 270 }
ap.carSeat            = { dx = 0.5, dy = 0.45, dz = 0.25, qz = 1 }
ap.cartonWide         = { dx = 0.12, dy = 0.09, dz = 0.015, qz = 1, fz = 180 }
ap.ceramicIngotCast   = { dx = 0.15, dy = 0.31, dz = 0.032, qz = 4 }
ap.cooler             = { dx = 0.25, dy = 0.44, dz = 0.17, qz = 1 }
ap.cutlery            = { dx = 0.06, dy = 0.33, dz = 0.006, qz = 1, fz = -90, my = -0.04 }
ap.duffelBag          = { dx = 0.29, dy = 0.76, dz = 0.1, qz = 1 }
ap.fabricRoll         = { dx = 0.15, dy = 0.65, dz = 0.055, qz = 4, fz = 90 }
ap.flask              = { dx = 0.12, dy = 0.05, dz = 0.05, qz = 1, fz = -90 }
ap.flier              = { dx = 0.12, dy = 0.26, dz = 0.003, qz = 20 }
ap.flour              = { dx = 0.35, dy = 0.33, dz = 0.1, qz = 1, fz = -90 }
ap.frozenFoodBag      = { dx = 0.23, dy = 0.42, dz = 0.024, qz = 4, fz = 90 }
ap.gasTank            = { dx = 0.63, dy = 0.56, dz = 0.085, qz = 2, my = -0.07 }
ap.granolaBar         = { dx = 0.09, dy = 0.23, dz = 0.018, qz = 4, fz = 90 }
ap.hideRolledDeer     = { dx = 0.11, dy = 0.65, dz = 0.032, qz = 4 }
ap.hikingBag          = { dx = 0.32, dy = 0.32, dz = 0.18, qz = 1, fx = -262, fz = 270, mz = 0.11, my = 0.18 }
ap.jar                = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 45 }
ap.jarTall            = { dx = 0.15, dy = 0.15, dz = 0.078, qz = 2 }
ap.leatherRoll        = { dx = 0.12, dy = 0.65, dz = 0.046, qz = 4 }
ap.lightBulb          = { dx = 0.11, dy = 0.12, dz = 0.02, qz = 1, fz = 90 }
ap.macAndCheese       = { dx = 0.18, dy = 0.1, dz = 0.095, qz = 2 }
ap.marinara           = { dx = 0.12, dy = 0.12, dz = 0.05 }
ap.militaryBackpack   = { dx = 0.4, dy = 0.32, dz = 0.2, fy = 342, fz = -90, my = 0.08, mz = -0.008, qz = 1 }
ap.muffler            = { dx = 0.24, dy = 0.5, dz = 0.042, qz = 4, fz = 90 }
ap.pizza              = { dx = 0.45, dy = 0.45, dz = 0.013, qz = 5 }
ap.pizzaSlice         = { dx = 0.25, dy = 0.24, dz = 0.0115, qz = 5 }
ap.potFull            = { dx = 0.40, dy = 0.40, dz = 0.10, qz = 1 }
ap.pouch              = { dx = 0.2, dy = 0.07, dz = 0.1, qz = 1 }
ap.sandBag            = { dx = 0.33, dy = 0.6, dz = 0.04, qz = 3, fz = 90 }
ap.sauce              = { dx = 0.17, dy = 0.08, dz = 0.09, qz = 1 }
ap.saucePan           = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = -90 }
ap.saucePanCopper     = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = 0 }
ap.saucePanCopperFull = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = 0 }
ap.saucePanFull       = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = -90 }
ap.smallBackpack      = { dx = 0.31, dy = 0.18, dz = 0.14, fy = 90, fz = 270, mz = 0.08, my = -0.07, qz = 1 }
ap.sponge             = { dx = 0.115, dy = 0.165, dz = 0.026, qz = 6, fz = 90 }
ap.suspension         = { dx = 0.28, dy = 0.44, dz = 0.04, qz = 1, fz = 90, my = -0.05 }
ap.tarp               = { dx = 0.44, dy = 0.52, dz = 0.03, qz = 5 }
ap.tinyBottle         = { dx = 0.075, dy = 0.075, dz = 0.03, qz = 1 }
ap.toiletPaper        = { dx = 0.16, dy = 0.16, dz = 0.06, qz = 3 }
ap.toothpaste         = { dx = 0.1, dy = 0.24, dz = 0.02, qz = 3 }
ap.trunkLid           = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8 }
ap.windshield         = { dx = 0.75, dy = 0.35, dz = 0.014, qz = 8 }
ap.wineBox            = { dx = 0.15, dy = 0.1, dz = 0.096, qz = 2 }
ap.woodenIngotMold    = { dx = 0.2, dy = 0.36, dz = 0.038, qz = 4 }

ap.weaponLong         = { dx = 0.13, dy = 0.7, dz = 0.16, qz = 1, fz = 270 }
ap.weaponLongWide     = extend(ap.weaponLong, { dx = 0.25 })
ap.weaponShort        = extend(ap.weaponLong, { dy = 0.4 })
ap.weaponShortWide    = extend(ap.weaponShort, { dy = 0.2 })

--
-- Mesh profiles
--

-- Thanks to @CouncilOfPoorlyLitBaldPeople. Yes, I'm crediting you anyway :P
mp["ammo/boxes/Ammobox"] = "ammoBox"
mp["ammo/boxes/Ammobox_Rifle_Small"] = "ammoBox"
mp["ammo/boxes/Ammobox_Shotgun"] = "shotgunShellsBox"
mp["weapons/ammo/762-556-308-223AmmoBox"] = "ammoBox"

-- By me

-- cutlery
--mp["weapons/1handed/BreadKnife"]                     = "cutlery"
--mp["weapons/1handed/ButterflyKnife"]                 = "cutlery"
--mp["weapons/1handed/ButterflyKnife2"]                = "cutlery"
--mp["weapons/1handed/ButterKnife"]                    = { p = "cutlery", my = -0.02 }
--mp["weapons/1handed/Chisel_Forged_Hand"]             = "cutlery"
--mp["weapons/1handed/Chisel_Hot_Hand"]                = "cutlery"
--mp["weapons/1handed/Fork"]                           = { p = "cutlery", my = 0.1 }
--mp["weapons/1handed/Fork_Bone_Hand"]                 = { p = "cutlery", my = 0.1 }
--mp["weapons/1handed/Fork_Forged_Hand"]               = { p = "cutlery", my = 0.1 }
--mp["weapons/1handed/Fork_Wood_Hand"]                 = { p = "cutlery", my = 0.1, fz = 90 }
--mp["weapons/1handed/KitchenKnife_Forged_Hand"]       = "cutlery"
--mp["weapons/1handed/Knife"]                          = { p = "cutlery", my = -0.02 }
--mp["weapons/1handed/Knife_Bone_Hand"]                = { p = "cutlery", my = -0.02 }
--mp["weapons/1handed/Knife_Fillet_Hand"]              = "cutlery"
--mp["weapons/1handed/KnifeHunting_Forged_Basic_Hand"] = "cutlery"
--mp["weapons/1handed/KnifeHunting_Forged_Hand"]       = "cutlery"
--mp["weapons/1handed/KnifeKitchen_Forged_Hand"]       = "cutlery"
--mp["weapons/1handed/KnifeParing_Hand"]               = "cutlery"
--mp["weapons/1handed/Pen"]                            = "cutlery"
--mp["weapons/1handed/Pencil"]                         = "cutlery"
--mp["weapons/1handed/PenKnife"]                       = "cutlery"
--mp["weapons/1handed/PenKnife2"]                      = "cutlery"
--mp["weapons/1handed/Plastic_Fork_Hand"]              = { p = "cutlery", my = 0.1, fz = 90 }
--mp["weapons/1handed/Plastic_Knife_Hand"]             = { p = "cutlery", my = 0.1 }
--mp["weapons/1handed/Plastic_Spoon_Hand"]             = { p = "cutlery", my = 0.1, fz = 90 }
--mp["weapons/1handed/Scalpel"]                        = "cutlery"
--mp["weapons/1handed/Screwdriver"]                    = "cutlery"
--mp["weapons/1handed/ShankGlass_Hand"]                = "cutlery"
--mp["weapons/1handed/Shiv"]                           = "cutlery"
--mp["weapons/1handed/Shiv2"]                          = "cutlery"
--mp["weapons/1handed/Shiv_Spear_Crude_Hand"]          = "cutlery"
--mp["weapons/1handed/Shiv_SpearCrude_Longer_Hand"]    = "cutlery"
--mp["weapons/1handed/Shiv_SpearStone_High_Hand"]      = "cutlery"
--mp["weapons/1handed/Shiv_SpearStoneBasic_Head_Hand"] = "cutlery"
--mp["weapons/1handed/Spoon"]                          = { p = "cutlery", my = 0.1 }
--mp["weapons/1handed/Spoon_Bone_Hand"]                = { p = "cutlery", my = 0.1 }
--mp["weapons/1handed/Spoon_Forged_Hand"]              = { p = "cutlery", my = 0.1 }
--mp["weapons/1handed/Spoon_Wood_Hand"]                = { p = "cutlery", my = 0.1 }
--mp["WorldItems/Spork"]                               = "cutlery"

-- items
mp["BleachBottle"]                                 = "bleachBottle"
mp["CaffinePills"]                                 = { p = "seasoningJar", s = 0.13 }
mp["Jar"]                                          = { p = "jar", s = 0.4 }
mp["PillBottle"]                                   = { p = "jar", s = 1.56 }
mp["WorldItems/BagofConcretePowder"]               = { p = "bagConcretePowder", s = 0.2 }
mp["WorldItems/BalsamicVinegar"]                   = "wineBottle"
mp["WorldItems/BBQ_Sauce"]                         = "bbqSauce"
mp["WorldItems/Bottle"]                            = "wineBottle"
mp["WorldItems/Bowl"]                              = "bowl"
mp["WorldItems/Bowl_Kiln"]                         = "bowl"
mp["WorldItems/Bowl_Kiln_Full"]                    = "bowlFull"
mp["WorldItems/BowlFood"]                          = "bowlFull"
mp["WorldItems/BowlOfGlaze"]                       = { p = "bowlFull2", s = 0.5 }
mp["WorldItems/BowlRamen"]                         = "bowlFull"
mp["WorldItems/BowlSoup"]                          = "bowlFull"
mp["WorldItems/BrakeDisk"]                         = { p = "pizza", s = 0.6, dz = 0.0175, qz = 4 }
mp["WorldItems/BreadSlices"]                       = { p = "breadSlices", s = 0.3 }
mp["WorldItems/Brochure"]                          = { p = "brochure", s = 0.125 }
mp["WorldItems/CannedSardinesOpen"]                = { p = "sardinesTin", qz = 1 }
mp["WorldItems/CarBumper"]                         = { p = "trunkLid", s = 0.25 }
mp["WorldItems/CarDoor"]                           = { p = "trunkLid", s = 0.25, dz = 0.018 }
mp["WorldItems/CarHood"]                           = "trunkLid"
mp["WorldItems/CarJack"]                           = { p = "trunkLid", s = 0.25 }
mp["WorldItems/CarParts"]                          = { p = "trunkLid", s = 0.25 }
mp["WorldItems/CarSeat"]                           = { p = "carSeat", s = 0.4 }
mp["WorldItems/CarTrunkLid"]                       = { p = "trunkLid", s = 0.25 }
mp["WorldItems/CarWindshield"]                     = { p = "windshield", s = 0.25 }
mp["WorldItems/Ceramic_IngotCast"]                 = { p = "ceramicIngotCast", s = 0.09 }
mp["WorldItems/CeramicCast_AnvilBlock"]            = { p = "anvilMold", s = 0.13 }
mp["WorldItems/CeramicMold_AnvilJeweller"]         = { p = "anvilMoldCast", s = 0.1 }
mp["WorldItems/CleaningLiquid"]                    = { p = "sauce", s = 0.5 }
mp["WorldItems/Clothing/ALICE_Pack_Ground"]        = "militaryBackpack"
mp["WorldItems/Clothing/BigHikingBag_Ground"]      = "bigHikingBag"
mp["WorldItems/Clothing/Briefcase"]                = "briefcase"
mp["WorldItems/Clothing/Cooler_Ground"]            = "cooler"
mp["WorldItems/Clothing/DuffelBag_Ground"]         = "duffelBag"
mp["WorldItems/Clothing/HikingBag_Ground"]         = "hikingBag"
mp["WorldItems/Clothing/SandBag_Ground"]           = "sandBag"
mp["WorldItems/Clothing/SchoolBag_Ground"]         = "smallBackpack"
mp["WorldItems/CookingPotFull"]                    = "potFull"
mp["WorldItems/Cornmeal"]                          = { p = "pouch", s = 0.126 }
mp["WorldItems/DipJar"]                            = { p = "jar", dz = 0.039, s = 0.12, fz = -180 }
mp["WorldItems/DirtBag"]                           = "sandBag"
mp["WorldItems/Disinfectant"]                      = "wineBottle"
mp["WorldItems/EmptyPopBottle"]                    = "wineBottle"
mp["WorldItems/FabricRolled"]                      = { p = "fabricRoll", s = 0.14 }
mp["WorldItems/Flask"]                             = "flask"
mp["WorldItems/Flier"]                             = { p = "flier", s = 0.125 }
mp["WorldItems/Flour"]                             = "flour"
mp["WorldItems/FrozenFoodBag"]                     = { p = "frozenFoodBag", s = 0.4 }
mp["WorldItems/GranolaBar"]                        = "granolaBar"
mp["WorldItems/HairDye"]                           = "wineBottle"
mp["WorldItems/Hide_Rolled_Deer"]                  = { p = "hideRolledDeer", s = 0.1 }
mp["WorldItems/HotSauce"]                          = "tinyBottle"
mp["WorldItems/Jar_Roe"]                           = { p = "jar", s = 0.5 }
mp["WorldItems/Jar_Roe_Open"]                      = { p = "jar", s = 0.5, qz = 1 }
mp["WorldItems/JarFood"]                           = "jar"
mp["WorldItems/JarFood_Open"]                      = { p = "jar", qz = 1 }
mp["WorldItems/JarLid"]                            = "jar"
mp["WorldItems/JarOpen"]                           = { p = "jar", qz = 1 }
mp["WorldItems/Ketchup"]                           = "sauce"
mp["WorldItems/Leather_Rolled"]                    = { p = "leatherRoll", s = 0.1 }
mp["WorldItems/Lightbar"]                          = { p = "trunkLid", s = 0.25 }
mp["WorldItems/LightBulb"]                         = "lightBulb"
mp["WorldItems/MacAndCheese"]                      = "macAndCheese"
mp["WorldItems/MapleSyrup"]                        = "sauce"
mp["WorldItems/Margerine"]                         = { p = "sardinesTin", s = 0.28 }
mp["WorldItems/Marinara"]                          = "marinara"
mp["WorldItems/Milk"]                              = "carton"
mp["WorldItems/Muffler"]                           = { p = "muffler", s = 0.4 }
mp["WorldItems/NormalGasTank1"]                    = { p = "gasTank", s = 0.4 }
mp["WorldItems/PainKillers"]                       = { p = "pizzaSlice", s = 1.12, dz = 0.006, fz = 90, qz = 5 }
mp["WorldItems/PeanutButter"]                      = "jarTall"
mp["WorldItems/Pizza"]                             = { p = "pizza", s = 0.4 }
mp["WorldItems/PizzaSlice"]                        = { p = "pizzaSlice", s = 0.4 }
mp["WorldItems/RiceVinegar"]                       = "wineBottle"
mp["WorldItems/Rod_Metal_Quarter"]                 = { p = "metalRod" }
mp["WorldItems/Rod_Metal_Slug"]                    = { p = "metalRod" }
mp["WorldItems/SandBag"]                           = "sandBag"
mp["WorldItems/SaucePan"]                          = "saucePan"
mp["WorldItems/SaucePan_Copper"]                   = { p = "saucePanCopper", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Pasta"]             = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Rice"]              = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Water"]             = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_FoodFluid"]                = "saucePanFull"
mp["WorldItems/SleepingTablets"]                   = { p = "sponge", s = 0.52, dz = 0.0135, qz = 5 }
mp["WorldItems/Sponge"]                            = { qz = 6, flip=true }
--mp["WorldItems/Sportsbottle"]                      = "bottle"
mp["WorldItems/Suspension"]                        = { p = "suspension", s = 0.4 }
mp["WorldItems/Tarp"]                              = { p = "tarp", s = 0.3 }
mp["WorldItems/ToiletPaper"]                       = {qz=3}
mp["WorldItems/TomatoPaste"]                       = { p = "toothpaste", s = 0.4 }
mp["WorldItems/Toothpaste"]                        = { p = "toothpaste", s = 0.6 }
mp["WorldItems/Umbrella_Open"]                     = { p = "weaponLong", mz = 0.016 }
mp["WorldItems/WeldingRods"]                       = { p = "bottle", s = 0.18 }
mp["WorldItems/WineBox"]                           = "wineBox"
mp["WorldItems/WoodenMold_AnvilJeweller_Cast"]     = { p = "anvilMoldCast", s = 0.1 }
mp["WorldItems/WoodenMold_CeramicCast_AnvilBlock"] = { p = "anvilMold", s = 0.13 }
mp["WorldItems/WoodenMold_IngotCast"]              = { p = "woodenIngotMold", s = 0.09 }
mp["WorldItems/ToyBear"] = {fz=180}

----
-- overrides
----
IA.arrangables["Base.IronBar"].mx = -0.24
ap.champagneBottle.fz = -270
ap.cocoaPowder.fz = 0

IA.arrangables["Base.JamFruit"]        = extend(ap.jar, { fz = 90 })
IA.arrangables["Base.JamMarmalade"]    = extend(ap.jar, { fz = 90 })
IA.arrangables["Base.MayonnaiseEmpty"] = extend(ap.jar, { fz = -30 })
IA.arrangables["Base.MayonnaiseFull"]  = extend(ap.jar, { fz = -30 })
IA.arrangables["Base.RemouladeEmpty"]  = extend(ap.jar, { fz = 0 })
IA.arrangables["Base.RemouladeFull"]   = extend(ap.jar, { fz = 0 })

----
-- surfaces
----

-- make metal shelves stack just a little bit tighter
IA.surfaceProfile.metalShelfWEN = {
  [1] = { zmin = 0.04, zmax = 0.35, xmin = 0.25, xmax = 0.90, ymin = 0.35, ymax = 1.00 },
  [2] = { zmin = 0.36, zmax = 0.65, xmin = 0.25, xmax = 0.90, ymin = 0.35, ymax = 1.00 },
  [3] = { zmin = 0.67, zmax = 1.00, xmin = 0.25, xmax = 0.90, ymin = 0.35, ymax = 1.00 },
}
IA.surfaceProfile.metalShelfWES = {
  [1] = { zmin = 0.04, zmax = 0.35, xmin = 0.25, xmax = 0.90, ymin = 0.00, ymax = 0.95 },
  [2] = { zmin = 0.36, zmax = 0.65, xmin = 0.25, xmax = 0.90, ymin = 0.00, ymax = 0.95 },
  [3] = { zmin = 0.67, zmax = 1.00, xmin = 0.25, xmax = 0.90, ymin = 0.00, ymax = 0.95 },
}
IA.surfaceProfile.metalShelfNSW = {
  [1] = { zmin = 0.04, zmax = 0.35, xmin = 0.10, xmax = 1.00, ymin = 0.25, ymax = 0.85 },
  [2] = { zmin = 0.36, zmax = 0.65, xmin = 0.10, xmax = 1.00, ymin = 0.25, ymax = 0.85 },
  [3] = { zmin = 0.67, zmax = 1.00, xmin = 0.10, xmax = 1.00, ymin = 0.25, ymax = 0.85 },
}
IA.surfaceProfile.metalShelfNSE = {
  [1] = { zmin = 0.04, zmax = 0.35, xmin = 0.00, xmax = 0.90, ymin = 0.25, ymax = 0.85 },
  [2] = { zmin = 0.36, zmax = 0.65, xmin = 0.00, xmax = 0.90, ymin = 0.25, ymax = 0.85 },
  [3] = { zmin = 0.67, zmax = 1.00, xmin = 0.00, xmax = 0.90, ymin = 0.25, ymax = 0.85 },
}

IA.surfaces["furniture_shelving_01_24"] = IA.surfaceProfile.metalShelfWES
IA.surfaces["furniture_shelving_01_25"] = IA.surfaceProfile.metalShelfWEN
IA.surfaces["furniture_shelving_01_26"] = IA.surfaceProfile.metalShelfNSW
IA.surfaces["furniture_shelving_01_27"] = IA.surfaceProfile.metalShelfNSE

-- military crates have a slightly taller appearance
local boxMilitary = { [1] = extend(IA.surfaceProfile.box[1], { zmin = 0.36 }) }
IA.surfaces["location_military_generic_01_0"] = boxMilitary
IA.surfaces["location_military_generic_01_1"] = boxMilitary
IA.surfaces["location_military_generic_01_8"] = boxMilitary
IA.surfaces["location_military_generic_01_9"] = boxMilitary
-- crafted metal crates
IA.surfaces["constructedobjects_01_44"] = IA.surfaceProfile.box
IA.surfaces["constructedobjects_01_45"] = IA.surfaceProfile.box
IA.surfaces["constructedobjects_01_46"] = IA.surfaceProfile.box
IA.surfaces["constructedobjects_01_47"] = IA.surfaceProfile.box
-- fancy crafted metal crates
IA.surfaces["crafted_05_44"] = IA.surfaceProfile.box
IA.surfaces["crafted_05_44"] = IA.surfaceProfile.box
IA.surfaces["crafted_05_44"] = IA.surfaceProfile.box
IA.surfaces["crafted_05_44"] = IA.surfaceProfile.box

-- wood shelves
IA.surfaceProfile.woodShelvesE = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.07, xmax = 0.43, ymin = 0.10, ymax = 1.00 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.07, xmax = 0.43, ymin = 0.10, ymax = 1.00 },
}
IA.surfaceProfile.woodShelvesW = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.74, xmax = 0.99, ymin = 0.10, ymax = 1.00 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.74, xmax = 0.99, ymin = 0.10, ymax = 1.00 },
}
IA.surfaceProfile.woodShelvesS = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.10, xmax = 1.00, ymin = 0.13, ymax = 0.49 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.10, xmax = 1.00, ymin = 0.13, ymax = 0.49 },
}
IA.surfaceProfile.woodShelvesN = {
  [1] = { zmin = 0.64, zmax = 1.00, xmin = 0.10, xmax = 1.00, ymin = 0.63, ymax = 0.99 },
  [2] = { zmin = 0.35, zmax = 0.58, xmin = 0.10, xmax = 1.00, ymin = 0.63, ymax = 0.99 },
}

IA.surfaces["furniture_shelving_01_1"] = IA.surfaceProfile.woodShelvesS
IA.surfaces["furniture_shelving_01_2"] = IA.surfaceProfile.woodShelvesE
IA.surfaces["furniture_shelving_01_3"] = IA.surfaceProfile.woodShelvesW
IA.surfaces["furniture_shelving_01_4"] = IA.surfaceProfile.woodShelvesN

--
IA.surfaceProfile.largeWallShelvesS = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0, xmax = 1, ymin = 0.15, ymax = 0.45 },
  [2] = { zmin = 0.379, zmax = 0.60, xmin = 0, xmax = 1, ymin = 0.155, ymax = 0.45 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0, xmax = 1, ymin = 0.17, ymax = 0.45 },
}
IA.surfaceProfile.largeWallShelvesE = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.19, xmax = 0.45, ymin = 0.15, ymax = 1 },
  [2] = { zmin = 0.382, zmax = 0.60, xmin = 0.19, xmax = 0.45, ymin = 0.15, ymax = 1 },
  [3] = { zmin = 0.68, zmax = 0.95,  xmin = 0.19, xmax = 0.45, ymin = 0.15, ymax = 1 },
}
IA.surfaceProfile.largeWallShelvesW = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.55, xmax = 0.81, ymin = 0.00, ymax = 0.85 },
  [2] = { zmin = 0.382, zmax = 0.60, xmin = 0.55, xmax = 0.81, ymin = 0.00, ymax = 0.85 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.55, xmax = 0.81, ymin = 0.00, ymax = 0.85 },
}
IA.surfaceProfile.largeWallShelvesN = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.00, xmax = 1.00, ymin = 0.55, ymax = 0.85 },
  [2] = { zmin = 0.379, zmax = 0.60, xmin = 0.00, xmax = 1.00, ymin = 0.55, ymax = 0.845 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.00, xmax = 1.00, ymin = 0.55, ymax = 0.83 },
}

IA.surfaces["furniture_shelving_01_9"] = IA.surfaceProfile.largeWallShelvesS
IA.surfaces["furniture_shelving_01_10"] = IA.surfaceProfile.largeWallShelvesE
IA.surfaces["furniture_shelving_01_11"] = IA.surfaceProfile.largeWallShelvesN
IA.surfaces["furniture_shelving_01_12"] = IA.surfaceProfile.largeWallShelvesW

IA.surfaceProfile.bigWallCornerShelvesS = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0.16, xmax = 0.45, ymin = 0.25, ymax = 1.15 },
  [2] = { zmin = 0.379, zmax = 0.6, xmin = 0.16, xmax = 0.45, ymin = 0.25, ymax = 1.15 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.16, xmax = 0.45, ymin = 0.25, ymax = 1.15 },
}
IA.surfaceProfile.bigWallCornerShelvesN = {
  [1] = { zmin = 0.068, zmax = 0.34, xmin = 0, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [2] = { zmin = 0.379, zmax = 0.6, xmin = 0, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
}
IA.surfaceProfile.bigWallCornerShelvesW = {
  [1] = { zmin = 0.05, zmax = 0.34, xmin = 0.68, xmax = 0.95, ymin = 0.15, ymax = 1 },
  [2] = { zmin = 0.35, zmax = 0.6, xmin = 0.65, xmax = 0.95, ymin = 0.15, ymax = 1 },
  [3] = { zmin = 0.64, zmax = 1, xmin = 0.65, xmax = 0.95, ymin = 0.15, ymax = 1 },
}
IA.surfaceProfile.bigWallCornerShelvesE = {
  [1] = { zmin = 0.059, zmax = 0.34, xmin = 0.15, xmax = 1, ymin = 0.68, ymax = 0.96 },
  [2] = { zmin = 0.379, zmax = 0.6, xmin = 0.15, xmax = 1, ymin = 0.68, ymax = 0.96 },
  [3] = { zmin = 0.68, zmax = 0.95, xmin = 0.15, xmax = 1, ymin = 0.68, ymax = 0.96 },
}

-- corners
IA.surfaces["furniture_shelving_01_8"] = IA.surfaceProfile.bigWallCornerShelvesS -- ^
IA.surfaces["furniture_shelving_01_13"] = IA.surfaceProfile.bigWallCornerShelvesN -- v
IA.surfaces["furniture_shelving_01_14"] = IA.surfaceProfile.bigWallCornerShelvesW -- >
IA.surfaces["furniture_shelving_01_15"] = IA.surfaceProfile.bigWallCornerShelvesE -- <

-- brown fancy wooden bookshelf
IA.surfaceProfile.bookshelfE = {
  [1] = { zmin = 0.05, zmax = 0.22, xmin = 0.18, xmax = 0.50, ymin = 0.19, ymax = 0.95 },
  [2] = { zmin = 0.344, zmax = 0.50, xmin = 0.25, xmax = 0.50, ymin = 0.19, ymax = 0.95 },
  [3] = { zmin = 0.618, zmax = 0.77, xmin = 0.25, xmax = 0.50, ymin = 0.19, ymax = 0.95 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.15, xmax = 0.50, ymin = 0.15, ymax = 0.95 },
}
IA.surfaceProfile.bookshelfW = {
  [1] = { zmin = 0.05, zmax = 0.22, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
  [2] = { zmin = 0.32, zmax = 0.49, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
  [3] = { zmin = 0.59, zmax = 0.76, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.60, xmax = 0.95, ymin = 0.19, ymax = 0.95 },
}
IA.surfaceProfile.bookshelfS = {
  [1] = { zmin = 0.055, zmax = 0.22, xmin = 0.096, xmax = 0.95, ymin = 0.18, ymax = 0.55 },
  [2] = { zmin = 0.333, zmax = 0.50, xmin = 0.12, xmax = 0.95, ymin = 0.25, ymax = 0.55 },
  [3] = { zmin = 0.61, zmax = 0.77, xmin = 0.13, xmax = 0.95, ymin = 0.25, ymax = 0.55 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.13, xmax = 0.95, ymin = 0.18, ymax = 0.55 },
}
IA.surfaceProfile.bookshelfN = {
  [1] = { zmin = 0.05, zmax = 0.22, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [2] = { zmin = 0.32, zmax = 0.49, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [3] = { zmin = 0.59, zmax = 0.76, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
  [4] = { zmin = 0.845, zmax = 1.00, xmin = 0.11, xmax = 0.95, ymin = 0.62, ymax = 0.95 },
}

IA.surfaces["furniture_shelving_01_40"] = IA.surfaceProfile.bookshelfS
IA.surfaces["furniture_shelving_01_41"] = IA.surfaceProfile.bookshelfE
IA.surfaces["furniture_shelving_01_42"] = IA.surfaceProfile.bookshelfW
IA.surfaces["furniture_shelving_01_43"] = IA.surfaceProfile.bookshelfN
--
-- this was assigned fridge but this is the white fancy wooden bookshelf
IA.surfaces["furniture_shelving_01_44"] = IA.surfaceProfile.bookshelfS
IA.surfaces["furniture_shelving_01_45"] = IA.surfaceProfile.bookshelfE
IA.surfaces["furniture_shelving_01_46"] = IA.surfaceProfile.bookshelfW
IA.surfaces["furniture_shelving_01_47"] = IA.surfaceProfile.bookshelfN

-- shelves generated from the game's tile geometry, only where nothing above (or Item Arrange) defined a profile.
-- entries already loaded are kept on hot reload, so restart after regenerating
local generatedSurfaces = require("CAItemArrangerExtension/IASurfaces_Generated")

for spriteName, surfaces in pairs(generatedSurfaces) do
  if not IA.surfaces[spriteName] then
    IA.surfaces[spriteName] = surfaces
  end
end

----
-- mods
----

-- VFX
ap.vfxCandyBox           = { dx = 0.2, dy = 0.09, dz = 0.046, qz = 3 }
ap.vfxCheeseKitBox       = { dx = 0.16, dy = 0.38, dz = 0.1, qz = 2, fz = -90 }
ap.vfxCheeseWheel        = { dx = 0.333, dy = 0.333, dz = 0.08, qz = 2 }
ap.vfxFocacciaSlice      = { dx = 0.12, dy = 0.21, dz = 0.012, qz = 4, fz = 90 }
ap.vfxGranolaBarBox      = { dx = 0.25, dy = 0.083, dz = 0.074, qz = 2, my = 0.03 }
ap.vfxJelloBox           = { dx = 0.21, dy = 0.11, dz = 0.05, qz = 3 }
ap.vfxPacketRamen        = { dx = 0.16, dy = 0.09, dz = 0.046, qz = 3 }
ap.vfxRamenBox           = { dx = 0.24, dy = 0.16, dz = 0.08, qz = 1 }
ap.vfxRectangleBox       = { dx = 0.21, dy = 0.25, dz = 0.026, qz = 3 }
ap.vfxRectFoodContainer  = { dx = 0.25, dy = 0.35, dz = 0.046, qz = 5 }
ap.vfxRoundFoodContainer = { dx = 0.32, dy = 0.32, dz = 0.06, qz = 4 }
ap.vfxSandwich           = { dx = 0.13, dy = 0.19, dz = 0.015, qz = 4, fz = 348 }
ap.vfxSnackBox           = { dx = 0.2, dy = 0.09, dz = 0.046, qz = 3, my = 0.01, mx = 0.01 }
ap.vfxStarterBox         = { dx = 0.185, dy = 0.095, dz = 0.115, qz = 1 }
ap.vfxTeaBox             = { dx = 0.08, dy = 0.08, dz = 0.033, qz = 4 }

--mp["CanClosed"]                                     = { p = "can", s = 0.8 }
--mp["WorldItems/VFX_BeerBottle"]                     = "wineBottle"
mp["WorldItems/VFX_BeerBottle_SM"]                  = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_BowlFull"]                       = "bowlFull"
mp["WorldItems/VFX_BoxRamen"]                       = "vfxRamenBox"
mp["WorldItems/VFX_CandyBox"]                       = {qz=3}
mp["WorldItems/VFX_CanOpen"]                        = { p = "can", s = 0.8, qz = 1 }
mp["WorldItems/VFX_Carton"]                         = {fz=180}
mp["WorldItems/VFX_CheeseKitBox"]                   = "vfxCheeseKitBox"
mp["WorldItems/VFX_CheeseWheel"]                    = "vfxCheeseWheel"
mp["WorldItems/VFX_CoffeeCreamerBottle"]            = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_Container_FoodStorageContainer"] = {qz=4}
mp["WorldItems/VFX_FoodStorageContainer"]           = {qz=4}
mp["WorldItems/VFX_FunDip"]                         = { p = "pouch", fx = -90, dy = 0.02, mz = 0.037, dx = 0.24 }
mp["WorldItems/VFX_GlassBottle"]                    = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_GranolaBarBox"]                  = "vfxGranolaBarBox"
mp["WorldItems/VFX_IcedTeaBottle"]                  = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_Jar"]                            = { p = "jar", s = 0.8 }
mp["WorldItems/VFX_JarFoodOpen"]                    = { p = "jar", s = 0.4, qz = 1 }
mp["WorldItems/VFX_JarOpen"]                        = { p = "jar", s = 0.8, qz = 1 }
mp["WorldItems/VFX_JelloBox"]                       = "vfxJelloBox"
mp["WorldItems/VFX_LemonBottle"]                    = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_MetalFoodStorageContainer"]      = { p = "vfxRectFoodContainer", s = 1.2 }
--mp["WorldItems/VFX_Mustard"]                        = "honey"
mp["WorldItems/VFX_Packaging_Bag"]                  = { p = "driedBeans", s = 0.8 }
--mp["WorldItems/VFX_PacketRamen"]                    = "vfxPacketRamen"
mp["WorldItems/VFX_PotForgedFull"]                  = "potFull"
mp["WorldItems/VFX_PotFull"]                        = "potFull"
mp["WorldItems/VFX_Pouch"]                          = "pouch"
mp["WorldItems/VFX_ProteinPowder"]                  = { p = "jar", s = 0.5, qz = 2 }
mp["WorldItems/VFX_RectangleBox"]                   = "vfxRectangleBox"
mp["WorldItems/VFX_Sandwich"]                       = "vfxSandwich"
mp["WorldItems/VFX_SliceBread"]                     = { p = "breadSlice", s = 0.3 }
mp["WorldItems/VFX_SliceFocaccia"]                  = "vfxFocacciaSlice"
mp["WorldItems/VFX_SM_BreadSlices"]                 = { p = "breadSlice", s = 0.3 }
mp["WorldItems/VFX_SM_FoodStorageContainer"]        = "vfxRoundFoodContainer"
mp["WorldItems/VFX_SM_MetalFoodStorageContainer"]   = { p = "vfxRectFoodContainer", s = 1.2 }
mp["WorldItems/VFX_SmallJar"]                       = { p = "jar", dz = 0.039, s = 0.76 }
mp["WorldItems/VFX_SnackBox"]                       = "vfxSnackBox"
mp["WorldItems/VFX_StarterBox"]                     = "vfxStarterBox"
mp["WorldItems/VFX_TeaBox"]                         = "vfxTeaBox"

-- Sapph
ap.sapphBox     = { dx = 0.3, dy = 0.42, dz = 0.072, qz = 4, mz = 0.003 }
ap.sapphBoxOpen = { dx = 0.6, dy = 0.5, dz = 0.08, qz = 1, mz = 0.002 }

mp["Worlditems/AlcoholBottle"]         = { p = "flask", s = 0.7 }
mp["Worlditems/Bigcanmodel"]           = { p = "jar", s = 1.2 }
mp["Worlditems/Box_CannedFood"]        = { p = "sapphBoxOpen", s = 0.0045 }
mp["Worlditems/Box_CannedFood_Closed"] = { p = "sapphBox", s = 0.0045 }
mp["Worlditems/BreadSliceToast"]       = { p = "breadSlices", s = 0.0035 }
mp["Worlditems/CheeseWheel"]           = "sapphCheeseWheel"
mp["WorldItems/CookingPot_Liquid"]     = "potFull"
mp["Worlditems/DevJarFood"]            = { p = "jar", s = 0.8 }
mp["Worlditems/EmptyBottle"]           = "wineBottle"
mp["Worlditems/GenericCan"]            = "jar"
mp["Worlditems/WhippedCan_Ground"]     = "wineBottle"

-- Authentic Z
mp["WorldItems/WorldItem_AuthenticPillBottle"] = { p = "seasoningJar", s = 1.25, qz = 1 }
mp["WorldItems/WorldItem_AZ_AquaBottle"]       = "bottle"
mp["WorldItems/WorldItem_AZ_GymBottle"]        = "wineBottle"
mp["WorldItems/WorldItem_SpiffoBackpack"]      = { p = "hikingBag", fx = 0, fz = 180, dx = 0.33, mz = 0 }

-- Fool's new containers
ap.ncAmmocan30   = { dx = 0.122, dy = 0.28, dz = 0.1, qz = 1, fz = 90, mz = 0.003 }
ap.ncAmmocan50   = { dx = 0.185, dy = 0.35, dz = 0.1, qz = 1, fz = 90 }
ap.ncBeverageJug = { dx = 0.45, dy = 0.45, dz = 0.18, qz = 1 }
ap.ncCardboardLg = { dx = 0.415, dy = 0.415, dz = 0.20, qz = 1 }
ap.ncCardboardMd = { dx = 0.31, dy = 0.38, dz = 0.085, qz = 3, fz = 90 }
ap.ncCardboardSm = { dx = 0.28, dy = 0.22, dz = 0.025, qz = 4 }
ap.ncDishTub     = { dx = 0.35, dy = 0.43, dz = 0.1, qz = 1 }
ap.ncMilkCrate   = { dx = 0.358, dy = 0.358, dz = 0.12, qz = 2, mz = 0.065, fz = 90 }
ap.ncTote        = { dx = 0.5, dy = 0.6, dz = 0.18, qz = 2, fz = 90 }
ap.ncWaterJug    = { dx = 0.285, dy = 0.24, dz = 0.36, qz = 1, fz = 90 }

mp["WorldItems/NCammocan30_ground"]           = "ncAmmocan30"
mp["WorldItems/NCammocan50_ground"]           = "ncAmmocan50"
mp["WorldItems/NCbeveragejugclosed_ground"]   = "ncBeverageJug"
mp["WorldItems/NCbeveragejugopen_ground"]     = { p = "ncBeverageJug", mz = 0.140 }
mp["WorldItems/NCbeveragejugopenfull_ground"] = { p = "ncBeverageJug", mz = 0.140 }
mp["WorldItems/NCcanteen"]                    = "flask"
mp["WorldItems/NCcardboard_large"]            = { p = "ncCardboardLg", s = 0.9 }
mp["WorldItems/NCcardboard_medium"]           = { p = "ncCardboardMd", s = 0.9 }
mp["WorldItems/NCcardboard_small"]            = { p = "ncCardboardSm", s = 0.8 }
mp["WorldItems/NCdishtub_01"]                 = { p = "ncDishtub", s = 0.7 }
mp["WorldItems/NCdishtub_02"]                 = { p = "ncDishtub", s = 0.7 }
mp["WorldItems/NCdishtub_03"]                 = { p = "ncDishtub", s = 0.7 }
mp["WorldItems/NCdishtub_ground"]             = { p = "ncDishtub", s = 0.7 }
mp["WorldItems/NCdishtubfull_ground"]         = "ncDishTub"
mp["WorldItems/NCmilkcrate_ground"]           = "ncMilkCrate"
mp["WorldItems/NCmilkcratelong_ground"]       = { p = "ncMilkCrate", dy = 0.6 }
mp["WorldItems/NCpizzabox_ground"]            = { p = "pizza", dz = 0.0262, mz = 0.019 }
mp["WorldItems/NCplastictote_large"]          = { p = "ncTote", s = 0.7 }
mp["WorldItems/NCplastictote_medium"]         = { p = "ncTote", s = 0.7, dz = 0.16 }
mp["WorldItems/NCplastictote_small"]          = { p = "ncTote", s = 0.7, dz = 0.07 }
mp["WorldItems/NCshoppingbasket_ground"]      = "ncDishtub"
mp["WorldItems/NCtackleboxlarge_ground"]      = "ncDishtub"
mp["WorldItems/NCwaterjug_ground"]            = "ncWaterJug"
mp["WorldItems/NCcomponentkit_ground"]            = {mz=0.02}
mp["WorldItems/NCcdbinder_ground"]            = {mz=0.02}
mp["WorldItems/NCcdcase_ground"]            = {mz=0.002}
mp["WorldItems/NCroughbox_ground"]            = {qz=2}
mp["WorldItems/NCshoebox_ground"]            = {qz=3, flip=true}

-- Pomp's items (food)
ap.pompCheesyPoofs = { dx = 0.3, dy = 0.1, dz = 0.063, qz = 2, fx = 90, mz = 0.035 }
ap.pompSourGummies = { dx = 0.23, dy = 0.1, dz = 0.0068, qz = 8 }
ap.pompChocMilk = { dx = 0.16, dy = 0.18, dz = 0.07, qz = 1 }
ap.pompSnackable = { dx = 0.22, dy = 0.22, dz = 0.02, qz = 3 }
ap.pompFigBox = { dx = 0.345, dy = 0.076, dz = 0.085, qz = 2, fz = 90, fy = 270, mz = 0.045 }
ap.pompFreezePop = { dy = 0.25, dx = 0.05, dz = 0.006, mz = 0.0034, qz = 4, fz = 90 }
ap.pompJiang = { dx = 0.19, dy = 0.135, dz = 0.05, qz = 3 }

mp["WorldItems/Food/PINormalCan"] = { qz=3 } -- 16
--mp["WorldItems/Food/PINormalCanOpen"] = { p = "jar", qz = 1 } -- 16
--mp["WorldItems/Food/PINormalCanHand"] = { p = "jar", qz = 1 }
--mp["WorldItems/Food/PIWingSauceBottle"] = { p = "sauce", s = 0.023 } -- 14
--mp["WorldItems/Food/PIWingSauceBottleHand"] = { p = "sauce", s = 0.023 } -- 14
--mp["WorldItems/Food/PITea"] = "bottle" -- 14
--mp["WorldItems/Food/PITeaHand"] = "bottle" -- 14
--mp["WorldItems/Food/SportsDrank"] = "bottle" -- 12
--mp["WorldItems/Food/SportsDrankHand"] = "bottle" -- 12
mp["WorldItems/BittersBar"] ={qz=3} -- 11
mp["WorldItems/BittersBarHand"] ={qz=3} -- 11
mp["WorldItems/BittersBarEmpty"] ={qz=3} -- 11
--mp["WorldItems/Food/PICan128"] = { p = "can", qz = 1 } -- 11
--mp["WorldItems/Food/PICan128Hand"] = { p = "can", qz = 1 } -- 11
--mp["WorldItems/Food/PICan128Empty"] = { p = "can", qz = 1 } -- 11
mp["WorldItems/Food/PISnackableSmol"] = "pompSnackable" -- 10
mp["WorldItems/Food/PIFreezePop"] = "pompFreezePop" -- 10
mp["WorldItems/Food/PIFreezePopHand"] = "pompFreezePop" -- 10
mp["WorldItems/Jiang"] = {qz=3} -- 9
mp["WorldItems/JiangHand"] = {qz=3} -- 9
mp["WorldItems/JiangEmpty"] = {qz=3} -- 9
mp["WorldItems/SourGummies"] = {qz=8} -- 9
mp["WorldItems/SourGummiesHand"] = {qz=8} -- 9
mp["WorldItems/SourGummiesEmpty"] = {qz=8} -- 9
mp["WorldItems/PIGummyWorms"] = {qz=3} -- 7
mp["WorldItems/GummyWormsEmpty"] = {qz=3} -- 7
mp["WorldItems/Food/PIFishSnackems"] = "pouch"
mp["WorldItems/Food/PIFishSnackemsEmpty"] = "pouch"
mp["WorldItems/Food/PIWingSauceBottleEmpty"] = { p = "sauce", s = 0.023 } -- 7
-- mp["WorldItems/Food/PIPopTartBox"] = "" -- 7
-- mp["WorldItems/Food/PITeaEmpty"] = "" -- 7
-- mp["WorldItems/GummyWormsHand"] = "" -- 6
-- mp["WorldItems/Food/SportsDrankEmpty"] = "" -- 6
mp["WorldItems/Food/PIHotSauce"] = "smallBottle" -- 6
mp["WorldItems/Food/PIHotSauceHand"] = "smallBottle" -- 6
-- mp["WorldItems/Food/PIFruitBarrelHand"] = "" -- 5
mp["WorldItems/Food/PIRingPop"] = {qz=5}
mp["WorldItems/Food/PIRingPopHand"] = {qz=5} -- 5
mp["WorldItems/Food/PIPopTart"] = {qz = 5} -- 5
mp["WorldItems/Food/PIPopTartHand"] = {qz = 5} -- 5
-- mp["WorldItems/Food/PIKidCuisine"] = "" -- 5
-- mp["WorldItems/Food/PIKidCuisineHand"] = "" -- 5
mp["WorldItems/WildPegasus_Ground"] = { p = "bottle", s = 1.2 } -- 4
-- mp["WorldItems/WildPegasusHand"] = "" -- 4
mp["WorldItems/Dabs"] = {qz=5} -- 4
mp["WorldItems/DabsHand"] = {qz=5} -- 4
mp["WorldItems/DabsEmpty"] = {qz=5} -- 4
mp["WorldItems/Food/PIDonutBag"] = {qz=5} -- 4
mp["WorldItems/Food/PIDonutBagEmpty"] = {qz=5} -- 4
mp["WorldItems/Food/PIPizzaBox"] = { qz = 5 } -- 4
mp["WorldItems/Food/PIPizzaBoxEmpty"] = { qz = 5 } -- 4
mp["WorldItems/Food/PIPizza"] = { qz = 5 } -- 4
mp["WorldItems/Food/PIPizzaFoldedHand"] = { qz = 5 } -- 4
mp["WorldItems/Food/PIPizzaSlice"] = { qz = 5 } -- 4
mp["WorldItems/Food/PIPizzaSliceHand"] = { qz = 5 } -- 4
mp["WorldItems/StallionMilk_Ground"] = {  fz = 190 } -- uhhh... ok
mp["WorldItems/StallionMilkOpen_Ground"] = { fz = 190 }
mp["WorldItems/Food/PICheesyPoofsSide"] = { qz = 2 } -- 1
mp["WorldItems/Food/PISnackableSmol"] = { qz = 6 }
mp["WorldItems/Food/PISnackableSmolEmpty"] = { qz = 6 }
mp["WorldItems/Food/PISnackableHamCracker"] = { qz = 6 }
mp["WorldItems/Food/PISnackableHamCrackerHand"] = { qz = 6 }
mp["WorldItems/Food/PIRitz"] = { qz = 6 }
mp["WorldItems/Food/PIRitzHand"] = { qz = 6 }
mp["WorldItems/Food/PICheddar"] = { qz = 6 }
mp["WorldItems/Food/PICheddarHand"] = { qz = 6 }
mp["WorldItems/Food/PISnackableNachoHand"] = { qz = 6 }
mp["WorldItems/Food/SnackablePizza"] = { qz = 6 }
mp["WorldItems/Food/SnackablePizzaHand"] = { qz = 6 }

-- bolts and arrows
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_fly"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_floor"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_fly"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_floor"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_fly"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_floor"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_part"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_part"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_part"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_pack"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_pack"] = { qz = 5,dz=0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_pack"] = { qz = 5,dz=0.01 }
mp["Crossbow|Bolts_wood_pack"] = { qz = 5,dz=0.01 }
mp["Crossbow|Bolts_metal_pack"] = { qz = 5,dz=0.01 }
mp["Crossbow|Bolts_carbon_pack"] = { qz = 5,dz=0.01 }

--- ggs
mp["Ammo/792x57Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets308Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets32Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets357Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets38Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets44Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets45Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets50Box"] = { dy = 0.15, dx = 0.2, qz = 2, dz = 0.112, mz = 0.002 }
mp["Ammo/Bullets50MagnumBox"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets545x39Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets556Box"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets762x39Box"] = { qz = 2, fz = 12, dx=0.18, dy=0.18 }
mp["Ammo/Bullets762x54rBox"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets9mmBox"] = { qz = 5, mz = 0.002 }
mp["Ammo/Bullets9x39Box"] = { qz = 5, mz = 0.002, fz=12 }
mp["Ammo/GrenadeAmmoBox"] = { qz = 5, mz = 0.002 }
mp["Ammo/ShotgunShellsBox"] = { fz = 12 }
mp["Ammo/ammoBox"] = { qz = 5, mz = 0.002 }
mp["WorldItems/HandGunAmmoBox"] = { qz = 5 }

mp["Ammo/WorldItems|308Box150"] = { qz=5 }
mp["Ammo/WorldItems|50Box100"] = { qz=5, dy = 0.2 }
mp["Ammo/WorldItems|556Box150"] = { qz=5 }
mp["Ammo/WorldItems|762x54rBox150"] = { qz=5 }
mp["Ammo/WorldItems|792x57Box75"] = { qz=5 }
mp["Ammo/WorldItems|792x57Box97"] = { qz=5 }
mp["Mags/MAGS|308Box150"] = { qz=5 }
mp["Mags/MAGS|50Box100"] = { qz=5 }
mp["Mags/MAGS|556Box150"] = { qz=5 }
mp["Mags/MAGS|762x54rBox150"] = { qz=5 }
mp["Mags/MAGS|792x57Box75"] = { qz=5 }
mp["Mags/MAGS|792x57Box97"] = { qz=5 }

---@param target  table
---@param foreign table<string, boolean>
---@return table<string, boolean>
local function ownKeys(target, foreign)
  local keys = {}

  for key in pairs(target) do
    if not foreign[key] then
      keys[key] = true
    end
  end

  return keys
end

IAE_DataKeys.meshProfiles = ownKeys(mp, foreignMeshProfiles)
IAE_DataKeys.surfaces = ownKeys(IA.surfaces, foreignSurfaces)
