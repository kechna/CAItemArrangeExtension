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
ap.cartonWide         = { dx = 0.12, dy = 0.09, dz = 0.015, qz = 1, fz = 180 }
ap.ceramicIngotCast   = { dx = 0.15, dy = 0.31, dz = 0.032, qz = 4 }
ap.cooler             = { dx = 0.25, dy = 0.44, dz = 0.17, qz = 1 }
ap.cutlery            = { dx = 0.06, dy = 0.33, dz = 0.006, qz = 1, fz=-90, my=-0.04 }
ap.duffelBag          = { dx = 0.29, dy = 0.76, dz = 0.1, qz = 1 }
ap.fabricRoll         = { dx = 0.15, dy = 0.65, dz = 0.055, qz = 4, fz = 90 }
ap.flask              = { dx = 0.12, dy = 0.05, dz = 0.05, qz = 1, fz=-90 }
ap.flour              = { dx = 0.35, dy = 0.33, dz = 0.1, qz = 1, fz = -90 }
ap.frozenFoodBag      = { dx = 0.23, dy = 0.42, dz = 0.024, qz = 4, fz=90 }
ap.gasTank            = { dx = 0.63, dy = 0.56, dz = 0.085, qz = 2, my = -0.07 }
ap.granolaBar         = { dx = 0.32, dy = 0.32, dz = 0.06, qz = 4 }
ap.hideRolledDeer     = { dx = 0.11, dy = 0.65, dz = 0.032, qz = 4 }
ap.hikingBag          = { dx = 0.32, dy = 0.32, dz = 0.18, qz = 1, fx = -262, fz = 270, mz = 0.11, my = 0.18 }
ap.jar                = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 45 }
ap.jarTall            = { dx = 0.15, dy = 0.15, dz = 0.078, qz = 2 }
ap.leatherRoll        = { dx = 0.12, dy = 0.65, dz = 0.046, qz = 4 }
ap.lightBulb          = { dx = 0.11, dy = 0.12, dz = 0.02, qz = 1, fz = 90 }
ap.macAndCheese       = { dx = 0.18, dy = 0.1, dz = 0.095, qz = 2 }
ap.marinara           = { dx = 0.12, dy = 0.12, dz = 0.05 }
ap.militaryBackpack   = { dx = 0.4, dy = 0.32, dz = 0.2, fy = 342, fz = -90, my = 0.08, mz=-0.008, qz = 1 }
ap.muffler            = { dx = 0.24, dy = 0.5, dz = 0.042, qz = 4, fz = 90 }
ap.potFull            = { dx = 0.40, dy = 0.40, dz = 0.10, qz = 1 }
ap.pouch              = { dx = 0.2, dy = 0.07, dz = 0.1, qz = 1 }
ap.sandBag            = { dx = 0.33, dy = 0.6, dz = 0.04, qz = 3, fz=90 }
ap.sauce              = { dx = 0.17, dy = 0.08, dz = 0.09, qz = 1 }
ap.saucePan           = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = -90 }
ap.saucePanCopper     = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = 0 }
ap.saucePanCopperFull = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = 0 }
ap.saucePanFull       = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = -90 }
ap.smallBackpack      = { dx = 0.31, dy = 0.18, dz = 0.14, fy = 90, fz = 270, mz = 0.08, my = -0.07, qz = 1 }
ap.sponge             = { dx = 0.115, dy = 0.165, dz = 0.026, qz = 6, fz = 90 }
ap.suspension         = { dx = 0.28, dy = 0.44, dz = 0.04, qz = 1, fz = 90, my = -0.05 }
ap.tinyBottle         = { dx = 0.075, dy = 0.075, dz = 0.03, qz = 1 }
ap.toiletPaper        = { dx = 0.16, dy = 0.16, dz = 0.06, qz = 3 }
ap.toothpaste         = { dx = 0.1, dy = 0.24, dz = 0.02, qz = 3 }
ap.trunkLid           = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8 }
ap.windshield         = { dx = 0.75, dy = 0.35, dz = 0.014, qz = 8 }
ap.wineBox            = { dx = 0.15, dy = 0.1, dz = 0.096, qz = 2 }
ap.woodenIngotMold    = { dx = 0.2, dy = 0.36, dz = 0.038, qz = 4 }
ap.breadSlices        = { dx = 0.23, dy = 0.21, dz = 0.0078, qz = 6, fz = -10 }
ap.breadSlice         = { dx = 0.038, dy = 0.055, dz = 0.0022, qz = 10, fz= -10 }

--
-- Mesh profiles
--

-- Thanks to @CouncilOfPoorlyLitBaldPeople. Yes, I'm crediting you anyway :P
mp["ammo/boxes/Ammobox"]                           = "ammoBox"
mp["ammo/boxes/Ammobox_Rifle_Small"]               = "ammoBox"
mp["ammo/boxes/Ammobox_Shotgun"]                   = "shotgunShellsBox"
mp["weapons/ammo/762-556-308-223AmmoBox"]          = "ammoBox"

