IA = IA or {}

local IA = IA

--
-- Arrangable profiles
--
IA.arrangableProfile.leatherRoll = { dx = 0.12, dy = 0.65, dz = 0.046, qz = 4 }
IA.arrangableProfile.hideRolledDeer = { dx = 0.11, dy = 0.65, dz = 0.032, qz = 4 }
IA.arrangableProfile.fabricRoll = { dx = 0.15, dy = 0.65, dz = 0.055, qz = 4, fz = 90 }

IA.arrangableProfile.bagConcretePowder = { dx = 0.3, dy = 0.18, dz = 0.16, qz = 1 }
IA.arrangableProfile.anvilMold = { dx = 0.26, dy = 0.36, dz = 0.075 }
IA.arrangableProfile.anvilMoldCast = { dx = 0.26, dy = 0.4, dz = 0.06 }
IA.arrangableProfile.woodenIngotMold = { dx = 0.2, dy = 0.36, dz = 0.038, qz = 4 }
IA.arrangableProfile.ceramicIngotCast = { dx = 0.15, dy = 0.31, dz = 0.032, qz = 4 }

IA.arrangableProfile.duffelBag = { dx = 0.29, dy = 0.76, dz = 0.1, qz = 1 }
IA.arrangableProfile.bowl = { dx = 0.19, dy = 0.19, dz = 0.025, qz = 6 }
IA.arrangableProfile.bowlFull = { dx = 0.19, dy = 0.19, dz = 0.04, qz = 1 }
IA.arrangableProfile.bowlFull2 = { dx = 0.22, dy = 0.22, dz = 0.04, qz = 1 } -- brain tan bowl is slightly bigger
IA.arrangableProfile.saucePan = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = -90 }
IA.arrangableProfile.saucePanFull = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = -90 }
IA.arrangableProfile.saucePanCopper = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 3, fz = 0 }
IA.arrangableProfile.saucePanCopperFull = { dx = 0.22, dy = 0.4, dz = 0.045, qz = 1, fz = 0 }

IA.arrangableProfile.potFull = {dx = 0.40, dy = 0.40, dz = 0.10, qz = 1 }
IA.arrangableProfile.marinara = {dx = 0.12, dy = 0.12, dz = 0.05}

--IA.arrangableProfile.rifle = { dx = 0.22, dy = 0.75, dz = 0.045, qz = 1 }
--IA.arrangableProfile.pistol = { dx = 0.22, dy = 0.30, dz = 0.045, qz = 1 }

IA.arrangableProfile.pouch = { dx = 0.2, dy = 0.07, dz = 0.1, qz = 1 }
IA.arrangableProfile.jar = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 45 }
IA.arrangableProfile.jarTall = { dx = 0.15, dy = 0.15, dz = 0.078, qz = 2 }
IA.arrangableProfile.sauce = { dx = 0.17, dy = 0.08, dz = 0.09, qz = 1 }
IA.arrangableProfile.cartonWide = {dx = 0.12, dy = 0.09, dz = 0.015, qz = 1, fz = 180}


--
-- Mesh profiles
--

-- Thanks to @CouncilOfPoorlyLitBaldPeople. Yes, I'm crediting you anyway :P
IA.meshProfiles["ammo/boxes/Ammobox"]                           = "ammoBox"
IA.meshProfiles["ammo/boxes/Ammobox_Rifle_Small"]               = "ammoBox"
IA.meshProfiles["ammo/boxes/Ammobox_Shotgun"]                   = "shotgunShellsBox"
IA.meshProfiles["weapons/ammo/762-556-308-223AmmoBox"]          = "ammoBox"

-- By me
IA.meshProfiles["WorldItems/Flask"]                             = "smallBottle"
IA.meshProfiles["WorldItems/Sportsbottle"]                      = "bottle"
IA.meshProfiles["WorldItems/Leather_Rolled"]                    = { profile = "leatherRoll", scale = 0.1 }
IA.meshProfiles["WorldItems/FabricRolled"]                      = { profile = "fabricRoll", scale = 0.14 }
IA.meshProfiles["WorldItems/Hide_Rolled_Deer"]                  = { profile = "hideRolledDeer", scale = 0.1 }
IA.meshProfiles["WorldItems/BagofConcretePowder"]               = { profile = "bagConcretePowder", scale = 0.2 }

IA.meshProfiles["WorldItems/WoodenMold_CeramicCast_AnvilBlock"] = { profile = "anvilMold", scale = 0.13 }
IA.meshProfiles["WorldItems/CeramicCast_AnvilBlock"]            = { profile = "anvilMold", scale = 0.13 }
IA.meshProfiles["WorldItems/WoodenMold_AnvilJeweller_Cast"]     = { profile = "anvilMoldCast", scale = 0.1 }
IA.meshProfiles["WorldItems/CeramicMold_AnvilJeweller"]         = { profile = "anvilMoldCast", scale = 0.1 }
IA.meshProfiles["WorldItems/WoodenMold_IngotCast"]              = { profile = "woodenIngotMold", scale = 0.09 }
IA.meshProfiles["WorldItems/Ceramic_IngotCast"]                 = { profile = "ceramicIngotCast", scale = 0.09 }

