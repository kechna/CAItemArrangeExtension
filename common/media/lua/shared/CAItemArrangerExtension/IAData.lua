IA = IA or {}

--- mesh name -> IA.arrangableProfile key
---@type table<string, string>
IA.meshProfiles = {}

---@type boolean
IA.meshProfilesApplied = false

local p = "CAItemArrangeExtension"

---@type table<string, string | false>
local meshCache = {}

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

  return model
end

--- The mesh of the item's world model. different model scripts often point at the same mesh, so this matches more
--- items than the model name would.
---@param sm   ScriptManager
---@param item Item
---@return string | nil
local function getWorldMesh(sm, item)
  local model = getWorldModel(item)

  if not model then
    return nil
  end

  local mesh = meshCache[model]

  if mesh == nil then
    local modelScript = sm:getModelScript(model)
    mesh = modelScript and modelScript:getMeshName() or false

    if mesh == "" then
      mesh = false
    end

    meshCache[model] = mesh
  end

  return mesh or nil
end

---@return table<table, string>
local function getProfileNames()
  local names = {}

  for name, profile in pairs(IA.arrangableProfile) do
    names[profile] = name
  end

  return names
end

--- get mesh -> profile mappings from items already registered with IA
---@param sm ScriptManager
local function learnMeshProfiles(sm)
  local profileNames = getProfileNames()
  local meshProfiles = IA.meshProfiles

  local fileWriter = isDebugEnabled() and getFileWriter(p .. "_meshes.txt", true, false) or nil

  for fullType, profile in pairs(IA.arrangables) do
    local name = profileNames[profile]
    local item = name and sm:getItem(fullType)
    local mesh = item and getWorldMesh(sm, item)

    if mesh and not meshProfiles[mesh] then
      meshProfiles[mesh] = name

      if fileWriter then
        fileWriter:writeln(string.format('IA.meshProfiles["%-50s = "%s"', mesh .. '"]', name))
      end
    end
  end

  if fileWriter then
    fileWriter:close()
  end
end

function IA.applyMeshProfiles()
  if IA.meshProfilesApplied then
    return
  end

  if type(IA.arrangables) ~= "table" or type(IA.arrangableProfile) ~= "table" then
    print(string.format("%s: Item Arrange is not loaded, skipping.", p))
    return
  end

  IA.meshProfilesApplied = true

  local sm = getScriptManager()
  local fileWriter = isDebugEnabled() and getFileWriter(p .. "_added.txt", true, false) or nil

  learnMeshProfiles(sm)

  local arrangables = IA.arrangables
  local profiles = IA.arrangableProfile
  local meshProfiles = IA.meshProfiles
  local items = sm:getAllItems()

  local added = 0
  local addedByMod = {}

  for i = 0, items:size() - 1 do
    local item = items:get(i)
    local fullType = item:getFullName()

    if not arrangables[fullType] then
      local mesh = getWorldMesh(sm, item)
      local profileName = mesh and meshProfiles[mesh]
      local profile = profileName and profiles[profileName]

      if profile then
        arrangables[fullType] = profile
        added = added + 1
        local modID = item:getModID()

        addedByMod[modID] = addedByMod[modID] and addedByMod[modID] + 1 or 1

        if fileWriter then
          fileWriter:writeln(
            string.format(
              'IA.arrangables["%-40s = IA.arrangableProfile.%-12s -- %s (%s)', fullType .. '"]', profileName, modID, mesh
            )
          )
        end
      end
    end
  end

  if fileWriter then
    fileWriter:close()
  end

  for modID, count in pairs(addedByMod) do
    print(string.format("%s: [%s] Made %d extra items arrangeable.", p, modID, count))
  end
end

Events.OnGameStart.Add(IA.applyMeshProfiles)
Events.OnServerStarted.Add(IA.applyMeshProfiles)