-- By me
mp["BleachBottle"]                                   = "bleachBottle"
mp["CaffinePills"]                                   = { p = "seasoningJar", s = 0.13 }
mp["Jar"]                                            = {p= "jar", s=0.4 }
mp["weapons/1handed/ButterKnife"]                    = { p = "cutlery", my = -0.02 }
mp["weapons/1handed/Fork"]                           = { p = "cutlery", my = 0.1 }
mp["weapons/1handed/Fork_Bone_Hand"]                 = { p = "cutlery", my = 0.1, }
mp["weapons/1handed/Fork_Forged_Hand"]               = { p = "cutlery", my = 0.1, }
mp["weapons/1handed/Fork_Wood_Hand"]                 = { p = "cutlery", my = 0.1, fz=90 }
mp["weapons/1handed/KitchenKnife_Forged_Hand"]       = "cutlery"
mp["weapons/1handed/Knife"]                          = { p = "cutlery", my = -0.02 }
mp["weapons/1handed/Knife_Bone_Hand"]                = { p = "cutlery", my = -0.02 }
mp["weapons/1handed/Knife_Fillet_Hand"]              = "cutlery"
mp["weapons/1handed/KnifeHunting_Forged_Basic_Hand"] = "cutlery"
mp["weapons/1handed/KnifeHunting_Forged_Hand"]       = "cutlery"
mp["weapons/1handed/KnifeKitchen_Forged_Hand"]       = "cutlery"
mp["weapons/1handed/KnifeParing_Hand"]               = "cutlery"
mp["weapons/1handed/Pen"]                            = "cutlery"
mp["weapons/1handed/Pencil"]                         = "cutlery"
mp["weapons/1handed/PenKnife"]                       = "cutlery"
mp["weapons/1handed/PenKnife2"]                      = "cutlery"
mp["weapons/1handed/Plastic_Fork_Hand"]              = { p = "cutlery", my = 0.1, fz=90 }
mp["weapons/1handed/Plastic_Knife_Hand"]             = { p = "cutlery", my = 0.1 }
mp["weapons/1handed/Plastic_Spoon_Hand"]             = { p = "cutlery", my = 0.1, fz=90 }
mp["weapons/1handed/Scalpel"]                        = "cutlery"
mp["weapons/1handed/Screwdriver"]                    = "cutlery"
mp["weapons/1handed/ShankGlass_Hand"]                = "cutlery"
mp["weapons/1handed/Shiv"]                           = "cutlery"
mp["weapons/1handed/Shiv2"]                          = "cutlery"
mp["weapons/1handed/Shiv_Spear_Crude_Hand"]          = "cutlery"
mp["weapons/1handed/Shiv_SpearCrude_Longer_Hand"]    = "cutlery"
mp["weapons/1handed/Shiv_SpearStone_High_Hand"]      = "cutlery"
mp["weapons/1handed/Shiv_SpearStoneBasic_Head_Hand"] = "cutlery"
mp["weapons/1handed/Spoon"]                          = { p = "cutlery", my = 0.1 }
mp["weapons/1handed/Spoon_Bone_Hand"]                = { p = "cutlery", my = 0.1, }
mp["weapons/1handed/Spoon_Forged_Hand"]              = { p = "cutlery", my = 0.1, }
mp["weapons/1handed/Spoon_Wood_Hand"]                = { p = "cutlery", my = 0.1, }
mp["WorldItems/BagofConcretePowder"]                 = { p = "bagConcretePowder", s = 0.2 }
mp["WorldItems/BalsamicVinegar"]                     = "wineBottle"
mp["WorldItems/BBQ_Sauce"]                           = "bbqSauce"
mp["WorldItems/Bottle"]                              = "wineBottle"
mp["WorldItems/Bowl"]                                = "bowl"
mp["WorldItems/Bowl_Kiln"]                           = "bowl"
mp["WorldItems/Bowl_Kiln_Full"]                      = "bowlFull"
mp["WorldItems/BowlFood"]                            = "bowlFull"
mp["WorldItems/BowlOfGlaze"]                         = { p = "bowlFull2", s = 0.5 }
mp["WorldItems/BowlRamen"]                           = "bowlFull"
mp["WorldItems/BowlSoup"]                            = "bowlFull"
mp["WorldItems/CannedSardinesOpen"]                  = { p = "sardinesTin", qz = 1 }
mp["WorldItems/CarBumper"]                           = { p = "trunkLid", s = 0.25 }
mp["WorldItems/BreadSlices"]                         = { p = "breadSlices", s = 0.3 }
mp["WorldItems/CarDoor"]                             = { p = "trunkLid", s = 0.25, dz = 0.018 }
mp["WorldItems/CarHood"]                             = "trunkLid"
mp["WorldItems/CarJack"]                             = { p = "trunkLid", s = 0.25 }
mp["WorldItems/CarParts"]                            = { p = "trunkLid", s = 0.25 }
mp["WorldItems/CarTrunkLid"]                         = { p = "trunkLid", s = 0.25 }
mp["WorldItems/CarWindshield"]                       = { p = "windshield", s = 0.25 }
mp["WorldItems/Ceramic_IngotCast"]                   = { p = "ceramicIngotCast", s = 0.09 }
mp["WorldItems/CeramicCast_AnvilBlock"]              = { p = "anvilMold", s = 0.13 }
mp["WorldItems/CeramicMold_AnvilJeweller"]           = { p = "anvilMoldCast", s = 0.1 }
mp["WorldItems/CleaningLiquid"]                      = { p = "sauce", s = 0.5 }
mp["WorldItems/Clothing/ALICE_Pack_Ground"]          = "militaryBackpack"
mp["WorldItems/Clothing/BigHikingBag_Ground"]        = "bigHikingBag"
mp["WorldItems/Clothing/Briefcase"]                  = "briefcase"
mp["WorldItems/Clothing/Cooler_Ground"]              = "cooler"
mp["WorldItems/Clothing/DuffelBag_Ground"]           = "duffelBag"
mp["WorldItems/Clothing/HikingBag_Ground"]           = "hikingBag"
mp["WorldItems/Clothing/SandBag_Ground"]             = "sandBag"
mp["WorldItems/Clothing/SchoolBag_Ground"]           = "smallBackpack"
mp["WorldItems/CookingPotFull"]                      = "potFull"
mp["WorldItems/Cornmeal"]                            = { p = "pouch", s = 0.126 }
mp["WorldItems/DipJar"]                              = {p = "jar", dz=0.039,s=0.12, fz=-180}
mp["WorldItems/DirtBag"]                             = "sandBag"
mp["WorldItems/Disinfectant"]                        = "wineBottle"
mp["WorldItems/EmptyPopBottle"]                      = "wineBottle"
mp["WorldItems/FabricRolled"]                        = { p = "fabricRoll", s = 0.14 }
mp["WorldItems/Flask"]                               = "flask"
mp["WorldItems/Flour"]                               = "flour"
mp["WorldItems/FrozenFoodBag"]                       = {p= "frozenFoodBag", s=0.4 }
mp["WorldItems/GranolaBar"]                          = "granolaBar"
mp["WorldItems/HairDye"]                             = "wineBottle"
mp["WorldItems/Hide_Rolled_Deer"]                    = { p = "hideRolledDeer", s = 0.1 }
mp["WorldItems/HotSauce"]                            = "tinyBottle"
mp["WorldItems/Jar_Roe"]                             = { p = "jar", s = 0.5 }
mp["WorldItems/Jar_Roe_Open"]                        = { p = "jar", s = 0.5, qz=1 }
mp["WorldItems/JarFood"]                             = "jar"
mp["WorldItems/JarFood_Open"]                        = { p = "jar", qz = 1 }
mp["WorldItems/JarLid"]                              = "jar"
mp["WorldItems/JarOpen"]                             = { p = "jar", qz = 1 }
mp["WorldItems/Ketchup"]                             = "sauce"
mp["WorldItems/Leather_Rolled"]                      = { p = "leatherRoll", s = 0.1 }
mp["WorldItems/Lightbar"]                            = { p = "trunkLid", s = 0.25 }
mp["WorldItems/LightBulb"]                           = "lightBulb"
mp["WorldItems/MacAndCheese"]                        = "macAndCheese"
mp["WorldItems/MapleSyrup"]                          = "sauce"
mp["WorldItems/Margerine"]                           = { p = "sardinesTin", s = 0.28 }
mp["WorldItems/Marinara"]                            = "marinara"
mp["WorldItems/Milk"]                                = "carton"
mp["WorldItems/Muffler"]                             = { p = "muffler", s = 0.4 }
mp["WorldItems/NormalGasTank1"]                      = { p = "gasTank", s = 0.4 }
mp["WorldItems/PeanutButter"]                        = "jarTall"
mp["WorldItems/RiceVinegar"]                         = "wineBottle"
mp["WorldItems/SandBag"]                             = "sandBag"
mp["WorldItems/SaucePan"]                            = "saucePan"
mp["WorldItems/SaucePan_Copper"]                     = { p = "saucePanCopper", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Pasta"]               = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Rice"]                = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_Copper_Water"]               = { p = "saucePanCopperFull", s = 0.075 }
mp["WorldItems/SaucePan_FoodFluid"]                  = "saucePanFull"
mp["WorldItems/Soysauce"]                            = "honey"
mp["WorldItems/Sponge"]                              = "sponge"
mp["WorldItems/Spork"]                               = "cutlery"
mp["WorldItems/Sportsbottle"]                        = "bottle"
mp["WorldItems/Suspension"]                          = { p = "suspension", s = 0.4 }
mp["WorldItems/ToiletPaper"]                         = "toiletPaper"
mp["WorldItems/TomatoPaste"]                         = {p="toothpaste", s=0.4}
mp["WorldItems/Toothpaste"]                          = {p="toothpaste", s=0.6}
mp["WorldItems/WineBox"]                             = "wineBox"
mp["WorldItems/WoodenMold_AnvilJeweller_Cast"]       = { p = "anvilMoldCast", s = 0.1 }
mp["WorldItems/WoodenMold_CeramicCast_AnvilBlock"]   = { p = "anvilMold", s = 0.13 }
mp["WorldItems/WoodenMold_IngotCast"]                = { p = "woodenIngotMold", s = 0.09 }

