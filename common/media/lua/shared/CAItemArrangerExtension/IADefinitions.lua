IA = IA or {}

local IA = IA

--
-- Arrangable profiles
--
IA.arrangableProfile.leather = { dx = 0.12, dy = 0.65, dz = 0.046, qz = 4 }

--
-- Mesh profiles
--

-- Thanks to @CouncilOfPoorlyLitBaldPeople. Yes, I'm crediting you anyway :P
IA.meshProfiles["ammo/boxes/Ammobox"]                  = "ammoBox"
IA.meshProfiles["ammo/boxes/Ammobox_Rifle_Small"]      = "ammoBox"
IA.meshProfiles["ammo/boxes/Ammobox_Shotgun"]          = "shotgunShellsBox"
IA.meshProfiles["weapons/ammo/762-556-308-223AmmoBox"] = "ammoBox"

-- By me
IA.meshProfiles["WorldItems/Flask"]                    = "smallBottle"
IA.meshProfiles["WorldItems/Sportsbottle"]             = "bottle"
IA.meshProfiles["WorldItems/Leather_Rolled"]           = { profile = "leather", scale = 0.1 }
