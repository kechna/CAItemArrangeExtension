IA = IA or {}

--- mesh name -> IA.arrangableProfile key. a plain string applies the profile as-is at every scale, a table marks the
--- model scale the profile was measured at, so it is resized for other scales of the same mesh.
---@type table<string, string | { profile: string, scale: number }>
IA.meshProfiles = {}

IA.meshProfilesApplied = false

local p = "CAItemArrangeExtension"

---@class CAIAE_WorldMesh
---@field mesh string
---@field scale number

---@class CAIAE_ScaledProfileName
---@field name string
---@field scale number

---@type table<string, CAIAE_WorldMesh | false>
local meshCache = {}

local SCALE_EPSILON = 0.0001

---@type table<string, IAArrangableProfile>
local scaledProfiles = {}

---@param value number
---@param ratio number
---@return number
local function scaleDimension(value, ratio)
  return math.floor(value * ratio * 1000 + 0.5) / 1000
end

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

---@param line string
---@param char string
---@return number
local function countChar(line, char)
  local _, count = line:gsub(char, "")

  return count
end

---@param body  string
---@param scale number
---@return number
local function parseScale(body, scale)
  local undoCoreScale = false
  local attachmentDepth
  local attachmentOpened = false

  body = body:gsub("/%*.-%*/", "")

  for rawLine in (body .. "\n"):gmatch("([^\r\n]*)\r?\n") do
    local line = rawLine:lower()

    if not attachmentDepth and line:match("^%s*attachment[%s{]") then
      attachmentDepth = 0
      attachmentOpened = false
    end

    if attachmentDepth then
      local opens = countChar(line, "{")

      attachmentDepth = attachmentDepth + opens - countChar(line, "}")
      attachmentOpened = attachmentOpened or opens > 0

      if attachmentOpened and attachmentDepth <= 0 then
        attachmentDepth = nil
      end
    else
      for entry in line:gmatch("[^,{}]+") do
        local key, value = entry:match("^%s*(%w+)%s*=%s*(%S+)")

        if key == "scale" then
          scale = tonumber(value) or scale
        elseif key == "undocorescale" then
          undoCoreScale = value == "true"
        end
      end
    end
  end

  if undoCoreScale then
    scale = scale * 0.6666667
  end

  return scale
end

--- scale has no getter and reflection only works in debug mode, so it's parsed from the model's script text.
---@param modelScript ModelScript
---@return number
local function getModelScale(modelScript)
  local ok, scale = pcall(function ()
    local bodies = modelScript:getLoadedScriptBodies()
    local result = 1

    -- flat list of mod id, body, mod id, body, ...
    for i = 1, bodies:size() - 1, 2 do
      result = parseScale(bodies:get(i), result)
    end

    return result
  end)

  if not ok or not scale or scale <= 0 then
    return 1
  end

  return scale
end

--- The mesh of the item's world model and the scale the model script renders it at. different model scripts often
--- point at the same mesh, so this matches more items than the model name would.
---@param sm   ScriptManager
---@param item Item
---@return CAIAE_WorldMesh | nil
local function getWorldMesh(sm, item)
  local model = getWorldModel(item)

  if not model then
    return nil
  end

  local worldMesh = meshCache[model]

  if worldMesh == nil then
    local modelScript = sm:getModelScript(model)
    local mesh = modelScript and modelScript:getMeshName()

    if mesh and mesh ~= "" then
      worldMesh = { mesh = mesh, scale = getModelScale(modelScript) }
    else
      worldMesh = false
    end

    meshCache[model] = worldMesh
  end

  return worldMesh or nil
end

---@return table<table, string>
local function getProfileNames()
  local names = {}

  for name, profile in pairs(IA.arrangableProfile) do
    names[profile] = name
  end

  return names
end

---@param entries CAIAE_ScaledProfileName[]
---@param scale   number
---@return boolean
local function hasScale(entries, scale)
  for i = 1, #entries do
    if math.abs(entries[i].scale - scale) < SCALE_EPSILON then
      return true
    end
  end

  return false
end