-- overrides
IA.arrangables["Base.IronBar"].mx = -0.24
ap.champagneBottle.fz = -270
ap.cocoaPowder.fz = 0

--ap.champagneBottle

-- VFX
ap.vfxCandyBox           = { dx = 0.2, dy = 0.09, dz = 0.046, qz = 3 }
ap.vfxCheeseKitBox       = { dx = 0.16, dy = 0.38, dz = 0.1, qz = 2, fz = -90 }
ap.vfxCheeseWheel        = { dx = 0.333, dy = 0.333, dz = 0.08, qz = 2 }
ap.vfxGranolaBarBox      = { dx = 0.25, dy = 0.083, dz = 0.074, qz = 2, my=0.03 }
ap.vfxJelloBox           = { dx = 0.21, dy = 0.11, dz = 0.05, qz = 3 }
ap.vfxPacketRamen        = { dx = 0.16, dy = 0.09, dz = 0.046, qz = 3 }
ap.vfxRamenBox           = { dx = 0.24, dy = 0.16, dz = 0.08, qz = 1 }
ap.vfxRectangleBox       = { dx = 0.21, dy = 0.25, dz = 0.026, qz = 3 }
ap.vfxRectFoodContainer  = { dx = 0.25, dy = 0.35, dz = 0.046, qz = 5 }
ap.vfxRoundFoodContainer = { dx = 0.32, dy = 0.32, dz = 0.06, qz = 4 }
ap.vfxSnackBox           = { dx = 0.2, dy = 0.09, dz = 0.046, qz = 3, my=0.01, mx=0.01 }
ap.vfxStarterBox         = { dx = 0.185, dy = 0.095, dz = 0.115, qz = 1 }
ap.vfxTeaBox             = { dx = 0.08, dy = 0.08, dz = 0.033, qz = 4 }
ap.vfxFocacciaSlice      = { dx = 0.12, dy = 0.21, dz = 0.012, qz=4, fz=90}
ap.vfxSandwich           = { dx = 0.13, dy = 0.19, dz = 0.015, qz=4, fz=348}

