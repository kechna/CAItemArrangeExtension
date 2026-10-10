IA = IA or {}

local IA = IA

local ap = IA.arrangableProfile
local mp = IA.meshProfiles

--
-- Arrangable profiles
--

ap.anvilMold          = { dx = 0.26, dy = 0.36, dz = 0.075 }
ap.anvilMoldCast      = { dx = 0.26, dy = 0.4, dz = 0.06 }
ap.bagConcretePowder  = { dx = 0.3, dy = 0.18, dz = 0.16, qz = 1 }
ap.bbqSauce           = { dx = 0.15, dy = 0.08, dz = 0.09, qz = 1, fz = -90 }
ap.bigHikingBag       = { dx = 0.32, dy = 0.32, dz = 0.2, qz = 1, fx = -262, fz = 270, mz = 0.11, my=0.18 }
ap.bleachBottle       = { dx = 0.1, dy = 0.16, dz = 0.11, qz = 1, fz = 180 }
ap.bowl               = { dx = 0.19, dy = 0.19, dz = 0.025, qz = 6 }
ap.bowlFull           = { dx = 0.19, dy = 0.19, dz = 0.04, qz = 1 }
ap.bowlFull2          = { dx = 0.22, dy = 0.22, dz = 0.04, qz = 1 } -- brain tan bowl is slightly bigger
ap.briefcase          = { dx = 0.29, dy = 0.76, dz = 0.1, qz = 1 }
ap.cartonWide         = { dx = 0.12, dy = 0.09, dz = 0.015, qz = 1, fz = 180 }
ap.ceramicIngotCast   = { dx = 0.15, dy = 0.31, dz = 0.032, qz = 4 }
ap.cooler             = { dx = 0.25, dy = 0.44, dz = 0.17, qz = 1 }
ap.duffelBag          = { dx = 0.29, dy = 0.76, dz = 0.1, qz = 1 }
ap.fabricRoll         = { dx = 0.15, dy = 0.65, dz = 0.055, qz = 4, fz = 90 }
ap.flour              = { dx = 0.35, dy = 0.33, dz = 0.1, qz = 1, fz = -90 }
ap.hideRolledDeer     = { dx = 0.11, dy = 0.65, dz = 0.032, qz = 4 }
ap.hikingBag          = { dx = 0.32, dy = 0.32, dz = 0.18, qz = 1, fx = -262, fz = 270, mz = 0.11, my = 0.18 }
ap.jar                = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 45 }
ap.jarTall            = { dx = 0.15, dy = 0.15, dz = 0.078, qz = 2 }
ap.leatherRoll        = { dx = 0.12, dy = 0.65, dz = 0.046, qz = 4 }
ap.lightBulb          = { dx = 0.11, dy = 0.12, dz = 0.02, qz = 1, fz = 90 }
ap.marinara           = { dx = 0.12, dy = 0.12, dz = 0.05 }
ap.militaryBackpack   = { dx = 0.4, dy = 0.32, dz = 0.2, fy = 342, fz = -90, my = 0.08, mz=-0.008, qz = 1 }
ap.potFull            = { dx = 0.40, dy = 0.40, dz = 0.10, qz = 1 }
ap.pouch              = { dx = 0.2, dy = 0.07, dz = 0.1, qz = 1 }
ap.sandBag            = { dx = 0.29, dy = 0.76, dz = 0.1, qz = 1 }
ap.sauce              = { dx = 0.17, dy = 0.08, dz = 0.09, qz = 1 }
ap.saucePan           = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = -90 }
ap.saucePanCopper     = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = 0 }
ap.saucePanCopperFull = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = 0 }
ap.saucePanFull       = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = -90 }
ap.smallBackpack      = { dx = 0.31, dy = 0.18, dz = 0.14, fy = 90, fz = 270, mz = 0.08, my = -0.07, qz = 1 }
ap.sponge             = { dx = 0.115, dy = 0.165, dz = 0.026, qz = 6, fz = 90 }
ap.tinyBottle         = { dx = 0.075, dy = 0.075, dz = 0.03, qz = 1 }
ap.toiletPaper        = { dx = 0.16, dy = 0.16, dz = 0.06, qz = 3 }
ap.woodenIngotMold    = { dx = 0.2, dy = 0.36, dz = 0.038, qz = 4 }


--IA.arrangableProfile.hikingBag             = { dx = 0.32, dy = 0.32, dz = 0.18, qz = 1, fx = -262, fz = 270, mz = 0.11, my = 0.18 }
--IA.arrangables["Base.Bag_NormalHikingBag"] = IA.arrangableProfile.hikingBag -- rotates wrong on all but NE wall
--
--IA.arrangableProfile.smallBackpack   = { dx = 0.31, dy = 0.18, dz = 0.14, fy = 90, fz = 270, mz = 0.08, my = -0.07, qz = 1 }
--IA.arrangables["Base.Bag_Schoolbag"] = IA.arrangableProfile.smallBackpack -- rotates ok on all walls