--- get mesh -> profile mappings, per model scale, from items already registered with IA
---@param sm ScriptManager
---@return table<string, CAIAE_ScaledProfileName[]>
local function learnMeshProfiles(sm)
  local profileNames = getProfileNames()
  local learned = {}

  local fileWriter = isDebugEnabled() and getFileWriter(p .. "_meshes.txt", true, false) or nil

  for fullType, profile in pairs(IA.arrangables) do
    local name = profileNames[profile]
    local item = name and sm:getItem(fullType)
    local worldMesh = item and getWorldMesh(sm, item)

    if worldMesh then
      local entries = learned[worldMesh.mesh]

      if not entries then
        entries = {}
        learned[worldMesh.mesh] = entries
      end

      if not hasScale(entries, worldMesh.scale) then
        entries[#entries + 1] = { name = name, scale = worldMesh.scale }

        if fileWriter then
          fileWriter:writeln(
            string.format(
              'IA.meshProfiles["%-50s = { profile = "%s", scale = %s }',
              worldMesh.mesh .. '"]',
              name,
              tostring(worldMesh.scale)
            )
          )
        end
      end
    end
  end

  if fileWriter then
    fileWriter:close()
  end

  return learned
end

---@param name  string
---@param ratio number
---@return IAArrangableProfile | nil
local function getScaledProfile(name, ratio)
  local profile = IA.arrangableProfile[name]

  if not profile then
    return nil
  end

  local key = name .. "@" .. string.format("%.3f", ratio)
  local scaled = scaledProfiles[key]

  if not scaled then
    scaled = {
      dx = scaleDimension(profile.dx, ratio),
      dy = scaleDimension(profile.dy, ratio),
      dz = scaleDimension(profile.dz, ratio),
    }

    for k, v in pairs(profile) do
      if scaled[k] == nil then
        scaled[k] = v
      end
    end

    if profile.mz then
      scaled.mz = scaleDimension(profile.mz, ratio)
    end

    scaledProfiles[key] = scaled
  end

  return scaled
end

---@param learned   table<string, CAIAE_ScaledProfileName[]>
---@param worldMesh CAIAE_WorldMesh
---@return IAArrangableProfile?, string?, number?
local function resolveProfile(learned, worldMesh)
  local manual = IA.meshProfiles[worldMesh.mesh]

  if type(manual) == "string" then
    return IA.arrangableProfile[manual], manual, 1
  end

  local candidates = {}

  if type(manual) == "table" and manual.profile and manual.scale then
    candidates[1] = { name = manual.profile, scale = manual.scale }
  end

  local entries = learned[worldMesh.mesh]

  if entries then
    for i = 1, #entries do
      candidates[#candidates + 1] = entries[i]
    end
  end

  local best, bestDistance

  for i = 1, #candidates do
    local candidate = candidates[i]

    if IA.arrangableProfile[candidate.name] then
      local distance = math.abs(math.log(worldMesh.scale / candidate.scale))

      if not best or distance < bestDistance - SCALE_EPSILON then
        best = candidate
        bestDistance = distance
      end
    end
  end

  if not best then
    return nil, nil, nil
  end

  local ratio = worldMesh.scale / best.scale

  if math.abs(ratio - 1) < SCALE_EPSILON then
    return IA.arrangableProfile[best.name], best.name, 1
  end

  return getScaledProfile(best.name, ratio), best.name, ratio
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

  local learned = learnMeshProfiles(sm)

  local arrangables = IA.arrangables
  local items = sm:getAllItems()

  local added = 0
  local addedByMod = {}

  for i = 0, items:size() - 1 do
    local item = items:get(i)
    local fullType = item:getFullName()

    if not arrangables[fullType] then
      local worldMesh = getWorldMesh(sm, item)
      local profile, profileName, ratio

      if worldMesh then
        profile, profileName, ratio = resolveProfile(learned, worldMesh)
      end

      if profile then
        arrangables[fullType] = profile
        added = added + 1
        local modID = item:getModID()

        addedByMod[modID] = addedByMod[modID] and addedByMod[modID] + 1 or 1

        if fileWriter then
          local scaleNote = ratio ~= 1 and string.format(", x%.2f", ratio) or ""

          fileWriter:writeln(
            string.format(
              'IA.arrangables["%-40s = IA.arrangableProfile.%-12s -- %s (%s @%s%s)',
              fullType .. '"]',
              profileName,
              modID,
              worldMesh and worldMesh.mesh or "N/A",
              tostring(worldMesh and worldMesh.scale or "N/A"),
              scaleNote
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