mp["WorldItems/VFX_BeerBottle"]                     = "wineBottle"
mp["WorldItems/VFX_BeerBottle_SM"]                  = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_BowlFull"]                       = "bowlFull"
mp["WorldItems/VFX_BoxRamen"]                       = "vfxRamenBox"
mp["WorldItems/VFX_CandyBox"]                       = "vfxCandyBox"
mp["WorldItems/VFX_Carton"]                         = "cartonWide"
mp["WorldItems/VFX_CheeseKitBox"]                   = "vfxCheeseKitBox"
mp["WorldItems/VFX_CheeseWheel"]                    = "vfxCheeseWheel"
mp["WorldItems/VFX_CoffeeCreamerBottle"]            = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_Container_FoodStorageContainer"] = "vfxRoundFoodContainer"
mp["WorldItems/VFX_FoodStorageContainer"]           = "vfxRoundFoodContainer"
mp["WorldItems/VFX_FunDip"]                         = { p = "pouch", fx = -90, dy = 0.02, mz = 0.037, dx = 0.24 }
mp["WorldItems/VFX_GlassBottle"]                    = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_GranolaBarBox"]                  = "vfxGranolaBarBox"
mp["WorldItems/VFX_IcedTeaBottle"]                  = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_Jar"]                            = { p = "jar", s = 0.8 }
mp["WorldItems/VFX_JarFoodOpen"]                    = { p = "jar", s = 0.4, qz=1 }
mp["WorldItems/VFX_JarOpen"]                        = { p = "jar", s = 0.8, qz=1 }
mp["WorldItems/VFX_JelloBox"]                       = "vfxJelloBox"
mp["WorldItems/VFX_LemonBottle"]                    = { p = "bottle", fz = 0 }
mp["WorldItems/VFX_MetalFoodStorageContainer"]      = { p = "vfxRectFoodContainer", s = 1.2 }
mp["WorldItems/VFX_Mustard"]                        = "honey"
mp["WorldItems/VFX_PacketRamen"]                    = "vfxPacketRamen"
mp["WorldItems/VFX_PotForgedFull"]                  = "potFull"
mp["WorldItems/VFX_PotFull"]                        = "potFull"
mp["WorldItems/VFX_Pouch"]                          = "pouch"
mp["WorldItems/VFX_ProteinPowder"]                  = { p = "jar", s = 0.5, qz=2 }
mp["WorldItems/VFX_RectangleBox"]                   = "vfxRectangleBox"
mp["WorldItems/VFX_SM_FoodStorageContainer"]        = "vfxRoundFoodContainer"
mp["WorldItems/VFX_SM_MetalFoodStorageContainer"]   = { p = "vfxRectFoodContainer", s = 1.2 }
mp["WorldItems/VFX_SmallJar"]                       = { p = "jar", dz = 0.039, s=0.76 }
mp["WorldItems/VFX_SnackBox"]                       = "vfxSnackBox"
mp["WorldItems/VFX_StarterBox"]                     = "vfxStarterBox"
mp["WorldItems/VFX_TeaBox"]                         = "vfxTeaBox"
mp["WorldItems/VFX_SliceBread"]                     = { p="breadSlice", s=0.3 }
mp["WorldItems/VFX_SM_BreadSlices"]                 = { p="breadSlice", s=0.3 }
mp["WorldItems/VFX_SliceFocaccia"]                 = "vfxFocacciaSlice"
mp["WorldItems/VFX_Sandwich"]                      = "vfxSandwich"