--
-- Mesh profiles
--

-- Thanks to @CouncilOfPoorlyLitBaldPeople. Yes, I'm crediting you anyway :P
mp["ammo/boxes/Ammobox"]                           = "ammoBox"
mp["ammo/boxes/Ammobox_Rifle_Small"]               = "ammoBox"
mp["ammo/boxes/Ammobox_Shotgun"]                   = "shotgunShellsBox"
mp["weapons/ammo/762-556-308-223AmmoBox"]          = "ammoBox"

-- By me
mp["WorldItems/BagofConcretePowder"]               = { p = "bagConcretePowder", s = 0.2 }
mp["WorldItems/CeramicCast_AnvilBlock"]            = { p = "anvilMold", s = 0.13 }
mp["WorldItems/CeramicMold_AnvilJeweller"]         = { p = "anvilMoldCast", s = 0.1 }
mp["WorldItems/Ceramic_IngotCast"]                 = { p = "ceramicIngotCast", s = 0.09 }
mp["WorldItems/Clothing/ALICE_Pack_Ground"]      = "militaryBackpack"
mp["WorldItems/Clothing/BigHikingBag_Ground"]      = "bigHikingBag"
mp["WorldItems/Clothing/Cooler_Ground"]            = "cooler"
mp["WorldItems/Clothing/DuffelBag_Ground"]         = "duffelBag"
mp["WorldItems/Clothing/HikingBag_Ground"]         = "hikingBag"
mp["WorldItems/Clothing/SandBag_Ground"]           = "sandBag"
mp["WorldItems/Clothing/SchoolBag_Ground"]         = "smallBackpack"
--mp["WorldItems/Clothing/Briefcase"]              = "briefcase"
mp["BleachBottle"]                                 = "bleachBottle"
mp["Jar"]                                          = "jar"
mp["WorldItems/BBQ_Sauce"]                         = "bbqSauce"
mp["WorldItems/BalsamicVinegar"]                   = "wineBottle"
mp["WorldItems/Bottle"]                            = "wineBottle"
mp["WorldItems/Bowl"]                              = "bowl"
mp["WorldItems/BowlFood"]                          = "bowlFull"
mp["WorldItems/BowlOfGlaze"]                       = { p = "bowlFull2", s = 0.5 }
mp["WorldItems/BowlRamen"]                         = "bowlFull"
mp["WorldItems/BowlSoup"]                          = "bowlFull"
mp["WorldItems/Bowl_Kiln"]                         = "bowl"
mp["WorldItems/Bowl_Kiln_Full"]                    = "bowlFull"
mp["WorldItems/CleaningLiquid"]                    = { p = "sauce", s = 0.5 }
mp["WorldItems/CookingPotFull"]                    = "potFull"
mp["WorldItems/Cornmeal"]                          = { p = "pouch", s = 0.126 }
mp["WorldItems/Disinfectant"]                      = "wineBottle"
mp["WorldItems/EmptyPopBottle"]                    = "wineBottle"
mp["WorldItems/FabricRolled"]                      = { p = "fabricRoll", s = 0.14 }
mp["WorldItems/Flask"]                             = "smallBottle"
mp["WorldItems/Flour"]                             = "flour"
mp["WorldItems/HairDye"]                           = "wineBottle"
mp["WorldItems/Hide_Rolled_Deer"]                  = { p = "hideRolledDeer", s = 0.1 }
mp["WorldItems/HotSauce"]                          = "tinyBottle"
mp["WorldItems/JarFood"]                           = "jar"
mp["WorldItems/JarFood_Open"]                      = { p = "jar", qz = 1 }
mp["WorldItems/JarLid"]                            = "jar"
mp["WorldItems/JarOpen"]                           = "jar"
mp["WorldItems/Ketchup"]                           = "sauce"
mp["WorldItems/Leather_Rolled"]                    = { p = "leatherRoll", s = 0.1 }
mp["WorldItems/LightBulb"]                         = "lightBulb"
mp["WorldItems/MapleSyrup"]                        = "sauce"
mp["WorldItems/Margerine"]                         = { p = "sardinesTin", s = 0.28 }
mp["WorldItems/Marinara"]                          = "marinara"
mp["WorldItems/Milk"]                              = "carton"
mp["WorldItems/PeanutButter"]                      = "jarTall"
mp["WorldItems/RiceVinegar"]                       = "wineBottle"
mp["WorldItems/SaucePan"]                          = "saucePan"
mp["WorldItems/SaucePan_Copper"]                   = { p = "saucePanCopper", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Pasta"]             = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Rice"]              = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Water"]             = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_FoodFluid"]                = "saucePanFull"
mp["WorldItems/Soysauce"]                          = "honey"
mp["WorldItems/Sponge"]                            = "sponge"
mp["WorldItems/Sportsbottle"]                      = "bottle"
mp["WorldItems/ToiletPaper"]                       = "toiletPaper"
mp["WorldItems/WoodenMold_AnvilJeweller_Cast"]     = { p = "anvilMoldCast", s = 0.1 }
mp["WorldItems/WoodenMold_CeramicCast_AnvilBlock"] = { p = "anvilMold", s = 0.13 }
mp["WorldItems/WoodenMold_IngotCast"]              = { p = "woodenIngotMold", s = 0.09 }

