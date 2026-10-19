require("IAArrange")
local Utils = require("CAItemArrangeExtension/Utils")

local modify = Utils.modify

IA = IA or nil

if not IA then
  return
end

local IA = IA

local ap = IA.arrangableProfile
local mp = IA.meshProfiles

----
-- overrides
----
IA.arrangables["Base.SheetMetal"] = nil
IA.arrangables["Base.CopperSheet"] = nil
IA.arrangables["Base.SmallSheetMetal"] = nil
IA.arrangables["Base.SmallCopperSheet"] = nil

IA.arrangables["Base.IronBar"].mx = -0.24
ap.champagneBottle.fz = -270
ap.cocoaPowder.fz = 0
ap.ammoCarton.dz = 0.065

IA.arrangables["Base.JamFruit"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 90 }
IA.arrangables["Base.JamMarmalade"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 90 }
IA.arrangables["Base.MayonnaiseEmpty"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = -30 }
IA.arrangables["Base.MayonnaiseFull"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = -30 }
IA.arrangables["Base.RemouladeEmpty"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 0 }
IA.arrangables["Base.RemouladeFull"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 0 }

--
-- Mesh profiles
--

-- Thanks to @CouncilOfPoorlyLitBaldPeople. Yes, I'm crediting you anyway :P
mp["ammo/boxes/Ammobox"] = { dx = 0.2, dy = 0.1, dz = 0.02, qz = 6 }
mp["ammo/boxes/Ammobox_Rifle_Small"] = { dx = 0.2, dy = 0.1, dz = 0.02, qz = 6 }
mp["ammo/boxes/Ammobox_Shotgun"] = { dx = 0.14, dy = 0.08, dz = 0.03, qz = 3 }
mp["weapons/ammo/762-556-308-223AmmoBox"] = { qz = 6, fz = -90, flip = true }

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