-- Sapph
ap.sapphBox = { dx = 0.5, dy = 0.72, dz = 0.07, qz = 1 }
ap.sapphBoxOpen = { dx = 0.6, dy = 0.72, dz = 0.07, qz = 1 }
mp["Worlditems/AlcoholBottle"]         = { p = "flask", s = 0.7 }
mp["Worlditems/Bigcanmodel"]           = { p = "jar", s = 1.2 }
mp["Worlditems/Box_CannedFood"]        = "sapphBoxOpen"
mp["Worlditems/Box_CannedFood_Closed"] = "sapphBox"
mp["Worlditems/CheeseWheel"]           = "sapphCheeseWheel"
mp["WorldItems/CookingPot_Liquid"]     = "potFull"
mp["Worlditems/DevJarFood"]            = { p = "jar", s = 0.8 }
mp["Worlditems/EmptyBottle"]           = "wineBottle"
mp["Worlditems/GenericCan"]            = "jar"
mp["Worlditems/WhippedCan_Ground"]     = "wineBottle"
mp["Worlditems/BreadSliceToast"]       = { p="breadSlices", s=0.0035 }


-- Authentic Z
mp["WorldItems/WorldItem_AuthenticPillBottle"] = { p = "seasoningJar", s = 1.25, qz = 1 }
mp["WorldItems/WorldItem_AZ_AquaBottle"]       = "bottle"
mp["WorldItems/WorldItem_AZ_GymBottle"]        = "wineBottle"
mp["WorldItems/WorldItem_SpiffoBackpack"]      = {p="hikingBag", fx=0, fz=180, dx=0.33, mz=0}

-- Fool's new containers
ap.ncWaterJug    = { dx = 0.285, dy = 0.24, dz = 0.36, qz = 1, fz = 90 }
ap.ncCardboardLg = { dx = 0.415, dy = 0.415, dz = 0.20, qz = 1 }
ap.ncCardboardMd = { dx = 0.31, dy = 0.38, dz = 0.085, qz = 3, fz = 90 }
ap.ncCardboardSm = { dx = 0.28, dy = 0.22, dz = 0.025, qz = 4 }

mp["WorldItems/NCcanteen"]          = "flask"
mp["WorldItems/NCcardboard_large"]  = { p = "ncCardboardLg", s = 0.9 }
mp["WorldItems/NCcardboard_medium"] = { p = "ncCardboardMd", s = 0.9 }
mp["WorldItems/NCcardboard_small"]  = { p = "ncCardboardSm", s = 0.8 }
mp["WorldItems/NCwaterjug_ground"]  = "ncWaterJug"

-- Pomp's items (food)
mp["WorldItems/Food/PINormalCan"] = { p = "jar" } -- 16
mp["WorldItems/Food/PINormalCanOpen"] = { p = "jar", qz = 1 } -- 16
mp["WorldItems/Food/PINormalCanHand"] = { p = "jar", qz = 1 }
mp["WorldItems/Food/PIWingSauceBottle"] = "smallBottle" -- 14
mp["WorldItems/Food/PIWingSauceBottleHand"] = "smallBottle" -- 14
-- mp["WorldItems/Food/PITea"] = "" -- 14
-- mp["WorldItems/Food/PITeaHand"] = "" -- 14
-- mp["WorldItems/Food/SportsDrank"] = "" -- 12
-- mp["WorldItems/Food/SportsDrankHand"] = "" -- 12
-- mp["WorldItems/BittersBar"] = "" -- 11
-- mp["WorldItems/BittersBarHand"] = "" -- 11
-- mp["WorldItems/BittersBarEmpty"] = "" -- 11
 mp["WorldItems/Food/PICan128"] = { p = "jar", qz = 1 } -- 11
 mp["WorldItems/Food/PICan128Hand"] = { p = "jar", qz = 1 } -- 11
 mp["WorldItems/Food/PICan128Empty"] = { p = "jar", qz = 1 } -- 11
