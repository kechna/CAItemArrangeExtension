IA = IA or {}

---@type table<string, string>
IA.modelProfiles = {}

---@type boolean
IA.modelProfilesApplied = false

local p = "CAItemArrangeExtension"

---@param item Item
---@return string | nil
local function getWorldModel(item)
  local model = item:getWorldStaticModel()

  if not model or model == "" then
    model = item:getStaticModel()
  end

  if not model or model == "" then
    return nil
  end

  if model:sub(1, 5) == "Base." then
    model = model:sub(6)
  end

  return model
end

---@return table<table, string>
local function getProfileNames()
  local names = {}

  for name, profile in pairs(IA.arrangableProfile) do
    names[profile] = name
  end

  return names
end

--- get model -> profile mappings from items already registered with IA
---@param sm ScriptManager
local function learnModelProfiles(sm)
  local profileNames = getProfileNames()
  local modelProfiles = IA.modelProfiles

  local debug = isDebugEnabled()
  local fileWriter = debug and getFileWriter(p .. "_models.txt", true, false) or nil

  for fullType, profile in pairs(IA.arrangables) do
    local name = profileNames[profile]
    local item = name and sm:getItem(fullType)
    local model = item and getWorldModel(item)

    if model then
      if not modelProfiles[model] then
        modelProfiles[model] = name

        if debug and fileWriter then
          fileWriter:writeln(string.format("%-30s -> %s", model, name))
        end
      end
    end
  end

  if debug and fileWriter then
    fileWriter:close()
  end
end

function IA.applyModelProfiles()
  if IA.modelProfilesApplied then
    return
  end

  if type(IA.arrangables) ~= "table" or type(IA.arrangableProfile) ~= "table" then
    print(string.format("%s: Item Arrange is not loaded, skipping.", p))
    return
  end

  IA.modelProfilesApplied = true

  local sm = getScriptManager()
  local debug = isDebugEnabled()
  local fileWriter = debug and getFileWriter(p .. "_added.txt", true, false) or nil

  learnModelProfiles(sm)

  local arrangables = IA.arrangables
  local profiles = IA.arrangableProfile
  local modelProfiles = IA.modelProfiles
  local items = sm:getAllItems()
  local added = 0

  for i = 0, items:size() - 1 do
    local item = items:get(i)
    local fullType = item:getFullName()

    if not arrangables[fullType] then
      local model = getWorldModel(item)
      local profile = model and modelProfiles[model] and profiles[modelProfiles[model]]

      if profile then
        arrangables[fullType] = profile
        added = added + 1

        if debug and fileWriter then
          local modId = item:getModID()
          fileWriter:writeln(string.format("%-30s | %-40s -> %s", modId, fullType, tostring(modelProfiles[model])))
        end
      end
    end
  end

  if debug and fileWriter then
    fileWriter:close()
  end

  print(string.format("%s: Made %d extra items arrangeable.", p, added))
end

Events.OnGameStart.Add(IA.applyModelProfiles)
Events.OnServerStarted.Add(IA.applyModelProfiles)