mp["weapons/1handed/AK47Bayonet"] = { fz = 270 }
mp["weapons/1handed/AKBayonet"] = { fz = 270 }
mp["weapons/1handed/AKOldBayonet"] = { fz = 270 }
mp["weapons/1handed/Axe_Bone_Hand"] = { fz = 270 }
mp["weapons/1handed/Axe_Forged_1Handed_Hand"] = { fz = 270 }
mp["weapons/1handed/BadmintonRacket"] = { fz = 270 }
mp["weapons/1handed/Banjo"] = { fz = 270 }
mp["weapons/1handed/Banjo_Broken"] = { fz = 270 }
mp["weapons/1handed/BaseballBat_Broken"] = { fz = 270 }
mp["weapons/1handed/BaseballBat_Broken_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/BoneClub_MetalSpiked_Hand"] = { fz = 270 }
mp["weapons/1handed/BoneClub_MetalSpikes_Short"] = { fz = 270 }
mp["weapons/1handed/Bone_ClubShort_Hand"] = { fz = 270 }
mp["weapons/1handed/Bone_Club_Hand"] = { fz = 270 }
mp["weapons/1handed/Bone_Long_Hand"] = { fz = 270 }
mp["weapons/1handed/Bone_Sharp_Long_Hand"] = { fz = 270 }
mp["weapons/1handed/Bone_Short_Hand"] = { fz = 270 }
mp["weapons/1handed/BowlingPin_Hand"] = { fz = 270 }
mp["weapons/1handed/BowlingPin_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/Brass_Nameplate_Hand"] = { fz = 270 }
mp["weapons/1handed/BreadKnife"] = { fz = 270 }
mp["weapons/1handed/ButterKnife"] = { fz = 270 }
mp["weapons/1handed/ButterflyKnife"] = { fz = 270 }
mp["weapons/1handed/ButterflyKnife2"] = { fz = 270 }
mp["weapons/1handed/CanOpener_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Can_MediumHandle_Hand"] = { fz = 270 }
mp["weapons/1handed/Can_ShortHandle_Hand"] = { fz = 270 }
mp["weapons/1handed/Can_TreeBranch_Hand"] = { fz = 270 }
mp["weapons/1handed/Can_WoodenStick_Hand"] = { fz = 270 }
mp["weapons/1handed/CarvingFork_Hand"] = { fz = 270 }
mp["weapons/1handed/ChairLeg"] = { fz = 270 }
mp["weapons/1handed/ChairLeg_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/ChiselWoodHandle_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Chisel_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Chisel_Hot_Hand"] = { fz = 270 }
mp["weapons/1handed/Crowbar"] = { fz = 270 }
mp["weapons/1handed/Crowbar_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Cudgel_Broken_Hand"] = { fz = 270 }
mp["weapons/1handed/Cudgel_Broken_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/Drumstick"] = { fz = 270 }
mp["weapons/1handed/DumbBell"] = { fz = 270 }
mp["weapons/1handed/DumbBell_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/File_Big_Jewellers_Hand"] = { fz = 270 }
mp["weapons/1handed/FirePoker"] = { fz = 270 }
mp["weapons/1handed/Firewood_Hand"] = { fz = 270 }
mp["weapons/1handed/Firewood_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/FishGaffHook"] = { fz = 270 }
mp["weapons/1handed/Flint_Stone_Hand"] = { fz = 270 }
mp["weapons/1handed/Flute"] = { fz = 270 }
mp["weapons/1handed/Fork"] = { fz = 270 }
mp["weapons/1handed/Fork_Bone_Hand"] = { fz = 270 }
mp["weapons/1handed/Fork_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Fork_Wood_Hand"] = { fz = 270 }
mp["weapons/1handed/FryingPan"] = { fz = 270 }
mp["weapons/1handed/FryingPan_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/GardenFork_ForkBroken"] = { fz = 270 }
mp["weapons/1handed/GardenFork_HandleBroken"] = { fz = 270 }
mp["weapons/1handed/GolfClub"] = { fz = 270 }
mp["weapons/1handed/GridlePan"] = { fz = 270 }
mp["weapons/1handed/Guitar_Acoustic_Broken"] = { fz = 270 }
mp["weapons/1handed/Guitar_ElectricBass_Broken"] = { fz = 270 }
mp["weapons/1handed/Guitar_Electric_Broken"] = { fz = 270 }
mp["weapons/1handed/HandAxe"] = { fz = 270 }
mp["weapons/1handed/HandAxe_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/HandFork"] = { fz = 270 }
mp["weapons/1handed/HandScythe"] = { fz = 270 }
mp["weapons/1handed/Handle_Hand"] = { fz = 270 }
mp["weapons/1handed/Handle_Medium_Spiked_Hand"] = { fz = 270 }
mp["weapons/1handed/HatchetSaw_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/1handed/HatchetSpikes_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/1handed/HockeyStick_Broken_Hand"] = { fz = 270 }
mp["weapons/1handed/HockeyStick_Broken_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/Hook_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/HuntingKnife"] = { fz = 270 }
mp["weapons/1handed/HuntingKnife_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/1handed/IceAxe"] = { fz = 270 }
mp["weapons/1handed/IcePick"] = { fz = 270 }
mp["weapons/1handed/JawBone_Axe_Hand"] = { fz = 270 }
mp["weapons/1handed/JawBone_Hand"] = { fz = 270 }
mp["weapons/1handed/JawBone_Handle_Hand"] = { fz = 270 }
mp["weapons/1handed/JudgesGavel_Hand"] = { fz = 270 }
mp["weapons/1handed/Katana_Broken"] = { fz = 270 }
mp["weapons/1handed/KitchenKnife_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife"] = { fz = 270 }
mp["weapons/1handed/KnifeHunting_Forged_Basic_Hand"] = { fz = 270 }
mp["weapons/1handed/KnifeHunting_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/KnifeKitchen_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/KnifeParing_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife_Bone_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife_DaggerCrafted_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife_FairbairnSykes_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife_Fillet_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife_RailroadSpike_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife_Steak_Hand"] = { fz = 270 }
mp["weapons/1handed/Knife_Sushi_Fillet_Hand"] = { fz = 270 }
mp["weapons/1handed/LSHarmonica"] = { fz = 270 }
mp["weapons/1handed/LeadPipe"] = { fz = 270 }
mp["weapons/1handed/LetterOpener"] = { fz = 270 }
mp["weapons/1handed/LongHandle_Broken_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/M1905Bayonet"] = { fz = 270 }
mp["weapons/1handed/M1917Bayonet"] = { fz = 270 }
mp["weapons/1handed/M4Bayonet"] = { fz = 270 }
mp["weapons/1handed/M5Bayonet"] = { fz = 270 }
mp["weapons/1handed/M6Bayonet"] = { fz = 270 }
mp["weapons/1handed/M7Bayonet"] = { fz = 270 }
mp["weapons/1handed/MaceHandle_CircularSaw_Hand"] = { fz = 270 }
mp["weapons/1handed/MaceHandle_RailSpike_Hand"] = { fz = 270 }
mp["weapons/1handed/MaceHandle_RakeHead_Hand"] = { fz = 270 }
mp["weapons/1handed/MaceHandle_Spiked_Hand"] = { fz = 270 }
mp["weapons/1handed/Mace_Basic_Hand"] = { fz = 270 }
mp["weapons/1handed/Mace_Hand"] = { fz = 270 }
mp["weapons/1handed/Mace_Handle_Hand"] = { fz = 270 }
mp["weapons/1handed/Mace_RoundAngle_Short_Hand"] = { fz = 270 }
mp["weapons/1handed/Machete"] = { fz = 270 }
mp["weapons/1handed/Machete_BladeHandle_Hand"] = { fz = 270 }
mp["weapons/1handed/Machete_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Machete_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/1handed/MauserBayonet"] = { fz = 270 }
mp["weapons/1handed/MeatCleaver"] = { fz = 270 }
mp["weapons/1handed/MeatCleaver_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/MeatCleaver_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/1handed/MetalBar_Half_Hand"] = { fz = 270 }
mp["weapons/1handed/MetalPipe_Broken_Hand"] = { fz = 270 }
mp["weapons/1handed/MetalPipe_RailSpike_Hand"] = { fz = 270 }
mp["weapons/1handed/Nightstick"] = { fz = 270 }
mp["weapons/1handed/Pen"] = { fz = 270 }
mp["weapons/1handed/PenKnife"] = { fz = 270 }
mp["weapons/1handed/PenKnife2"] = { fz = 270 }
mp["weapons/1handed/PenMulticolor_Hand"] = { fz = 270 }
mp["weapons/1handed/PenSpiffo_Hand"] = { fz = 270 }
mp["weapons/1handed/Pencil"] = { fz = 270 }
mp["weapons/1handed/PencilSpiffo_Hand"] = { fz = 270 }
mp["weapons/1handed/PipeWrench"] = { fz = 270 }
mp["weapons/1handed/Plank_Broken_Hand"] = { fz = 270 }
mp["weapons/1handed/Plank_Broken_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/Plastic_Fork_Hand"] = { fz = 270 }
mp["weapons/1handed/Plastic_Knife_Hand"] = { fz = 270 }
mp["weapons/1handed/Plastic_Spoon_Hand"] = { fz = 270 }
mp["weapons/1handed/Plunger"] = { fz = 270 }
mp["weapons/1handed/Plunger_BarbedWire_Hand"] = { fz = 270 }
mp["weapons/1handed/Railroad_Spike_Hand"] = { fz = 270 }
mp["weapons/1handed/RollingPin"] = { fz = 270 }
mp["weapons/1handed/SKSBayonet"] = { fz = 270 }
mp["weapons/1handed/SaucePan"] = { fz = 270 }
mp["weapons/1handed/SaucePan_Copper_Hand"] = { fz = 270 }
mp["weapons/1handed/Saw_Flint_Hand"] = { fz = 270 }
mp["weapons/1handed/Scalpel"] = { fz = 270 }
mp["weapons/1handed/ScrapMetal_MetalBlock_Hand"] = { fz = 270 }
mp["weapons/1handed/ScrewDriver_Crafted_Hand"] = { fz = 270 }
mp["weapons/1handed/ScrewDriver_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/1handed/Screwdriver"] = { fz = 270 }
mp["weapons/1handed/Scythe_Primitive_Hand"] = { fz = 270 }
mp["weapons/1handed/ShankGlass_Hand"] = { fz = 270 }
mp["weapons/1handed/Shiv"] = { fz = 270 }
mp["weapons/1handed/Shiv2"] = { fz = 270 }
mp["weapons/1handed/Shiv_SpearCrude_Longer_Hand"] = { fz = 270 }
mp["weapons/1handed/Shiv_SpearStoneBasic_Head_Hand"] = { fz = 270 }
mp["weapons/1handed/Shiv_SpearStone_High_Hand"] = { fz = 270 }
mp["weapons/1handed/Shiv_Spear_Crude_Hand"] = { fz = 270 }
mp["weapons/1handed/Shiv_Toothbrush_Hand"] = { fz = 270 }
mp["weapons/1handed/Shovel_HeadBroken"] = { fz = 270 }
mp["weapons/1handed/SmashedBottle"] = { fz = 270 }
mp["weapons/1handed/SpearForged_Basic_Head_Hand"] = { fz = 270 }
mp["weapons/1handed/Spear_Crude_Head_Hand"] = { fz = 270 }
mp["weapons/1handed/Spear_Crude_Longer_Head_Hand"] = { fz = 270 }
mp["weapons/1handed/Spear_Forged_Head_Hand"] = { fz = 270 }
mp["weapons/1handed/Spoon"] = { fz = 270 }
mp["weapons/1handed/Spoon_Bone_Hand"] = { fz = 270 }
mp["weapons/1handed/Spoon_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Stake"] = { fz = 270 }
mp["weapons/1handed/Steel_Rod_Half_Hand"] = { fz = 270 }
mp["weapons/1handed/Steel_Rod_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_Basic_Broken_Bot_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_Broken_Bot_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_ScrapMetal_Bot_NOTANG_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_ScrapMetal_NoCross_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_Short_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_SingleEdgeShort_Basic_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_SingleEdge_Basic_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_SingleEdge_Hand"] = { fz = 270 }
mp["weapons/1handed/Sword_SingleEdge_Short_Hand"] = { fz = 270 }
mp["weapons/1handed/T56Bayonet"] = { fz = 270 }
mp["weapons/1handed/TableLegBroken_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/TableLeg_Broken_Hand"] = { fz = 270 }
mp["weapons/1handed/Tapered_Punch_Hand"] = { fz = 270 }
mp["weapons/1handed/TennisRacket"] = { fz = 270 }
mp["weapons/1handed/TireIron"] = { fz = 270 }
mp["weapons/1handed/ToyChicken"] = { fz = 270 }
mp["weapons/1handed/TreeBranch_Bone_Hand"] = { fz = 270 }
mp["weapons/1handed/TreeBranch_Hand"] = { fz = 270 }
mp["weapons/1handed/TreeBranch_NailSpike_Hand"] = { fz = 270 }
mp["weapons/1handed/TreeBranch_RailSpike_Hand"] = { fz = 270 }
mp["weapons/1handed/TrowelMason_Hand"] = { fz = 270 }
mp["weapons/1handed/Trumpet"] = { fz = 270 }
mp["weapons/1handed/Violin"] = { fz = 270 }
mp["weapons/1handed/WalkieTalkie"] = { fz = 270 }
mp["weapons/1handed/WoodenMallet"] = { fz = 270 }
mp["weapons/1handed/WoodenStick_Broken_Hand"] = { fz = 270 }
mp["weapons/1handed/WoodenStick_Broken_Nail_Hand"] = { fz = 270 }
mp["weapons/1handed/WoodenStick_Hand"] = { fz = 270 }
mp["weapons/1handed/WoodenStick_Nails_Hand"] = { fz = 270 }
mp["weapons/1handed/Wrench"] = { fz = 270 }
mp["weapons/1handed/Yardstick"] = { fz = 270 }
mp["weapons/2handed/AxeCircularSaw_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/2handed/AxeSpikes_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/2handed/Axe_Forged_2Handed_Hand"] = { fz = 270 }
mp["weapons/2handed/Axe_StoneTwoHanded_Hand"] = { fz = 270 }
mp["weapons/2handed/BarBell"] = { fz = 270 }
mp["weapons/2handed/BarBell_Forged_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_CircularSaw_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_Fork_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_Mace_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_Metal_Bolts_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_Metal_CircularSaw"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_Nailed_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_RailSpike_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_Rake_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_TinCanned_Hand"] = { fz = 270 }
mp["weapons/2handed/BaseBallBat_UnusableMetal_Hand"] = { fz = 270 }
mp["weapons/2handed/Baseballbat"] = { fz = 270 }
mp["weapons/2handed/BoltCutters"] = { fz = 270 }
mp["weapons/2handed/Broom"] = { fz = 270 }
mp["weapons/2handed/Broom_BarbedWire_Hand"] = { fz = 270 }
mp["weapons/2handed/Broom_Crafted_Hand"] = { fz = 270 }
mp["weapons/2handed/Can_LongHandle_Hand"] = { fz = 270 }
mp["weapons/2handed/CanoePadel"] = { fz = 270 }
mp["weapons/2handed/CanoePadelX2"] = { fz = 270 }
mp["weapons/2handed/CanoePadelvX2_Broken_Hand"] = { fz = 270 }
mp["weapons/2handed/ConcreteClubMetal_Bucket_Hand"] = { fz = 270 }
mp["weapons/2handed/ConcreteClubMetal_Kettle_Hand"] = { fz = 270 }
mp["weapons/2handed/ConcreteClubWood_Bucket_Hand"] = { fz = 270 }
mp["weapons/2handed/ConcreteClubWood_Kettle_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_Bone_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_BreakDisk_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_CircularSaw_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_Fork_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_Spade_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_TreeBranch_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_TwoHanded_Mace_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_TwoHanded_Nail_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_TwoHanded_RailSpike_Hand"] = { fz = 270 }
mp["weapons/2handed/Cudgel_Unusable_Metal_Hand"] = { fz = 270 }
mp["weapons/2handed/EngineParts_Bludgeon_Hand"] = { fz = 270 }
mp["weapons/2handed/FireAxe"] = { fz = 270 }
mp["weapons/2handed/FishingRod_Crafted"] = { fz = 270 }
mp["weapons/2handed/FishingRod_Modern"] = { fz = 270 }
mp["weapons/2handed/GardenFork"] = { fz = 270 }
mp["weapons/2handed/GardenFork_Forged_Hand"] = { fz = 270 }
mp["weapons/2handed/GardenHoe"] = { fz = 270 }
mp["weapons/2handed/Guitar_Acoustic"] = { fz = 270 }
mp["weapons/2handed/Guitar_ElectricBassBlack"] = { fz = 270 }
mp["weapons/2handed/Guitar_ElectricBassBlue"] = { fz = 270 }
mp["weapons/2handed/Guitar_ElectricBassRed"] = { fz = 270 }
mp["weapons/2handed/Guitar_ElectricBlack"] = { fz = 270 }
mp["weapons/2handed/Guitar_ElectricBlue"] = { fz = 270 }
mp["weapons/2handed/Handle_PickAxe_Broken_Hand"] = { fz = 270 }
mp["weapons/2handed/Handle_PickAxe_Hand"] = { fz = 270 }
mp["weapons/2handed/Handle_PickAxe_Spiked_Hand"] = { fz = 270 }
mp["weapons/2handed/HobbyHorse_Hand"] = { fz = 270 }
mp["weapons/2handed/HockeyStick"] = { fz = 270 }
mp["weapons/2handed/HockeyStick_Nails_Hand"] = { fz = 270 }
mp["weapons/2handed/HockeyStick_Saw_Hand"] = { fz = 270 }
mp["weapons/2handed/IceHockeyStick"] = { fz = 270 }
mp["weapons/2handed/IceHockeyStick_Barbed_Hand"] = { fz = 270 }
mp["weapons/2handed/JawBone_Axe_2Handed_Hand"] = { fz = 270 }
mp["weapons/2handed/Katana"] = { fz = 270 }
mp["weapons/2handed/Keytar"] = { fz = 270 }
mp["weapons/2handed/LaCrosseStick"] = { fz = 270 }
mp["weapons/2handed/LeafRake"] = { fz = 270 }
mp["weapons/2handed/LongHandle_BrakeDisk_Hand"] = { fz = 270 }
mp["weapons/2handed/LongHandle_CircularSaw_Hand"] = { fz = 270 }
mp["weapons/2handed/LongHandle_RailSpike_Hand"] = { fz = 270 }
mp["weapons/2handed/LongHandle_RakeHead_Hand"] = { fz = 270 }
mp["weapons/2handed/Mace_LongHandle_Basic_Hand"] = { fz = 270 }
mp["weapons/2handed/Mace_LongHandle_Hand"] = { fz = 270 }
mp["weapons/2handed/Mace_RoundAngle_Hand"] = { fz = 270 }
mp["weapons/2handed/Maul_Stone_Hand"] = { fz = 270 }
mp["weapons/2handed/MeatCleaverApzxe_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/2handed/MetalBar_Full_Hand"] = { fz = 270 }
mp["weapons/2handed/Mop"] = { fz = 270 }
mp["weapons/2handed/Mop_Hand"] = { fz = 270 }
mp["weapons/2handed/NailedPlank"] = { fz = 270 }
mp["weapons/2handed/PickAxe_Hand"] = { fz = 270 }
mp["weapons/2handed/Plank"] = { fz = 270 }
mp["weapons/2handed/Plank_BrakeDisk_Hand"] = { fz = 270 }
mp["weapons/2handed/Plank_CircularSaw_Hand"] = { fz = 270 }
mp["weapons/2handed/Plank_Saw_Hand"] = { fz = 270 }
mp["weapons/2handed/Plunger_Spear_Hand"] = { fz = 270 }
mp["weapons/2handed/PoolCue"] = { fz = 270 }
mp["weapons/2handed/PoweredAxe"] = { fz = 270 }
mp["weapons/2handed/Railroad_SpikePullerLRG_Hand"] = { fz = 270 }
mp["weapons/2handed/Railroad_SpikePuller_ModernLRG_Hand"] = { fz = 270 }
mp["weapons/2handed/Rake"] = { fz = 270 }
mp["weapons/2handed/ScrapMetal_Bludgeon_Hand"] = { fz = 270 }
mp["weapons/2handed/ScrapMetal_BrakeDisk_Hand"] = { fz = 270 }
mp["weapons/2handed/ScrapMetal_ForkHead_Hand"] = { fz = 270 }
mp["weapons/2handed/ScrapMetal_MetalBlock_2Handed_Hand"] = { fz = 270 }
mp["weapons/2handed/ScrapMetal_RakeHead_Hand"] = { fz = 270 }
mp["weapons/2handed/ScrapMetal_SpadeHead_Hand"] = { fz = 270 }
mp["weapons/2handed/Shaft_Broken_Hand"] = { fz = 270 }
mp["weapons/2handed/Shaft_Hand"] = { fz = 270 }
mp["weapons/2handed/Shaft_Spear_Hand"] = { fz = 270 }
mp["weapons/2handed/Shovel"] = { fz = 270 }
mp["weapons/2handed/Shovel02"] = { fz = 270 }
mp["weapons/2handed/SnowShovel"] = { fz = 270 }
mp["weapons/2handed/Spade_Forged_Hand"] = { fz = 270 }
mp["weapons/2handed/Spade_Wood_Hand"] = { fz = 270 }
mp["weapons/2handed/SpearCrafted"] = { fz = 270 }
mp["weapons/2handed/SpearForged_Basic_Hand"] = { fz = 270 }
mp["weapons/2handed/SpearHandFork"] = { fz = 270 }
mp["weapons/2handed/SpearHuntingKnife"] = { fz = 270 }
mp["weapons/2handed/SpearKnife"] = { fz = 270 }
mp["weapons/2handed/SpearScissors"] = { fz = 270 }
mp["weapons/2handed/SpearScrewdriver"] = { fz = 270 }
mp["weapons/2handed/Spear_BoneLong_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_BoneSmall_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Crude_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Crude_Longer_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_FightingKnife_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Forged_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Glass_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_KnifeForged_Large_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_KnifeForged_Small_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Knife_ScrapMetal_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Knife_Steak_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Stone_Hand"] = { fz = 270 }
mp["weapons/2handed/Spear_Stone_High_Hand"] = { fz = 270 }
mp["weapons/2handed/StoneAxe_Hand"] = { fz = 270 }
mp["weapons/2handed/TableLeg"] = { fz = 270 }
mp["weapons/2handed/TableLeg_Chain_Hand"] = { fz = 270 }
mp["weapons/2handed/TableLeg_Nails_Hand"] = { fz = 270 }
mp["weapons/2handed/TableLeg_SawHead_Hand"] = { fz = 270 }
mp["weapons/2handed/TreeSapling_Hand"] = { fz = 270 }
mp["weapons/2handed/Umbrella_Closed"] = { fz = 270 }
mp["weapons/2handed/WoodAxe_Forged_Hand"] = { fz = 270 }
mp["weapons/2handed/WoodToyHorse"] = { fz = 270 }
mp["weapons/2handed/WoodToyHorse"] = { fz = 270 }

mp["weapons/1handed/HockeyStick_Broken_Nails_Hand"] = { fz = 270, dx = 0.23 }
mp["weapons/1handed/HockeyStick_Broken_Hand"] = { fz = 270, dx = 0.23 }
mp["weapons/2handed/HockeyStick_Nails_Hand"] = { fz = 270, dx = 0.23 }
mp["weapons/2handed/HockeyStick_Saw_Hand"] = { fz = 270, dx = 0.23 }

mp["Weapons/1Handed/EntrenchingTool_Blade"] = { mz = 0.012 }
mp["Weapons/1Handed/EntrenchingTool_Blunt"] = { mz = 0.012 }
mp["Weapons/1Handed/EntrenchingTool_Folded"] = { mz = 0.02 }
mp["weapons/1handed/BallPeenHammer_Hand"] = { fz = 270 }
mp["weapons/1handed/ClubHammer"] = { fz = 270 }
mp["weapons/1handed/HammerClub_Forged_Hand"] = { flipZ = true, fz = 180, dy = 0.4, dx = 0.13, mz = 0.012 }
mp["weapons/1handed/HammerClub_Forged_Hand"] = { fz = 270 }
mp["weapons/1handed/Hammer_Forged_Hand"] = { flipZ = true, fz = 180 }
mp["weapons/1handed/Hammer_Forged_Hand"] = { fz = 270, dy = 0.4, dx = 0.22 }
mp["weapons/1handed/Hammer_Smithing_Hand"] = { flipZ = true, fz = 180 }
mp["weapons/1handed/Hammer_Smithing_Hand"] = { fz = 270 }
mp["weapons/1handed/MetalBar_Half_Hand"] = { qz = 8 }
mp["weapons/1handed/Steel_Rod_Half_Hand"] = { flipZ = true, qz = 8 }
mp["weapons/1handed/Steel_Rod_Hand"] = { flipZ = true, qz = 8 }
mp["weapons/1handed/StoneHammer_Hand"] = { fz = 270 }
mp["weapons/2handed/MetalBar_Full_Hand"] = { qz = 8 }
mp["weapons/2handed/SledgeHammer"] = { fz = 270 }
mp["weapons/2handed/SledgeHammer02"] = { fz = 270 }

--Base.545x39Carton | static: nil | world: WorldItems/Parcel4_Text
--Base.556Carton | static: WorldItems/Parcel4_Text | world: WorldItems/Parcel4_Text
--Base.762x39BulletsCarton | static: WorldItems/Parcel4_Text | world: WorldItems/Parcel4_Text
--Base.762x39Carton | static: nil | world: WorldItems/Parcel4_Text
--Base.762x54rCarton | static: nil | world: WorldItems/Parcel4_Text
--Base.792x57Carton | static: nil | world: WorldItems/Parcel4_Text
--Base.Bullets50CalCarton | static: nil | world: WorldItems/Parcel4_Text
--Base.Bullets50MagnumCarton | static: nil | world: WorldItems/Parcel4_Text
--Base.Bullets9x39Carton | static: nil | world: WorldItems/Parcel4_Text

mp["WorldItems/Parcel4_Text"] = ap.ammoCarton
mp["BleachBottle"] = { dx = 0.1, dy = 0.16, dz = 0.11, fz = 180 }
mp["CaffinePills"] = { dx = 0.1, dy = 0.1, dz = 0.07, fz = 153, s = 0.13 }
mp["Jar"] = { dx = 0.12, dy = 0.12, dz = 0.06, qz = 3, fz = 45, s = 0.4 }
mp["PillBottle"] = { dx = 0.12, dy = 0.12, dz = 0.06, qz = 3, fz = 45, s = 1.56 }
mp["SpiffoPlushieFull"] = { fz = 180 }
mp["WorldItems/BBQ_Sauce"] = { dx = 0.15, dy = 0.08, dz = 0.09, fz = -90 }
mp["WorldItems/BagofConcretePowder"] = { dy = 0.18, s = 0.2 }
mp["WorldItems/BalsamicVinegar"] = { dx = 0.12, dy = 0.12, dz = 0.04, fz = 270 }
mp["WorldItems/Bottle"] = { dx = 0.12, dy = 0.12, dz = 0.04, fz = -90 }
mp["WorldItems/Bowl"] = { dx = 0.19, dy = 0.19, dz = 0.025, qz = 6 }
mp["WorldItems/BowlFood"] = { dz = 0.04 }
mp["WorldItems/Bowl_Kiln"] = { dx = 0.19, dy = 0.19, dz = 0.025, qz = 6 }
mp["WorldItems/Bowl_Kiln_Full"] = { dx = 0.19, dy = 0.19, dz = 0.04 }
mp["WorldItems/BrakeDisk"] = { qz = 4 }
mp["WorldItems/BreadSlices"] = { qz = 6, fz = -10, dz = 0.007, s = 0.3 }
mp["WorldItems/Brochure"] = { dz = 0.03, fy = 180, flipX = true, flipY = true, s = 0.125 }
mp["WorldItems/CannedSardinesOpen"] = { dx = 0.1, dy = 0.15, dz = 0.015, fz = 270 }
mp["WorldItems/CarBumper"] = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8, s = 0.25 }
mp["WorldItems/CarDoor"] = { dx = 0.8, dy = 0.8, dz = 0.018, qz = 8, s = 0.25 }
mp["WorldItems/CarHood"] = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8 }
mp["WorldItems/CarJack"] = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8, s = 0.25 }
mp["WorldItems/CarParts"] = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8, s = 0.25 }
mp["WorldItems/CarSeat"] = { dy = 0.45, s = 0.4 }
mp["WorldItems/CarTrunkLid"] = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8, s = 0.25 }
mp["WorldItems/CarWindshield"] =
  { dx = 0.84, dy = 0.39, dz = 0.018, mx = -0.135, my = -0.182, qz = 8, fz = 0, s = 0.25 }