-- mp["WorldItems/Food/PISnackableSmol"] = "" -- 10
-- mp["WorldItems/Food/PIFreezePop"] = "" -- 10
-- mp["WorldItems/Food/PIFreezePopHand"] = "" -- 10
-- mp["WorldItems/Jiang"] = "" -- 9
-- mp["WorldItems/JiangHand"] = "" -- 9
-- mp["WorldItems/JiangEmpty"] = "" -- 9
-- mp["WorldItems/SourGummies"] = "" -- 9
-- mp["WorldItems/SourGummiesHand"] = "" -- 9
-- mp["WorldItems/SourGummiesEmpty"] = "" -- 9
-- mp["WorldItems/PIGummyWorms"] = "" -- 7
-- mp["WorldItems/GummyWormsEmpty"] = "" -- 7
-- mp["WorldItems/Food/PIFishSnackems"] = "" -- 7
-- mp["WorldItems/Food/PIFishSnackemsEmpty"] = "" -- 7
-- mp["WorldItems/Food/PIWingSauceBottleEmpty"] = "" -- 7
-- mp["WorldItems/Food/PIPopTartBox"] = "" -- 7
-- mp["WorldItems/Food/PITeaEmpty"] = "" -- 7
-- mp["WorldItems/GummyWormsHand"] = "" -- 6
-- mp["WorldItems/Food/SportsDrankEmpty"] = "" -- 6
-- mp["WorldItems/Food/PIHotSauce"] = "" -- 6
-- mp["WorldItems/Food/PIHotSauceHand"] = "" -- 6
-- mp["WorldItems/Food/PIFruitBarrelHand"] = "" -- 5
-- mp["WorldItems/Food/PIRingPop"] = "" -- 5
-- mp["WorldItems/Food/PIRingPopHand"] = "" -- 5
-- mp["WorldItems/Food/PIPopTart"] = "" -- 5
-- mp["WorldItems/Food/PIPopTartHand"] = "" -- 5
-- mp["WorldItems/Food/PIKidCuisine"] = "" -- 5
-- mp["WorldItems/Food/PIKidCuisineHand"] = "" -- 5
-- mp["WorldItems/WildPegasus_Ground"] = "" -- 4
-- mp["WorldItems/WildPegasusHand"] = "" -- 4
-- mp["WorldItems/Dabs"] = "" -- 4
-- mp["WorldItems/DabsHand"] = "" -- 4
-- mp["WorldItems/DabsEmpty"] = "" -- 4
-- mp["WorldItems/Food/PIRitz"] = "" -- 4
-- mp["WorldItems/Food/PIRitzHand"] = "" -- 4
-- mp["WorldItems/Food/PISnackableHamCracker"] = "" -- 4
-- mp["WorldItems/Food/PISnackableHamCrackerHand"] = "" -- 4
-- mp["WorldItems/Food/SnackableMarinara"] = "" -- 4
-- mp["WorldItems/Food/SnackableMarinaraHand"] = "" -- 4
-- mp["WorldItems/Food/PIFruitBarrel"] = "" -- 4
-- mp["WorldItems/Food/PICheesyPoofsEmpty"] = "" -- 4
-- mp["WorldItems/Food/PIDonutBag"] = "" -- 4
-- mp["WorldItems/Food/PIDonutBagEmpty"] = "" -- 4
-- mp["WorldItems/Food/PIMiniDonutHand"] = "" -- 4
-- mp["WorldItems/Food/PIMiniDonut"] = "" -- 4
-- mp["WorldItems/Food/PIPizzaBox"] = "" -- 4
-- mp["WorldItems/Food/PIPizzaBoxEmpty"] = "" -- 4
-- mp["WorldItems/Food/PIPizza"] = "" -- 4
-- mp["WorldItems/Food/PIPizzaFoldedHand"] = "" -- 4
-- mp["WorldItems/Food/PIPizzaSlice"] = "" -- 4
-- mp["WorldItems/Food/PIPizzaSliceHand"] = "" -- 4
-- mp["WorldItems/Food/PIChipBagHandy"] = "" -- 4
-- mp["WorldItems/MaplesSyrup"] = "" -- 3
-- mp["WorldItems/SaucePanPasta"] = "" -- 3
-- mp["WorldItems/SaucePanPastaRice"] = "" -- 3
-- mp["WorldItems/Sbeve"] = "" -- 3
-- mp["WorldItems/ChickenNuggets"] = "" -- 3
-- mp["WorldItems/ChocMilk"] = "" -- 3
-- mp["WorldItems/ChocMilkHand"] = "" -- 3
-- mp["WorldItems/Chocc"] = "" -- 3
-- mp["WorldItems/ChoccHand"] = "" -- 3
-- mp["WorldItems/ChoccEmpty"] = "" -- 3
-- mp["WorldItems/Food/PICheesyPoofs"] = "" -- 3
-- mp["WorldItems/Food/PIFishSnackemsHand"] = "" -- 3
-- mp["WorldItems/Food/PISchoolMilk"] = "" -- 3
-- mp["WorldItems/Food/PISchoolMilkHand"] = "" -- 3
-- mp["WorldItems/Food/PISchoolMilkEmpty"] = "" -- 3
-- mp["WorldItems/PegasusEmpty_Ground"] = "" -- 2
-- mp["WorldItems/MaplesSyrupHand"] = "" -- 2
-- mp["WorldItems/SbeveHand"] = "" -- 2
-- mp["WorldItems/POreo"] = "" -- 2
-- mp["WorldItems/POreoPackage"] = "" -- 2
-- mp["WorldItems/POreoPackageEmpty"] = "" -- 2
-- mp["WorldItems/ChocMilkEmpty"] = "" -- 2
-- mp["WorldItems/ChocolateCrossBox"] = "" -- 2
-- mp["WorldItems/ChocolateCrossBoxEmpty"] = "" -- 2
-- mp["WorldItems/UtahWaferPack"] = "" -- 2
-- mp["WorldItems/UtahWaferPackEmpty"] = "" -- 2
-- mp["WorldItems/UtahWafer"] = "" -- 2
-- mp["WorldItems/UtahWaferHand"] = "" -- 2
-- mp["WorldItems/VodkaAus"] = "" -- 2
-- mp["WorldItems/VodkaAusHand"] = "" -- 2
-- mp["WorldItems/Food/PICheddar"] = "" -- 2
-- mp["WorldItems/Food/PICheddarHand"] = "" -- 2
-- mp["WorldItems/Food/SnackablePizza"] = "" -- 2
-- mp["WorldItems/Food/SnackablePizzaHand"] = "" -- 2
-- mp["WorldItems/Food/PIBarrelBox"] = "" -- 2
-- mp["WorldItems/Food/PIBarrelBoxEmpty"] = "" -- 2
-- mp["WorldItems/Food/PICheesyPoofsHand"] = "" -- 2
-- mp["WorldItems/Food/PICandyCigarettes"] = "" -- 2
-- mp["WorldItems/Food/PICandyCigarettesEmpty"] = "" -- 2
-- mp["WorldItems/Food/PIPushPop"] = "" -- 2
-- mp["WorldItems/Food/PIPushPopHand"] = "" -- 2
-- mp["WorldItems/Food/PIPushPopEmpty"] = "" -- 2
-- mp["WorldItems/Food/PIPopcornBag"] = "" -- 2
-- mp["WorldItems/Food/PIPopcornBagFull"] = "" -- 2
-- mp["WorldItems/Food/PIPopcornBagFullHand"] = "" -- 2
-- mp["WorldItems/Food/PIBunnBourbon"] = "" -- 2
-- mp["WorldItems/Food/PIBunnBourbonHand"] = "" -- 2
-- mp["WorldItems/Food/PIAlcopop"] = "" -- 2
-- mp["WorldItems/Food/PIAlcopopHand"] = "" -- 2
-- mp["WorldItems/Food/PICheeseStickDip"] = "" -- 2
-- mp["WorldItems/StallionMilk_Ground"] = "" -- 1
-- mp["WorldItems/StallionMilkOpen_Ground"] = "" -- 1
-- mp["WorldItems/Pomps"] = "" -- 1
-- mp["WorldItems/PompsWrapper"] = "" -- 1
-- mp["WorldItems/PBCup"] = "" -- 1
-- mp["WorldItems/PBCupHand"] = "" -- 1
-- mp["WorldItems/KFCheese"] = "" -- 1
-- mp["WorldItems/KFCheeseOpen"] = "" -- 1
-- mp["WorldItems/KFCheeseHand"] = "" -- 1
-- mp["WorldItems/Brawndo"] = "" -- 1
-- mp["WorldItems/BrawndoCan"] = "" -- 1
-- mp["WorldItems/BrawndoHand"] = "" -- 1
-- mp["WorldItems/FrozenWaffle"] = "" -- 1
-- mp["WorldItems/FrozenWaffleHand"] = "" -- 1
-- mp["WorldItems/WafflezBox"] = "" -- 1
-- mp["WorldItems/WafflezBoxDestroyed"] = "" -- 1
-- mp["WorldItems/MoxxBox"] = "" -- 1
-- mp["WorldItems/MoxxStick"] = "" -- 1
-- mp["WorldItems/MoxxStickHand"] = "" -- 1
-- mp["WorldItems/MoxxBoxDestroyed"] = "" -- 1
-- mp["WorldItems/KFMarley"] = "" -- 1
-- mp["WorldItems/KFMarleyTrash"] = "" -- 1
-- mp["WorldItems/RootBeer"] = "" -- 1
-- mp["WorldItems/RootBeerHand"] = "" -- 1
-- mp["WorldItems/RootBeerEmpty"] = "" -- 1
-- mp["WorldItems/RootBeerBox"] = "" -- 1
-- mp["WorldItems/RootBeerBoxEmpty"] = "" -- 1
-- mp["WorldItems/CheetosCheese"] = "" -- 1
-- mp["WorldItems/CheetosCheeseEmpty"] = "" -- 1
-- mp["WorldItems/CheetosPacket"] = "" -- 1
-- mp["WorldItems/CheetosPacketEmpty"] = "" -- 1
-- mp["WorldItems/BowlSoup"] = "" -- 1
-- mp["WorldItems/BowlCheetosClassic"] = "" -- 1
-- mp["WorldItems/CzechCoffee"] = "" -- 1
-- mp["WorldItems/CzechCoffeeHand"] = "" -- 1
-- mp["WorldItems/CzechCoffeeEmpty"] = "" -- 1
-- mp["WorldItems/DinoNug1"] = "" -- 1
-- mp["WorldItems/DinoNug2"] = "" -- 1
-- mp["WorldItems/DinoNug3"] = "" -- 1
-- mp["WorldItems/DinoNugBox"] = "" -- 1
-- mp["WorldItems/DinoNugBoxEmpty"] = "" -- 1
-- mp["WorldItems/TaterSticks"] = "" -- 1
-- mp["WorldItems/TaterSticksHand"] = "" -- 1
-- mp["WorldItems/TaterSticksEmpty"] = "" -- 1
-- mp["WorldItems/Tartsies"] = "" -- 1
-- mp["WorldItems/TartsiesHand"] = "" -- 1
-- mp["WorldItems/TartsiesEmpty"] = "" -- 1
-- mp["WorldItems/ChocolateCross"] = "" -- 1
-- mp["WorldItems/ChocolateCrossHand"] = "" -- 1
-- mp["WorldItems/ChocolateRabbit"] = "" -- 1
-- mp["WorldItems/ChocolateRabbitHand"] = "" -- 1
-- mp["WorldItems/BuckeyesPack"] = "" -- 1
-- mp["WorldItems/BuckeyesEmpty"] = "" -- 1
-- mp["WorldItems/Buckeye"] = "" -- 1
-- mp["WorldItems/BuckeyeHand"] = "" -- 1
-- mp["WorldItems/VodkaAusEmpty"] = "" -- 1
-- mp["WorldItems/Food/FigBar"] = "" -- 1
-- mp["WorldItems/Food/FigBarHand"] = "" -- 1
-- mp["WorldItems/Food/FigBarEmpty"] = "" -- 1
-- mp["WorldItems/Food/FigBox"] = "" -- 1
-- mp["WorldItems/Food/FigBoxEmpty"] = "" -- 1
-- mp["WorldItems/Food/PICheeseBallsSmall"] = "" -- 1
-- mp["WorldItems/Food/PICheeseBallsSmallHand"] = "" -- 1
-- mp["WorldItems/Food/PICheeseBallsSmallEmpty"] = "" -- 1
-- mp["WorldItems/Food/PICheeseBalls"] = "" -- 1
-- mp["WorldItems/Food/PICheeseBallsHand"] = "" -- 1
-- mp["WorldItems/Food/PICheeseBallsEmpty"] = "" -- 1
-- mp["WorldItems/Jacket_1895IR22Ground"] = "" -- 1
-- mp["WorldItems/Food/PISnackableSmolEmpty"] = "" -- 1
-- mp["WorldItems/Food/PISnackableNachoHand"] = "" -- 1
-- mp["WorldItems/Food/SnackableCheeseStrips"] = "" -- 1
-- mp["WorldItems/Food/PIChickenNuggets"] = "" -- 1
-- mp["WorldItems/Food/PIOyster"] = "" -- 1
-- mp["WorldItems/Food/PIOysterHand"] = "" -- 1
-- mp["WorldItems/Food/PIRMOysters"] = "" -- 1
-- mp["WorldItems/Food/PIRMOystersEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIFruitBarrelEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIFruitBarrelWater"] = "" -- 1
-- mp["WorldItems/Food/PICandyCig"] = "" -- 1
-- mp["WorldItems/Food/PISpam"] = "" -- 1
-- mp["WorldItems/Food/PISpamOpen"] = "" -- 1
-- mp["WorldItems/Food/PISpamOpenHand"] = "" -- 1
-- mp["WorldItems/Food/PIHoneyBunBox"] = "" -- 1
-- mp["WorldItems/Food/PIHoneyBunBoxEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIHoneyBun"] = "" -- 1
-- mp["WorldItems/Food/PIHoneyBunHand"] = "" -- 1
-- mp["WorldItems/Food/PIMilkMolars"] = "" -- 1
-- mp["WorldItems/Food/PIMilkMolarsHand"] = "" -- 1
-- mp["WorldItems/Food/PIJawbreaker"] = "" -- 1
-- mp["WorldItems/Food/PIJawbreakerHand"] = "" -- 1
-- mp["WorldItems/Food/PIWormholes"] = "" -- 1
-- mp["WorldItems/Food/PIWormholesHand"] = "" -- 1
-- mp["WorldItems/Food/PIWormholesEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIIceCaps"] = "" -- 1
-- mp["WorldItems/Food/PIIceCapsHand"] = "" -- 1
-- mp["WorldItems/Food/PIIceCapsEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIPompsBig"] = "" -- 1
-- mp["WorldItems/Food/PICandyBagSmall"] = "" -- 1
-- mp["WorldItems/Food/PICandyBagSmallHand"] = "" -- 1
-- mp["WorldItems/Food/PICheesyPoofsSide"] = "" -- 1
-- mp["WorldItems/Food/PIIceCreamSandwich"] = "" -- 1
-- mp["WorldItems/Food/PIIceCreamSandwichHand"] = "" -- 1
-- mp["WorldItems/Food/PIBunnBourbonEmpty"] = "" -- 1
-- mp["WorldItems/Food/PISodaBox"] = "" -- 1
-- mp["WorldItems/Food/PISodaBoxEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIAlcopopEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIFireball"] = "" -- 1
-- mp["WorldItems/Food/PIFireballEmpty"] = "" -- 1
-- mp["WorldItems/Food/PIFireballHand"] = "" -- 1
-- mp["WorldItems/Food/PICheeseStickDipPack"] = "" -- 1
-- mp["WorldItems/Food/PICheeseStickDipHand"] = "" -- 1
-- mp["WorldItems/Food/PIKidCuisineEmpty"] = "" -- 1
