require("PZAPI/ModOptions")

local IA = IA or nil

if not IA then return end

local PZAPI = PZAPI
local Events = Events

local MOD_OPTIONS_ID = "CAItemArrangeExtension"
local FACING_OPTION = "facingMode"
local MIXED_OPTION = "mixedStacks"
local TEXT_PREFIX = "IGUI_CAIAE_Options_"

-- new modes go at the end, the option is saved as an index
local FACING_MODES = { "walls", "towards", "away", "view", "look" }

local function applyOptions(options)
  local option = options:getOption(FACING_OPTION)

  IA.FacingMode = FACING_MODES[option and option:getValue() or 1] or "walls"

  local mixed = options:getOption(MIXED_OPTION)
  IA.MixedStacks = mixed and mixed:getValue() == true or false
end

local function initialize()
  local api = PZAPI and PZAPI.ModOptions

  if not api then return end

  local options = api:getOptions(MOD_OPTIONS_ID)

  if not options then
    options = api:create(MOD_OPTIONS_ID, TEXT_PREFIX .. "Title")

    local combo = options:addComboBox(FACING_OPTION, TEXT_PREFIX .. "FacingMode", TEXT_PREFIX .. "FacingMode_tooltip")
    for i = 1, #FACING_MODES do
      combo:addItem(TEXT_PREFIX .. "FacingMode_" .. FACING_MODES[i], i == 1)
    end

    options:addTickBox(MIXED_OPTION, TEXT_PREFIX .. "MixedStacks", false, TEXT_PREFIX .. "MixedStacks_tooltip")

    -- vanilla only reads ModOptions.ini once the options screen is opened
    api:load()
  end

  -- called by the options screen after the new values are stored
  options.apply = applyOptions
  applyOptions(options)
end

Events.OnGameBoot.Add(initialize)

-- a hot reload comes after OnGameBoot
if IA.FacingMode or getPlayer() then
  initialize()
end