mp["WorldItems/Toothbrush"] = {
  fz = 180, --[[mx = -0.02]]
}

mp["WorldItems/CeramicCast_AnvilBlock"] = { dx = 0.26, qz = 3, s = 0.13 }
mp["WorldItems/Ceramic_IngotCast"] = { qz = 4 }
mp["WorldItems/CleaningLiquid"] = { dx = 0.17, dy = 0.08, dz = 0.09, s = 0.5 }
mp["WorldItems/Clothing/ALICE_Pack_Ground"] = { dy = 0.32, my = 0.08, mz = -0.008, fy = -18, fz = -90 }
mp["WorldItems/Clothing/BigHikingBag_Ground"] =
  { dx = 0.32, dy = 0.32, dz = 0.2, my = 0.18, mz = 0.11, fx = -262, fz = 270 }
mp["WorldItems/Clothing/Briefcase"] = { dx = 0.1, dz = 0.11, fz = 180, flipX = true, flipY = true }
mp["WorldItems/Clothing/DuffelBag_Ground"] = { dx = 0.29, dy = 0.76, dz = 0.1 }
mp["WorldItems/Clothing/HikingBag_Ground"] = { dx = 0.32, dz = 0.18, my = 0.18, mz = 0.11, fx = 98, fz = -90 }
mp["WorldItems/Clothing/SandBag_Ground"] = { dx = 0.33, dy = 0.6, dz = 0.04, qz = 3 }
mp["WorldItems/Clothing/SchoolBag_Ground"] = { dz = 0.14, my = -0.07, fz = 180, flipY = true, flip = true }
mp["WorldItems/CookingPotFull"] = { dz = 0.1 }
mp["WorldItems/Cornmeal"] = { dx = 0.2, dy = 0.07, dz = 0.1, s = 0.126 }
mp["WorldItems/DipJar"] = { dx = 0.12, dy = 0.12, dz = 0.039, qz = 3, fz = -180, s = 0.12 }
mp["WorldItems/DirtBag"] = { dz = 0.04, qz = 3, flip = true }
mp["WorldItems/Disinfectant"] = { dy = 0.12, dz = 0.04, fz = -90 }
mp["WorldItems/Doll"] = { fz = 180 }
mp["WorldItems/EmptyPopBottle"] = { dz = 0.04, fz = -90 }
mp["WorldItems/FabricRolled"] = { dx = 0.15, dy = 0.65, dz = 0.055, qz = 4, fz = 90, s = 0.14 }
mp["WorldItems/Flask"] = { dy = 0.05, fz = 180, flip = true }
mp["WorldItems/Flier"] = { qz = 20 }
mp["WorldItems/Flour"] = { dy = 0.33, dz = 0.1, fz = -90 }
mp["WorldItems/Frog"] = { flipZ = true, fz = 180 }
mp["WorldItems/FrozenFoodBag"] = { qz = 4, flip = true }
mp["WorldItems/GranolaBar"] = { dx = 0.09, qz = 4, flip = true }
mp["WorldItems/HairDye"] = { dx = 0.12, dy = 0.12, dz = 0.04, fz = -90 }
mp["WorldItems/Hide_Rolled_Deer"] = { dy = 0.65, qz = 4, s = 0.1 }
mp["WorldItems/JarFood"] = { qz = 3, fz = 45 }
mp["WorldItems/JarFood_Open"] = { fz = 45 }
mp["WorldItems/JarLid"] = { qz = 3, fz = 45 }
mp["WorldItems/JarOpen"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 45 }
mp["WorldItems/Jar_Roe"] = { qz = 3, fz = 45 }
mp["WorldItems/Jar_Roe_Open"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 45, s = 0.5 }
mp["WorldItems/Ketchup"] = { dx = 0.17, dy = 0.08, dz = 0.09 }
mp["WorldItems/Leather_Rolled"] = { qz = 4, s = 0.4 }
mp["WorldItems/LightBulb"] = { dx = 0.11, dy = 0.12, dz = 0.02, flip = true }
mp["WorldItems/Lightbar"] = { dx = 0.8, dy = 0.8, dz = 0.014, qz = 8, s = 0.25 }
mp["WorldItems/MacAndCheese"] = { qz = 2 }
mp["WorldItems/MapleSyrup"] = { dx = 0.17, dy = 0.08, dz = 0.09 }
mp["WorldItems/Margerine"] = { dx = 0.1, dy = 0.15, dz = 0.015, qz = 3, fz = 270, s = 0.28 }
mp["WorldItems/Marinara"] = { dx = 0.12, dy = 0.12, dz = 0.05, qz = 3 }
mp["WorldItems/Milk"] = { dx = 0.1, dy = 0.1, dz = 0.015, fz = 180 }
mp["WorldItems/Muffler"] = { dx = 0.24, dy = 0.5, dz = 0.042, qz = 4, fz = 90, s = 0.4 }
mp["WorldItems/NormalGasTank1"] = { dx = 0.63, dz = 0.085, my = -0.07, qz = 2, s = 0.4 }
mp["WorldItems/PainKillers"] = { dx = 0.25, dy = 0.24, dz = 0.006, qz = 5, fz = 90, s = 1.12 }
mp["WorldItems/PeanutButter"] = { dx = 0.15, dy = 0.15, dz = 0.078, qz = 2 }
mp["WorldItems/Pizza"] = { qz = 5 }
mp["WorldItems/PizzaSlice"] = { qz = 5 }
mp["WorldItems/Plumpabug_Plushie"] = { fz = 180 }
mp["WorldItems/PlushieBadger"] = { fz = 180 }
mp["WorldItems/PlushieBadger"] = { fz = 180 }
mp["WorldItems/PlushieBeaver"] = { fz = 180 }
mp["WorldItems/PlushieFox"] = { fz = 180 }
mp["WorldItems/PlushieHedgehog"] = { fz = 180 }
mp["WorldItems/PlushieHedgehog"] = { fz = 180 }
mp["WorldItems/PlushieMole"] = { fz = 180 }
mp["WorldItems/PlushieMole"] = { fz = 180 }
mp["WorldItems/PlushieRabbit"] = { fz = 180 }
mp["WorldItems/PlushieSquirrel"] = { fz = 180 }
mp["WorldItems/Plushie_EyeOfCthulhu"] = { fz = 180 }
mp["WorldItems/Plushie_Pancho"] = { fz = 180 }
mp["WorldItems/RiceVinegar"] = { dx = 0.12, dy = 0.12, dz = 0.04, fz = 270 }
mp["WorldItems/Rubberducky"] = { fz = 180 }
mp["WorldItems/SandBag"] = { dz = 0.04, qz = 3, flip = true }
mp["WorldItems/SaucePan"] = { qz = 3, fz = 180, flip = true }
mp["WorldItems/SaucePan_Copper"] = { qz = 3 }
mp["WorldItems/SaucePan_Copper_Rice"] = { dx = 0.22, dy = 0.4, dz = 0.045, s = 0.075 }
mp["WorldItems/SaucePan_Copper_Water"] = { dx = 0.22, dy = 0.4, dz = 0.045, s = 0.075 }
mp["WorldItems/SaucePan_FoodFluid"] = { fz = 180, flip = true }
mp["WorldItems/Sheet_Copper"] = { dz = 0.03 }
mp["WorldItems/Sheet_Copper_Small"] = { dz = 0.03 }
mp["WorldItems/SleepingTablets"] = { dx = 0.115, dy = 0.165, dz = 0.0135, qz = 5, fz = 90, s = 0.52 }