-- overrides
IA.arrangables["Base.IronBar"].mx = -0.24
ap.champagneBottle.fz = -270
ap.cocoaPowder.fz = 0

--ap.champagneBottle

-- VFX
ap.cheeseKitBox = { dx = 0.16, dy = 0.38, dz = 0.1, qz = 2, fz = -90 }
ap.roundFoodContainer = { dx = 0.32, dy = 0.32, dz = 0.06, qz = 4 }
ap.rectFoodContainer = { dx = 0.25, dy = 0.35, dz = 0.046, qz = 5 }
ap.granolaBar = { dx = 0.32, dy = 0.32, dz = 0.06, qz = 4 }
ap.granolaBarBox = { dx = 0.25, dy = 0.35, dz = 0.046, qz = 3 }
ap.starterBox = { dx = 0.185, dy = 0.095, dz = 0.115, qz = 1 }
ap.vfxCheeseWheel = { dx = 0.333, dy = 0.333, dz = 0.08, qz = 2 }

mp["WorldItems/VFX_BeerBottle"]                     = "wineBottle"
mp["WorldItems/VFX_Carton"]                         = "cartonWide"
mp["WorldItems/VFX_CoffeeCreamerBottle"]            = "bottle"
mp["WorldItems/VFX_GlassBottle"]                    = "bottle"
mp["WorldItems/VFX_IcedTeaBottle"]                  = "bottle"
mp["WorldItems/VFX_LemonBottle"]                    = "bottle"
mp["WorldItems/VFX_Mustard"]                        = "honey"
mp["WorldItems/VFX_PotForgedFull"]                  = "potFull"
mp["WorldItems/VFX_PotFull"]                        = "potFull"
mp["WorldItems/VFX_Pouch"]                          = "pouch"
mp["WorldItems/VFX_JarFoodOpen"]                    = { p = "jar", qz = 1 }
mp["WorldItems/VFX_BowlFull"]                       = "bowlFull"
mp["WorldItems/VFX_CheeseKitBox"]                   = "cheeseKitBox"
mp["WorldItems/VFX_Container_FoodStorageContainer"] = "roundFoodContainer"
mp["WorldItems/VFX_FoodStorageContainer"]           = "roundFoodContainer"
mp["WorldItems/VFX_SM_FoodStorageContainer"]        = "roundFoodContainer"
mp["WorldItems/VFX_MetalFoodStorageContainer"]      = { p = "rectFoodContainer", s = 1.2 }
mp["WorldItems/VFX_SM_MetalFoodStorageContainer"]   = { p = "rectFoodContainer", s = 1.2 }
mp["WorldItems/VFX_StarterBox"]                     = "starterBox"

mp["WorldItems/GranolaBar"]        = "granolaBar"
mp["WorldItems/VFX_GranolaBarBox"] = "granolaBarBox"
mp["WorldItems/VFX_CheeseWheel"]   = "vfxCheeseWheel"

-- Sapph
mp["WorldItems/CookingPot_Liquid"]       = "potFull"
mp["Worlditems/EmptyBottle"]             = "wineBottle"
mp["Worlditems/CheeseWheel"]             = "sapphCheeseWheel"

-- Authentic Z
mp["WorldItems/WorldItem_AZ_AquaBottle"] = "bottle"
mp["WorldItems/WorldItem_AZ_GymBottle"]  = "wineBottle"

-- Fool's new containers
ap.ncWaterJug    = { dx = 0.285, dy = 0.24, dz = 0.36, qz = 1, fz = 90 }
ap.ncCardboardLg = { dx = 0.415, dy = 0.415, dz = 0.20, qz = 1 }
ap.ncCardboardMd = { dx = 0.31, dy = 0.38, dz = 0.085, qz = 3, fz = 90 }
ap.ncCardboardSm = { dx = 0.28, dy = 0.22, dz = 0.025, qz = 4 }

mp["WorldItems/NCwaterjug_ground"]  = "ncWaterJug"
mp["WorldItems/NCcanteen"]          = "smallBottle"
mp["WorldItems/NCcardboard_large"]  = { p = "ncCardboardLg", s = 0.9 }
mp["WorldItems/NCcardboard_medium"] = { p = "ncCardboardMd", s = 0.9 }
mp["WorldItems/NCcardboard_small"]  = { p = "ncCardboardSm", s = 0.8 }
