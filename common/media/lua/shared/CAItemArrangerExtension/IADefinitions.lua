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
IA.arrangableProfile.bowl = { dx = 0.18, dy = 0.18, dz = 0.025, qz = 6 }
IA.arrangableProfile.bowlFull = { dx = 0.18, dy = 0.18, dz = 0.04, qz = 1 }
IA.arrangableProfile.bowlFull2 = { dx = 0.22, dy = 0.22, dz = 0.04, qz = 1 } -- brain tan bowl is slightly bigger
IA.arrangableProfile.saucePan = { dx = 0.22, dy = 0.22, dz = 0.045, qz = 3, fz = -125 }

IA.arrangableProfile.rifle = { dx = 0.22, dy = 0.75, dz = 0.045, qz = 1 }
IA.arrangableProfile.pistol = { dx = 0.22, dy = 0.30, dz = 0.045, qz = 1 }


--
-- Mesh profiles
--

-- Thanks to @CouncilOfPoorlyLitBaldPeople. Yes, I'm crediting you anyway :P
IA.meshProfiles["ammo/boxes/Ammobox"] = "ammoBox"
IA.meshProfiles["ammo/boxes/Ammobox_Rifle_Small"] = "ammoBox"
IA.meshProfiles["ammo/boxes/Ammobox_Shotgun"] = "shotgunShellsBox"
IA.meshProfiles["weapons/ammo/762-556-308-223AmmoBox"] = "ammoBox"

-- By me
IA.meshProfiles["WorldItems/Flask"] = "smallBottle"
IA.meshProfiles["WorldItems/Sportsbottle"] = "bottle"
IA.meshProfiles["WorldItems/Leather_Rolled"] = { profile = "leatherRoll", scale = 0.1 }
IA.meshProfiles["WorldItems/FabricRolled"] = { profile = "fabricRoll", scale = 0.14 }
IA.meshProfiles["WorldItems/Hide_Rolled_Deer"] = { profile = "hideRolledDeer", scale = 0.1 }
IA.meshProfiles["WorldItems/BagofConcretePowder"] = { profile = "bagConcretePowder", scale = 0.2 }

IA.meshProfiles["WorldItems/WoodenMold_CeramicCast_AnvilBlock"] = { profile = "anvilMold", scale = 0.13 }
IA.meshProfiles["WorldItems/CeramicCast_AnvilBlock"] = { profile = "anvilMold", scale = 0.13 }
IA.meshProfiles["WorldItems/WoodenMold_AnvilJeweller_Cast"] = { profile = "anvilMoldCast", scale = 0.1 }
IA.meshProfiles["WorldItems/CeramicMold_AnvilJeweller"] = { profile = "anvilMoldCast", scale = 0.1 }
IA.meshProfiles["WorldItems/WoodenMold_IngotCast"] = { profile = "woodenIngotMold", scale = 0.09 }
IA.meshProfiles["WorldItems/Ceramic_IngotCast"] = { profile = "ceramicIngotCast", scale = 0.09 }

IA.meshProfiles["WorldItems/Clothing/DuffelBag_Ground"] = { profile = "duffelBag", scale = 0.4 }
IA.meshProfiles["WorldItems/Bowl"] = { profile = "bowlEmpty", scale = 0.4 }
IA.meshProfiles["WorldItems/BowlFood"] = { profile = "bowlFull", scale = 0.4 }
IA.meshProfiles["WorldItems/BowlSoup"] = { profile = "bowlFull", scale = 0.4 }
IA.meshProfiles["WorldItems/BowlRamen"] = { profile = "bowlFull", scale = 0.4 }
IA.meshProfiles["WorldItems/BowlOfGlaze"] = { profile = "bowlFull2", scale = 0.5 }
IA.meshProfiles["WorldItems/SaucePan"] = { profile = "saucePan", scale = 0.4 }
IA.meshProfiles["WorldItems/SaucePan_FoodFluid"] = { profile = "saucePan", scale = 0.4 }
IA.meshProfiles["WorldItems/WorldItems/SaucePan_Copper"] = { profile = "saucePan", scale = 0.4 }
IA.meshProfiles["WorldItems/WorldItems/SaucePan_Copper_Water"] = { profile = "saucePan", scale = 0.4 }