mp["WorldItems/SpiffoPlushie"] = { fz = 180 }
mp["WorldItems/Sponge"] = { qz = 6, flip = true }
mp["WorldItems/Suspension"] = { dx = 0.28, dy = 0.44, my = -0.05, flip = true, s = 0.4 }
mp["WorldItems/Tarp"] = { qz = 5 }
mp["WorldItems/TeddyBear_Crafted"] = { fz = 180 }
mp["WorldItems/TeddyBear_Crafted2"] = { fz = 180 }
mp["WorldItems/ToiletPaper"] = { qz = 3 }
mp["WorldItems/TomatoPaste"] = { dx = 0.1, dy = 0.24, dz = 0.02, qz = 3, s = 0.4 }
mp["WorldItems/Toothpaste"] = { dx = 0.1, qz = 3, s = 0.6 }
mp["WorldItems/Umbrella_Open"] = { dx = 0.13, dy = 0.7, dz = 0.16, mz = 0.016, fz = -90 }
mp["WorldItems/WeldingRods"] = { fz = -90 }
mp["WorldItems/WineBox"] = { dx = 0.15, qz = 2 }
mp["WorldItems/WoodenMold_AnvilJeweller_Cast"] = { dx = 0.325, dy = 0.5, dz = 0.075, qz = 3, s = 0.1 }
mp["WorldItems/WoodenMold_CeramicCast_AnvilBlock"] = { dx = 0.26, dy = 0.36, dz = 0.075, qz = 3, s = 0.13 }
mp["WorldItems/WoodenMold_IngotCast"] = { qz = 4 }
mp["WorldItems/WorldItem-SubstitutionDoll"] = { fz = 180 }
mp["WorldItems/WorldItem_FlamingoPlushie"] = { fz = 180 }
mp["WorldItems/WorldItem_SpiffoSanta"] = { fz = 180 }