IA.meshProfiles["WorldItems/Clothing/DuffelBag_Ground"] = "duffelBag"
IA.meshProfiles["WorldItems/MapleSyrup"]                = "sauce"
IA.meshProfiles["WorldItems/Soysauce"]                  = "honey"
IA.meshProfiles["WorldItems/BBQ_Sauce"]                 = { profile = "sauce", scale = 0.22 }
IA.meshProfiles["WorldItems/Ketchup"]                   = "sauce"
IA.meshProfiles["WorldItems/Hotsauce"]                  = "smallBottle"
IA.meshProfiles["WorldItems/RiceVinegar"]               = "wineBottle"
IA.meshProfiles["WorldItems/Marinara"]                  = "marinara"
IA.meshProfiles["WorldItems/Bowl"]                      = "bowl"
IA.meshProfiles["WorldItems/Bowl_Kiln"]                 = "bowl"
IA.meshProfiles["WorldItems/BowlFood"]                  = "bowlFull"
IA.meshProfiles["WorldItems/BowlSoup"]                  = "bowlFull"
IA.meshProfiles["WorldItems/BowlRamen"]                 = "bowlFull"
IA.meshProfiles["WorldItems/BowlOfGlaze"]               = { profile = "bowlFull2", scale = 0.5 }
IA.meshProfiles["WorldItems/Bowl_Kiln_Full"]            = "bowlFull"
IA.meshProfiles["WorldItems/SaucePan"]                  = "saucePan"
IA.meshProfiles["WorldItems/SaucePan_FoodFluid"]        = "saucePanFull"
IA.meshProfiles["WorldItems/SaucePan_Copper"]           = { profile = "saucePanCopper", scale = 0.075 }
IA.meshProfiles["WorldItems/SaucePan_Copper_Water"]     = { profile = "saucePanCopperFull", scale = 0.075 }
IA.meshProfiles["WorldItems/SaucePan_Copper_Pasta"]     = { profile = "saucePanCopperFull", scale = 0.075 }
IA.meshProfiles["WorldItems/SaucePan_Copper_Rice"]      = { profile = "saucePanCopperFull", scale = 0.075 }
IA.meshProfiles["WorldItems/CookingPotFull"]            = "potFull"
IA.meshProfiles["WorldItems/JarLid"]                    = "jar"
IA.meshProfiles["WorldItems/PeanutButter"]              = "jarTall"
IA.meshProfiles["WorldItems/BalsamicVinegar"]           = "wineBottle"
IA.meshProfiles["WorldItems/Bottle"]                    = "wineBottle"
IA.meshProfiles["WorldItems/EmptyPopBottle"]            = "wineBottle"
IA.meshProfiles["WorldItems/Disinfectant"]              = "wineBottle"
IA.meshProfiles["WorldItems/Milk"]                      = "carton"

-- VFX
IA.meshProfiles["WorldItems/VFX_BeerBottle"]              = "wineBottle"
IA.meshProfiles["WorldItems/VFX_Carton"]                  = "cartonWide"
IA.meshProfiles["WorldItems/VFX_CoffeeCreamerBottle"]     = "bottle"
IA.meshProfiles["WorldItems/VFX_GlassBottle"]             = "wineBottle"
IA.meshProfiles["WorldItems/VFX_IcedTeaBottle"]           = "wineBottle"
IA.meshProfiles["WorldItems/VFX_LemonBottle"]             = "wineBottle"
IA.meshProfiles["WorldItems/VFX_Mustard"]                 = "honey"
IA.meshProfiles["WorldItems/VFX_PotForgedFull"]           = "potFull"
IA.meshProfiles["WorldItems/VFX_PotFull"]                 = "potFull"
IA.meshProfiles["WorldItems/VFX_Pouch"]                   = "pouch"

IA.arrangableProfile.roundFoodContainer = {dx = 0.32, dy = 0.32, dz = 0.06, qz = 4 }
IA.arrangableProfile.rectFoodContainer = {dx = 0.25, dy = 0.35, dz = 0.046, qz = 5 }

IA.meshProfiles["WorldItems/VFX_Container_FoodStorageContainer"] = "roundFoodContainer"
IA.meshProfiles["WorldItems/VFX_FoodStorageContainer"]           = "roundFoodContainer"
IA.meshProfiles["WorldItems/VFX_SM_FoodStorageContainer"]        = "roundFoodContainer"
IA.meshProfiles["WorldItems/VFX_MetalFoodStorageContainer"]      = {profile="rectFoodContainer", scale=1.2}
IA.meshProfiles["WorldItems/VFX_SM_MetalFoodStorageContainer"]   = {profile= "rectFoodContainer" , scale=1.2}

-- Sapph
IA.meshProfiles["WorldItems/CookingPot_Liquid"]       = "potFull"
IA.meshProfiles["WorldItems/EmptyBottle"]             = "wineBottle"

-- Authentic Z
IA.meshProfiles["WorldItems/WorldItem_AZ_AquaBottle"] = "bottle"
IA.meshProfiles["WorldItems/WorldItem_AZ_GymBottle"]  = "wineBottle"