mp["WorldItems/Billet_Metal"] = { qz = 8 }
mp["WorldItems/Cast_Ingot_Metal"] = { qz = 4 }
mp["WorldItems/Chunk_Metal"] = { qz = 8 }
mp["WorldItems/Ingot_Holed"] = { qz = 8 }
mp["WorldItems/MetalBar_Quarter"] = { qz = 8 }
mp["WorldItems/MetalBar_Tenth"] = { qz = 8 }
mp["WorldItems/MetalSheet"] = { flipZ = true, qz = 20, dz = 0.007, mz = 0.001 }
mp["WorldItems/Rod_Metal_Quarter"] = { flipZ = true, qz = 8 }
mp["WorldItems/Rod_Metal_Slug"] = { qz = 8 }
mp["WorldItems/Sheet_Copper"] = { flipZ = true, qz = 20, dz = 0.006, mz = 0.001, dx = 0.65 }
mp["WorldItems/Sheet_Copper_Small"] = { flipZ = true, qz = 20, dz = 0.005, mz = 0.001 }
mp["WorldItems/SmallSheetMetal"] = { qz = 20, dz = 0.005, mz = 0.001 }

mp["Newspaper"] = { flipY = true }
mp["WorldItems/CircularSawBlade"] = { qz = 20, dz = 0.005 }
mp["WorldItems/CircularSawBlade_Half"] = { qz = 20, dz = 0.005 }
mp["WorldItems/Newspaper"] = { flipY = true }
mp["WorldItems/Tarp_Segment"] = { qz = 10 }
mp["WorldItems/Whetstone_Crude"] = { qz = 6 }
mp["WorldItems/Whetstone_Modern"] = { qz = 6 }

----
-- mods
----

-- VFX
mp["WorldItems/VFX_BeerBottle_SM"] = { dz = 0.1 }
mp["WorldItems/VFX_BoxRamen"] = { dy = 0.16 }
mp["WorldItems/VFX_CandyBox"] = { qz = 3 }
mp["WorldItems/VFX_CanOpen"] = { dx = 0.1, dy = 0.1, dz = 0.05, fz = 270, s = 0.8 }
mp["WorldItems/VFX_Carton"] = { qz = 3, fz = 180 }
mp["WorldItems/VFX_CheeseKitBox"] = { qz = 2, fz = -90 }
mp["WorldItems/VFX_CheeseWheel"] = { dx = 0.333, dy = 0.333, dz = 0.08, qz = 2 }
mp["WorldItems/VFX_Container_FoodStorageContainer"] = { qz = 4 }
mp["WorldItems/VFX_FoodStorageContainer"] = { qz = 4 }
mp["WorldItems/VFX_Focaccia"] = { qz = 10 }
mp["WorldItems/VFX_FunDip"] = { fx = 180, flipX = true }
mp["WorldItems/VFX_GlassBottle"] = { dx = 0.1, dy = 0.1, dz = 0.1 }
mp["WorldItems/VFX_GranolaBarBox"] = { my = 0.03, qz = 2, fz = -90, flipX = true }
mp["WorldItems/VFX_IcedTeaBottle"] = { dx = 0.1, dy = 0.1, dz = 0.1 }
mp["WorldItems/VFX_Jar"] = { qz = 3, fz = 45 }
mp["WorldItems/VFX_JarFoodOpen"] = { dx = 0.12, dy = 0.12, dz = 0.06, fz = 45, s = 0.4 }
mp["WorldItems/VFX_JarOpen"] = { fz = 45 }
mp["WorldItems/VFX_JelloBox"] = { qz = 3, fz = -90, flipX = true }
mp["WorldItems/VFX_LemonBottle"] = { dx = 0.1, dy = 0.1, dz = 0.1 }
mp["WorldItems/VFX_MetalFoodStorageContainer"] = { qz = 5 }
mp["WorldItems/VFX_Packaging_Bag"] = { dz = 0.013, qz = 12, s = 0.8 }
mp["WorldItems/VFX_PotForgedFull"] = { dz = 0.1 }
mp["WorldItems/VFX_PotFull"] = { dx = 0.4 }
mp["WorldItems/VFX_Pouch"] = { dy = 0.07, fz = -90, flipX = true }
mp["WorldItems/VFX_ProteinPowder"] = { dz = 0.12, qz = 2, fz = 45, s = 0.5 }
mp["WorldItems/VFX_RectangleBox"] = { qz = 3 }
mp["WorldItems/VFX_Sandwich"] = { dx = 0.13, qz = 4, fz = -12 }
mp["WorldItems/VFX_SliceBread"] = { dx = 0.127, dz = 0.003, qz = 10, fz = -10, s = 0.3 }
mp["WorldItems/VFX_SliceFocaccia"] = { qz = 5, flipZ = true }
mp["WorldItems/VFX_SandwichFocaccia"] = { qz = 5, dz = 0.008, flipZ = true }
mp["WorldItems/VFX_SM_BreadSlices"] = { dx = 0.038, dy = 0.055, dz = 0.002, qz = 10, fz = -10, s = 0.3 }
mp["WorldItems/VFX_SM_FoodStorageContainer"] = { dx = 0.32, dy = 0.32, dz = 0.06, qz = 4 }
mp["WorldItems/VFX_SM_MetalFoodStorageContainer"] = { dx = 0.25, dy = 0.35, dz = 0.046, qz = 5, s = 1.2 }
mp["WorldItems/VFX_SmallJar"] = { qz = 3, fz = 45 }
mp["WorldItems/VFX_SnackBox"] = { qz = 3, fz = -90, flipX = true }
mp["WorldItems/VFX_StarterBox"] = { fz = -90, flipX = true }
mp["WorldItems/VFX_TeaBox"] = { qz = 4 }

-- Sapph
mp["Worlditems/AlcoholBottle"] = { fz = -90 }
mp["Worlditems/Bigcanmodel"] = { qz = 3, fz = 45 }
mp["Worlditems/Box_CannedFood"] = { dx = 0.6, dy = 0.5, s = 0.0045 }
mp["Worlditems/Box_CannedFood_Closed"] = { qz = 4 }
mp["Worlditems/BreadSliceToast"] = { dy = 0.27, dz = 0.01, qz = 6, fz = -10, s = 0.0035 }
mp["WorldItems/CookingPot_Liquid"] = { dz = 0.1 }
mp["Worlditems/DevJarFood"] = { qz = 3, fz = 45 }
mp["Worlditems/EmptyBottle"] = { dz = 0.04, fz = -90 }
mp["Worlditems/GenericCan"] = { qz = 3, fz = 45 }
mp["Worlditems/WhippedCan_Ground"] = { dx = 0.12, dz = 0.04, fz = -90 }

-- Authentic Z
mp["WorldItems/WorldItem_AZ_AquaBottle"] = { fz = -90 }
mp["WorldItems/WorldItem_AZ_GymBottle"] = { dz = 0.04, fz = -90 }
mp["WorldItems/WorldItem_AuthenticPillBottle"] = { dy = 0.08, dz = 0.056, fz = 153, s = 1.25 }
mp["WorldItems/WorldItem_GroguAZ"] = { flipZ = true }
mp["WorldItems/WorldItem_PlushieOtisPugAZ"] = { flipZ = true }
mp["WorldItems/WorldItem_SpiffoBackpack"] = { dx = 0.33, dy = 0.32, dz = 0.18, my = 0.18, mz = 0, fz = 180 }

-- Fool's new containers
mp["WorldItems/NCammocan30_ground"] = { dy = 0.28 }
mp["WorldItems/NCammocan50_ground"] = { flip = true }
mp["WorldItems/NCbeveragejugclosed_ground"] = { dz = 0.18 }
mp["WorldItems/NCbeveragejugopen_ground"] = { dx = 0.45, dy = 0.45, dz = 0.18, mz = 0.14 }
mp["WorldItems/NCbeveragejugopenfull_ground"] = { dx = 0.45, dy = 0.45, dz = 0.18, mz = 0.14 }
mp["WorldItems/NCcanteen"] = { dx = 0.12, dy = 0.05, dz = 0.05, fz = -90 }
mp["WorldItems/NCcardboard_large"] = { dz = 0.2, s = 0.9 }
mp["WorldItems/NCcardboard_medium"] = { qz = 3, flip = true }
mp["WorldItems/NCcardboard_small"] = { qz = 4 }
mp["WorldItems/NCdishtub_01"] = { dx = 0.35, dy = 0.43, dz = 0.1, qz = 3, s = 0.7 }
mp["WorldItems/NCdishtub_02"] = { dx = 0.35, dy = 0.43, dz = 0.1, qz = 3, s = 0.7 }
mp["WorldItems/NCdishtub_03"] = { dx = 0.35, dy = 0.43, dz = 0.1, qz = 3, s = 0.7 }
mp["WorldItems/NCdishtub_ground"] = { dx = 0.35, dy = 0.43, dz = 0.1, qz = 3, s = 0.7 }
mp["WorldItems/NCdishtubfull_ground"] = { dz = 0.1 }
mp["WorldItems/NCmilkcrate_ground"] = { qz = 2, flip = true }
mp["WorldItems/NCmilkcratelong_ground"] = { qz = 2, flip = true }
mp["WorldItems/NCpizzabox_ground"] = { qz = 5 }
mp["WorldItems/NCplastictote_large"] = { dy = 0.6, qz = 2, flip = true, s = 0.7 }
mp["WorldItems/NCplastictote_medium"] = { dz = 0.16, qz = 2, flip = true, s = 0.7 }
mp["WorldItems/NCplastictote_small"] = { qz = 2, flip = true }
mp["WorldItems/NCshoppingbasket_ground"] = { dx = 0.35, dy = 0.43, dz = 0.1, qz = 3 }
mp["WorldItems/NCtackleboxlarge_ground"] = { dx = 0.35, dy = 0.43, dz = 0.1, qz = 3 }
mp["WorldItems/NCwaterjug_ground"] = { dy = 0.24, dz = 0.36, flip = true }
mp["WorldItems/NCcomponentkit_ground"] = { qz = 3, mz = 0.02 }
mp["WorldItems/NCcdbinder_ground"] = { qz = 3, mz = 0.02 }
mp["WorldItems/NCcdcase_ground"] = { qz = 3 }
mp["WorldItems/NCroughbox_ground"] = { qz = 2 }
mp["WorldItems/NCshoebox_ground"] = { qz = 3, flip = true }

-- Pomp's items
mp["WorldItems/BittersBar"] = { qz = 3 }
mp["WorldItems/BittersBarEmpty"] = { qz = 3 }
mp["WorldItems/BittersBarHand"] = { qz = 3 }
mp["WorldItems/Dabs"] = { qz = 5 }
mp["WorldItems/DabsEmpty"] = { qz = 5 }
mp["WorldItems/DabsHand"] = { qz = 5 }
mp["WorldItems/Food/PICan128"] = { qz = 3, dz = 0.055 }
mp["WorldItems/Food/PICheddar"] = { qz = 6 }
mp["WorldItems/Food/PICheddarHand"] = { qz = 6 }
mp["WorldItems/Food/PICheesyPoofsSide"] = { qz = 2 }
mp["WorldItems/Food/PIDonutBag"] = { qz = 5 }
mp["WorldItems/Food/PIDonutBagEmpty"] = { qz = 5 }
mp["WorldItems/Food/PIFishSnackems"] = { dz = 0.009, flipZ = true, qz = 5, fz = 180 }
mp["WorldItems/Food/PIFishSnackemsEmpty"] = { dz = 0.009, flipZ = true, qz = 5, fz = 180 }
mp["WorldItems/Food/PIFreezePop"] = { dx = 0.05, qz = 4 }
mp["WorldItems/Food/PIFreezePopHand"] = { dx = 0.05, dy = 0.25, dz = 0.0064, qz = 4, fz = 90 }
mp["WorldItems/Food/PIHoneyBun"] = { flipZ = true, qz = 5, fz = 180 }
mp["WorldItems/Food/PIHotSauce"] = { dx = 0.1, dy = 0.1, dz = 0.04, fz = -90 }
mp["WorldItems/Food/PIHotSauceHand"] = { dx = 0.1, dy = 0.1, dz = 0.04, fz = 270 }
mp["WorldItems/Food/PINormalCan"] = { qz = 3 } --
mp["WorldItems/Food/PIPizza"] = { qz = 5 }
mp["WorldItems/Food/PIPizzaBox"] = { qz = 5 }
mp["WorldItems/Food/PIPizzaBoxEmpty"] = { qz = 5 }
mp["WorldItems/Food/PIPizzaFoldedHand"] = { qz = 5 }
mp["WorldItems/Food/PIPizzaSlice"] = { qz = 5 }
mp["WorldItems/Food/PIPizzaSliceHand"] = { qz = 5 }
mp["WorldItems/Food/PIPompsBig"] = { qz = 4 }
mp["WorldItems/Food/PIPopTart"] = { qz = 5 }
mp["WorldItems/Food/PIPopTartHand"] = { qz = 5 }
mp["WorldItems/Food/PIRMOysters"] = { flipZ = true, qz = 5 }
mp["WorldItems/Food/PIRingPop"] = { qz = 5 }
mp["WorldItems/Food/PIRingPopHand"] = { qz = 5 }
mp["WorldItems/Food/PIRitz"] = { qz = 6 }
mp["WorldItems/Food/PIRitzHand"] = { qz = 6 }
mp["WorldItems/Food/PISnackableHamCracker"] = { qz = 6 }
mp["WorldItems/Food/PISnackableHamCrackerHand"] = { qz = 6 }
mp["WorldItems/Food/PISnackableNachoHand"] = { qz = 6 }
mp["WorldItems/Food/PISnackableSmol"] = "pompSnackable"
mp["WorldItems/Food/PISnackableSmol"] = { qz = 6 }
mp["WorldItems/Food/PISnackableSmolEmpty"] = { qz = 6 }
mp["WorldItems/Food/PIWingSauceBottleEmpty"] = { dx = 0.17, dy = 0.08, dz = 0.09, s = 0.023 }
mp["WorldItems/Food/SnackablePizza"] = { qz = 6 }
mp["WorldItems/Food/SnackablePizzaHand"] = { qz = 6 }
mp["WorldItems/GummyWormsEmpty"] = { qz = 3 }
mp["WorldItems/Jiang"] = { qz = 3 }
mp["WorldItems/JiangEmpty"] = { qz = 3 }
mp["WorldItems/JiangHand"] = { qz = 3 }
mp["WorldItems/Misc/PIMagazine"] = { flipX = true, fx = 180, fy = 180, flipY = true, dx = 0.016 }
mp["WorldItems/Misc/PIRambleyRaccoonPlushie"] = { fz = 180 }
mp["WorldItems/PIGummyWorms"] = { qz = 3 }
mp["WorldItems/Pomps"] = { qz = 4 }
mp["WorldItems/SourGummies"] = { qz = 8 }
mp["WorldItems/SourGummiesEmpty"] = { qz = 8 }
mp["WorldItems/SourGummiesHand"] = { qz = 8 }
mp["WorldItems/StallionMilkOpen_Ground"] = { fz = 190 }
mp["WorldItems/StallionMilk_Ground"] = { qz = 3, fz = 190 } -- uhhh... ok
mp["WorldItems/WildPegasus_Ground"] = { fz = -90 }

mp["WorldItems/BittersBar"] = { qz = 3 }
mp["WorldItems/ChocolateCrossBox"] = { qz = 3 }
mp["WorldItems/Dabs"] = { qz = 3 }
mp["WorldItems/DinoNugBox"] = { qz = 3 }
mp["WorldItems/Food/FigBox"] = { qz = 3, flipZ = true, flipX = true, fx = 180 }
mp["WorldItems/Food/PIBarrelBox"] = { qz = 3 }
mp["WorldItems/Food/PICheeseStickDipPack"] = { qz = 3 }
mp["WorldItems/Food/PICheesyPoofs"] = { qz = 3 }
mp["WorldItems/Food/PIHoneyBunBox"] = { qz = 3 }
mp["WorldItems/Food/SnackablePizza"] = { qz = 3 }
mp["WorldItems/Misc/PIMysteryBox"] = { qz = 3 }
mp["WorldItems/MoxxBox"] = { qz = 3 }
mp["WorldItems/POreoPackage"] = { qz = 3 }

-- bolts and arrows
mp["Crossbow|Bolts_carbon_pack"] = { qz = 5, dz = 0.01 }
mp["Crossbow|Bolts_metal_pack"] = { qz = 5, dz = 0.01 }
mp["Crossbow|Bolts_wood_pack"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_floor"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_fly"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_pack"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_carbon_part"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_floor"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_fly"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_pack"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_metal_part"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_floor"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_fly"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_pack"] = { qz = 5, dz = 0.01 }
mp["weapons/firearms/Ranged_Weaponry_Misc|Arrow_wood_part"] = { qz = 5, dz = 0.01 }

--- ggs
mp["Ammo/792x57Box"] = { qz = 5 }
mp["Ammo/Bullets308Box"] = { qz = 5 }
mp["Ammo/Bullets32Box"] = { qz = 5 }
mp["Ammo/Bullets357Box"] = { qz = 5 }
mp["Ammo/Bullets38Box"] = { qz = 5 }
mp["Ammo/Bullets44Box"] = { qz = 5 }
mp["Ammo/Bullets45Box"] = { qz = 5 }
mp["Ammo/Bullets50Box"] = { dy = 0.15, dx = 0.2, qz = 2, dz = 0.112 }
mp["Ammo/Bullets50MagnumBox"] = { qz = 5 }
mp["Ammo/Bullets545x39Box"] = { qz = 5 }
mp["Ammo/Bullets556Box"] = { qz = 5 }
mp["Ammo/Bullets762x39Box"] = { qz = 2, fz = 12, dx = 0.18, dy = 0.18 }
mp["Ammo/Bullets762x54rBox"] = { qz = 5 }
mp["Ammo/Bullets9mmBox"] = { qz = 5 }
mp["Ammo/Bullets9x39Box"] = { qz = 5, fz = 12 }
mp["Ammo/GrenadeAmmoBox"] = { qz = 5 }
mp["Ammo/ShotgunShellsBox"] = { fz = 12 }
mp["Ammo/WorldItems|308Box150"] = { qz = 5 }
mp["Ammo/WorldItems|50Box100"] = { qz = 5, dy = 0.2 }
mp["Ammo/WorldItems|556Box150"] = { qz = 5 }
mp["Ammo/WorldItems|762x54rBox150"] = { qz = 5 }
mp["Ammo/WorldItems|792x57Box75"] = { qz = 5 }
mp["Ammo/WorldItems|792x57Box97"] = { qz = 5 }
mp["Ammo/ammoBox"] = { qz = 5 }
mp["Mags/MAGS|308Box150"] = { qz = 5 }
mp["Mags/MAGS|50Box100"] = { qz = 5 }
mp["Mags/MAGS|556Box150"] = { qz = 5 }
mp["Mags/MAGS|762x54rBox150"] = { qz = 5 }
mp["Mags/MAGS|792x57Box75"] = { qz = 5 }
mp["Mags/MAGS|792x57Box97"] = { qz = 5 }
mp["WorldItems/HandGunAmmoBox"] = { qz = 5 }

-- firearms
mp["ammo/boxes/Ammobox_Shotgun"] = { dx = 0.134, dy = 0.063, dz = 0.056, mx = 0.003, my = 0.008, qz = 3, zmin = 0.003 }

-- bicycle
mp["Bicycle_RedStreet"] = { dx = 0.401, dy = 1, dz = 0.38, mx = 0.385, my = 0.537, mz = 0.001 }
mp["Bicycle_Frame2"] = { dx = 0.401, dy = 1, dz = 0.38, mx = 0.385, my = 0.537, mz = 0.001 }
mp["Bicycle_World"] = { dx = 0.401, dy = 1, dz = 0.38, mx = 0.385, my = 0.537, mz = 0.001 }
