require("IAArrange")

--- @class IASurfaceProfile
--- @field zmin number
--- @field zmax number
--- @field xmin number
--- @field xmax number
--- @field ymin number
--- @field ymax number

--- @class IAArrangableProfile
--- @field dx number
--- @field dy number
--- @field dz number
--- @field mx number?
--- @field my number?
--- @field mz number?
--- @field qz number?
--- @field fx number?
--- @field fy number?
--- @field fz number?
--- @field lx number? real length along x when it's longer than dx, kept on the surface when placed
--- @field ly number? real length along y when it's longer than dy, kept on the surface when placed
--- @field center number[]? measured profiles: centre of the model's box relative to its origin (tiles, tiles, floors)

---@class CAIAE_MeshBase
---@field dx? number x distance
---@field dy? number y distance (top left to right)
---@field dz? number z distance (vertical)
---@field mz? number
---@field qz? number
---@field fx? number
---@field fy? number
---@field fz? number

---@class CAIAE_MeshProfile: CAIAE_MeshBase
---@field p   string arrangableProfile key
---@field s?  number model scale the profile was measured at

---@class CAIAE_MeshOverride: CAIAE_MeshBase
---@field flipX? boolean turn the item 90° around x (adds 90 to fx) and swap its dimensions to match
---@field flipY? boolean turn the item 90° around y (adds 90 to fy) and swap its dimensions to match
---@field flipZ? boolean turn the item 90° around z (adds 90 to fz) and swap its dimensions to match
---@field flip? boolean same as `flipZ`
---@field s? number model scale the entry's dimensions and offsets were measured at, scaled along for other scales

---@class ItemArrangeMod
---@field surfaceProfile table<string, table<integer, IASurfaceProfile>>
---@field surfaces table<string, table<integer, IASurfaceProfile>>
---@field arrangables table<string, IAArrangableProfile>
---@field arrangableProfile table<string, IAArrangableProfile>
---@field meshProfiles table<string, string | CAIAE_MeshProfile | CAIAE_MeshOverride>
---@field meshProfilesApplied boolean
---@field meshCache table<string, CAIAE_WorldMesh | false>
---@field meshProfilesAdded table<string, IAArrangableProfile>
---@field devRestackContextMenu? fun(playerNum: integer, context: ISContextMenu, worldObjects: IsoObject[], test: boolean)
---@field applyMeshProfiles fun(): void
IA = IA or {}

---@type table<string, string | CAIAE_MeshProfile>
IA.meshProfiles = IA.meshProfiles or {}

IA.meshProfilesApplied = false

local p = "CAItemArrangeExtension"

--- sizes and offsets measured from the models by src/generateMeshSizes.ts, for meshes no profile covers yet.
---@type table<string, { dx: number, dy: number, dz: number, oz?: number, cx?: number, cy?: number }>
local meshSizes = require("CAItemArrangeExtension/IAMeshSizes_Generated")

--- profile name used for items arranged by their measured mesh size.
local MEASURED = "measured"

--- profile name used for items arranged by a mesh entry's own dimensions.
local INLINE = "inline"

--- measured sizes outside this range are broken meshes or things that don't fit on a tile.
local MIN_MEASURED_SIZE = 0.001
local MAX_MEASURED_SIZE = 1

--- long items (sledgehammers, shovels) may be up to this long, their footprint is shortened to `MAX_FOOTPRINT`.
local MAX_MEASURED_LENGTH = 2.5

--- IA only places items whose footprint fits inside a surface, so longer ones overhang it, like IA's own long weapons.
local MAX_FOOTPRINT = 0.7

--- how much a measured bottom offset may exceed the item's height before it's distrusted, in floors.
local MAX_BOTTOM_OFFSET_SLACK = 0.05

--- measured items at least this many times longer along x than along y get rotated to lie along y.
local SKINNY_RATIO = 2

--- tiles per floor, IA measures dz in floors and dx/dy in tiles.
local FLOOR_HEIGHT = 2.449

---@class CAIAE_WorldMesh
---@field mesh        string
---@field modelScript ModelScript
---@field sizeKeys    string[] keys into the generated sizes, most specific first
---@field scale?      number parsed on first use, see getMeshScale

---@class CAIAE_ScaledProfileName
---@field name  string
---@field scale number

---@class CAIAE_LearnedProfile
---@field name      string
---@field worldMesh CAIAE_WorldMesh

---@type table<string, CAIAE_WorldMesh | false>
IA.meshCache = {}

local SCALE_EPSILON = 0.0001

---@type table<string, IAArrangableProfile>
local scaledProfiles = {}

--- size key -> profile built from the measured model size.
---@type table<string, IAArrangableProfile | false>
local measuredProfiles = {}

--- mesh@profile@ratio -> profile with the mesh's overrides applied.
---@type table<string, IAArrangableProfile>
local overriddenProfiles = {}

--- keys of a `CAIAE_MeshProfile` that aren't profile fields.
local MESH_PROFILE_KEYS = { p = true, s = true }

--- mesh -> candidates with their scales, built once per mesh.
---@type table<string, CAIAE_ScaledProfileName[]>
local candidateCache = {}

---@param value number
---@param ratio number
---@return number
local function scaleDimension(value, ratio)
  return math.floor(value * ratio * 1000 + 0.5) / 1000
end

---@param source Item | InventoryItem
---@return string | nil, boolean | nil model, and whether it's the world static model
local function getStaticModel(source)
  local model = source:getWorldStaticModel()

  if model and model ~= "" then
    return model, true
  end

  model = source:getStaticModel()

  if not model or model == "" then
    return nil, nil
  end

  return model, false
end

--- some items (e.g. weapons) only resolve their model on the instance, so fall back to a temporary one.
---@param item Item
---@return string | nil, boolean | nil model, and whether it's the world static model
local function getWorldModel(item)
  local model, isWorldStatic = getStaticModel(item)

  if model then
    return model, isWorldStatic
  end

  -- the game runs OnCreate in its own protected call and logs its errors, so pcall can't catch them. the instance
  -- reads OnCreate from the script, so it's switched off while the temporary instance is made.
  local luaCreate = item:getLuaCreate()

  if luaCreate then
    item:setLuaCreate(nil)
  end

  local ok, result, resultIsWorldStatic = pcall(function ()
    local instance = instanceItem(item)

    if not instance then
      return nil, nil
    end

    return getStaticModel(instance)
  end)

  if luaCreate then
    item:setLuaCreate(luaCreate)
  end

  -- the instance was never added to a container, so dropping the reference is enough for it to be collected
  if not ok then
    return nil, nil
  end

  return result, resultIsWorldStatic
end

--- keys of the model in the generated sizes: the game lays models down when it draws them through the weapon path
--- (no world static model), the generator keeps those apart.
---@param model         string
---@param isWorldStatic boolean
---@return string[]
local function getSizeKeys(model, isWorldStatic)
  local key = (model:match("[^.]+$") or model):lower()

  if isWorldStatic then
    return { key }
  end

  return { key .. "@weapon", key }
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
  body = body:lower()

  -- also covers undocorescale
  if not body:find("scale", 1, true) then
    return scale
  end

  local undoCoreScale = false
  local attachmentDepth
  local attachmentOpened = false

  body = body:gsub("/%*.-%*/", "")

  for line in (body .. "\n"):gmatch("([^\r\n]*)\r?\n") do

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
    local result = 1.0

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
  local model, isWorldStatic = getWorldModel(item)

  if not model then
    return nil
  end

  local cacheKey = isWorldStatic and model or model .. "@weapon"
  local worldMesh = IA.meshCache[cacheKey]

  if worldMesh == nil then
    local modelScript = sm:getModelScript(model)
    local mesh = modelScript and modelScript:getMeshName()

    if mesh and mesh ~= "" then
      worldMesh = { mesh = mesh, modelScript = modelScript, sizeKeys = getSizeKeys(model, isWorldStatic == true) }
    else
      worldMesh = false
    end

    IA.meshCache[cacheKey] = worldMesh
  end

  return worldMesh or nil
end

--- parsing the script text is slow, so this only runs for meshes that have a sized profile.
---@param worldMesh CAIAE_WorldMesh
---@return number
local function getMeshScale(worldMesh)
  if not worldMesh.scale then
    worldMesh.scale = getModelScale(worldMesh.modelScript)
  end

  return worldMesh.scale
end

---@return table<table, string>
local function getProfileNames()
  local names = {}
  local sorted = {}

  for name in pairs(IA.arrangableProfile) do
    sorted[#sorted + 1] = name
  end

  -- profiles shared under several names get the first one alphabetically, not whichever comes up last
  table.sort(sorted)

  for i = #sorted, 1, -1 do
    names[IA.arrangableProfile[sorted[i]]] = sorted[i]
  end

  return names
end

--- get mesh -> profile mappings from items already registered with IA, one per model. scales are resolved later,
--- only for the meshes that are actually needed.
---@param sm ScriptManager
---@return table<string, CAIAE_LearnedProfile[]>
local function learnMeshProfiles(sm)
  local profileNames = getProfileNames()
  local learned = {}
  local seen = {}

  -- no scales here, writing them would mean parsing every model's script
  local fileWriter = isDebugEnabled() and getFileWriter(p .. "_meshes.txt", true, false) or nil

  -- in a fixed order, the first item of each model decides what's learned for it
  local fullTypes = {}

  for fullType in pairs(IA.arrangables) do
    fullTypes[#fullTypes + 1] = fullType
  end

  table.sort(fullTypes)

  for i = 1, #fullTypes do
    local fullType = fullTypes[i]
    local name = profileNames[IA.arrangables[fullType]]
    local item = name and sm:getItem(fullType)
    local worldMesh = item and getWorldMesh(sm, item)

    if worldMesh and not seen[worldMesh] then
      seen[worldMesh] = true

      local entries = learned[worldMesh.mesh]

      if not entries then
        entries = {}
        learned[worldMesh.mesh] = entries
      end

      entries[#entries + 1] = { name = name, worldMesh = worldMesh }

      if fileWriter then
        fileWriter:writeln(
          string.format('IA.meshProfiles["%-50s = "%s" -- %s', worldMesh.mesh .. '"]', name, fullType)
        )
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

    if profile.mz then scaled.mz = scaleDimension(profile.mz, ratio) end
    if profile.mx then scaled.mx = scaleDimension(profile.mx, ratio) end
    if profile.my then scaled.my = scaleDimension(profile.my, ratio) end

    scaledProfiles[key] = scaled
  end

  return scaled
end

---@param value number
---@param max?  number defaults to MAX_MEASURED_SIZE
---@return boolean
local function isMeasurable(value, max)
  return value >= MIN_MEASURED_SIZE and value <= (max or MAX_MEASURED_SIZE)
end

--- cos and sin of an angle in degrees, exact for quarter turns.
---@param degrees number
---@return number, number
local function cosSin(degrees)
  -- wrapped by hand: kahlua's `%` keeps the sign of negative angles, which would miss the lookup
  local turns = degrees / 90

  if turns == math.floor(turns) then
    turns = turns - math.floor(turns / 4) * 4

    return ({ 1, 0, -1, 0 })[turns + 1], ({ 0, 1, 0, -1 })[turns + 1]
  end

  local radians = math.rad(degrees)

  return math.cos(radians), math.sin(radians)
end

--- turns a point around one axis of the game's model space (y up), counter-clockwise like the renderer does.
---@param v       number[] x, y, z
---@param axis    integer 1 = x, 2 = y, 3 = z
---@param degrees number
---@return number[]
local function rotatePoint(v, axis, degrees)
  local cos, sin = cosSin(degrees)
  local a, b = axis % 3 + 1, (axis + 1) % 3 + 1
  local result = { v[1], v[2], v[3] }

  result[a] = v[a] * cos - v[b] * sin
  result[b] = v[a] * sin + v[b] * cos

  return result
end

--- where a point of the item ends up once IA turns it by fx/fy/fz (`RotX(fx) * RotY(fz) * RotZ(fy)`), or back again.
--- points are in IA's axes (x and y in tiles, z in floors), which are the model's x, -z and y.
---@param point   number[] x, y, z
---@param angles  number[] fx, fy, fz
---@param inverse boolean
---@return number[]
local function turnPoint(point, angles, inverse)
  local v = { point[1], point[3] * FLOOR_HEIGHT, -point[2] }

  if inverse then
    v = rotatePoint(rotatePoint(rotatePoint(v, 1, -angles[1]), 2, -angles[3]), 3, -angles[2])
  else
    v = rotatePoint(rotatePoint(rotatePoint(v, 3, angles[2]), 2, angles[3]), 1, angles[1])
  end

  return { v[1], -v[3], v[2] / FLOOR_HEIGHT }
end

--- sets the offsets that put the measured box's centre in the middle of the item's slot, resting on the surface.
--- the bottom offset is only kept while it's believable (a few meshes have broken bounds).
---@param profile IAArrangableProfile
---@param center  number[] x, y in tiles, z in floors, relative to the item's origin
---@param height? number the box's height in floors, defaults to the profile's dz
local function setCenterOffsets(profile, center, height)
  height = height or profile.dz

  local mz = scaleDimension(height / 2 - center[3], 1)

  profile.center = center
  profile.mx = scaleDimension(-center[1], 1)
  profile.my = scaleDimension(-center[2], 1)
  profile.mz = nil

  if mz ~= 0 and math.abs(mz) <= height + MAX_BOTTOM_OFFSET_SLACK then
    profile.mz = mz
  end
end

---@param worldMesh CAIAE_WorldMesh
---@return table | nil, string | nil
local function getMeshSize(worldMesh)
  for i = 1, #worldMesh.sizeKeys do
    local key = worldMesh.sizeKeys[i]

    if meshSizes[key] then
      return meshSizes[key], key
    end
  end

  return nil, nil
end

--- profile from the model's measured size, lying the way the game draws it and centred in its slot.
---@param worldMesh CAIAE_WorldMesh
---@return IAArrangableProfile | nil
local function getMeasuredProfile(worldMesh)
  local size, key = getMeshSize(worldMesh)

  if not size then
    return nil
  end

  ---@cast key string
  local profile = measuredProfiles[key]

  if profile == nil then
    if isMeasurable(size.dx, MAX_MEASURED_LENGTH)
      and isMeasurable(size.dy, MAX_MEASURED_LENGTH)
      and isMeasurable(size.dz) then
      profile = { dx = size.dx, dy = size.dy, dz = size.dz, qz = 1 }

      local center = { size.cx or 0, size.cy or 0, size.dz / 2 - (size.oz or 0) }

      -- long, skinny items (rods, bats) lying along x are turned to lie along y
      if size.dx >= size.dy * SKINNY_RATIO then
        profile.dx, profile.dy, profile.fz = size.dy, size.dx, 90
        center = turnPoint(center, { 0, 0, 90 }, false)
      end

      if profile.dx > MAX_FOOTPRINT then profile.lx = profile.dx end
      if profile.dy > MAX_FOOTPRINT then profile.ly = profile.dy end

      profile.dx = math.min(profile.dx, MAX_FOOTPRINT)
      profile.dy = math.min(profile.dy, MAX_FOOTPRINT)

      setCenterOffsets(profile, center)
    else
      profile = false
    end

    measuredProfiles[key] = profile
  end

  return profile or nil
end

local SCALED_ENTRY_KEYS = { dx = true, dy = true, dz = true, mx = true, my = true, mz = true }

---@param manual    CAIAE_MeshOverride
---@param worldMesh CAIAE_WorldMesh
---@return table fields, number ratio
local function getScaledEntry(manual, worldMesh)
  local ratio = manual.s and getMeshScale(worldMesh) / manual.s or 1
  local fields = {}

  for k, v in pairs(manual) do
    if not MESH_PROFILE_KEYS[k] then
      fields[k] = SCALED_ENTRY_KEYS[k] and scaleDimension(v, ratio) or v
    end
  end

  return fields, ratio
end

---@param worldMesh CAIAE_WorldMesh
---@param manual    CAIAE_MeshOverride
---@return IAArrangableProfile?, string?, number?
local function getInlineProfile(worldMesh, manual)
  if not manual.dx or not manual.dy or not manual.dz then
    return nil, nil, nil
  end

  local profile, ratio = getScaledEntry(manual, worldMesh)

  ---@cast profile IAArrangableProfile
  return profile, INLINE, ratio
end

---@param learned table<string, CAIAE_LearnedProfile[]>
---@param mesh    string
---@return CAIAE_ScaledProfileName[]
local function getCandidates(learned, mesh)
  local candidates = candidateCache[mesh]

  if candidates then
    return candidates
  end

  candidates = {}

  local manual = IA.meshProfiles[mesh]

  if type(manual) == "table" and manual.p and manual.s then
    candidates[1] = { name = manual.p, scale = manual.s }
  end

  local entries = learned[mesh]

  if entries then
    local learnedCandidates = {}

    for i = 1, #entries do
      local entry = entries[i]

      learnedCandidates[#learnedCandidates + 1] = { name = entry.name, scale = getMeshScale(entry.worldMesh) }
    end

    table.sort(learnedCandidates, function (a, b)
      if a.name ~= b.name then
        return a.name < b.name
      end

      return a.scale < b.scale
    end)

    for i = 1, #learnedCandidates do
      candidates[#candidates + 1] = learnedCandidates[i]
    end
  end

  candidateCache[mesh] = candidates

  return candidates
end

---@param learned   table<string, CAIAE_LearnedProfile[]>
---@param worldMesh CAIAE_WorldMesh
---@return IAArrangableProfile?, string?, number?
local function resolveBaseProfile(learned, worldMesh)
  local manual = IA.meshProfiles[worldMesh.mesh]

  -- hand-made profiles always win, measured sizes only fill the gaps
  if type(manual) == "string" then
    return IA.arrangableProfile[manual], manual, 1
  end

  if type(manual) == "table" and manual.p and not manual.s then
    return IA.arrangableProfile[manual.p], manual.p, 1
  end

  local candidates = getCandidates(learned, worldMesh.mesh)

  if #candidates == 0 then
    -- a mesh entry without `p` (e.g. `{ qz = 4 }`) tweaks the measured profile, see applyOverrides
    local measured = getMeasuredProfile(worldMesh)

    if measured then
      return measured, MEASURED, 1
    end

    if type(manual) == "table" then
      return getInlineProfile(worldMesh, manual)
    end

    return nil, nil, nil
  end

  local scale = getMeshScale(worldMesh)
  ---@type CAIAE_ScaledProfileName
  local best
  ---@type number
  local bestDistance

  for i = 1, #candidates do
    local candidate = candidates[i]

    ---@diagnostic disable-next-line: unnecessary-if
    if IA.arrangableProfile[candidate.name] then
      local distance = math.abs(math.log(scale / candidate.scale))

      if not best or distance < bestDistance - SCALE_EPSILON then
        best = candidate
        bestDistance = distance
      end
    end
  end

  if not best then
    return nil, nil, nil
  end

  local ratio = scale / best.scale

  if math.abs(ratio - 1) < SCALE_EPSILON then
    return IA.arrangableProfile[best.name], best.name, 1
  end

  return getScaledProfile(best.name, ratio), best.name, ratio
end

--- the rotation each flip key adds to, `flip` is short for `flipZ`.
local FLIP_KEYS = { flip = "fz", flipX = "fx", flipY = "fy", flipZ = "fz" }

--- sign-less rotation of `turns` quarter turns that turns axis `a` into `b`: odd turns swap the two axes, even ones
--- leave every axis on its own.
---@param turns number
---@param a     integer
---@param b     integer
---@return number[]
local function getQuarterTurn(turns, a, b)
  local m = { 1, 0, 0, 0, 1, 0, 0, 0, 1 }

  if math.abs(turns) % 2 == 1 then
    m[(a - 1) * 3 + a], m[(b - 1) * 3 + b] = 0, 0
    m[(a - 1) * 3 + b], m[(b - 1) * 3 + a] = 1, 1
  end

  return m
end

---@param a number[]
---@param b number[]
---@return number[]
local function multiplyMatrices(a, b)
  local m = {}

  for row = 0, 2 do
    for col = 1, 3 do
      m[row * 3 + col] = a[row * 3 + 1] * b[col] + a[row * 3 + 2] * b[col + 3] + a[row * 3 + 3] * b[col + 6]
    end
  end

  return m
end

---@param m          number[]
---@param v          number[]
---@param transposed boolean multiply by the inverse, which is the transpose for rotations
---@return number[]
local function transformVector(m, v, transposed)
  local result = {}

  for i = 1, 3 do
    local sum = 0

    for j = 1, 3 do
      sum = sum + (transposed and m[(j - 1) * 3 + i] or m[(i - 1) * 3 + j]) * v[j]
    end

    result[i] = sum
  end

  return result
end

--- sign-less rotation matrix of a quarter-turn rotation, nil when an angle isn't a multiple of 90. Composed like
--- Item Arrange does (`RotX(fx) * RotY(fz) * RotZ(fy)`, y up), where model x is IA's x and model z is IA's y.
---@param fx number
---@param fy number
---@param fz number
---@return number[] | nil
local function getQuarterTurnMatrix(fx, fy, fz)
  if fx % 90 ~= 0 or fy % 90 ~= 0 or fz % 90 ~= 0 then
    return nil
  end

  return multiplyMatrices(getQuarterTurn(fx / 90, 2, 3),
    multiplyMatrices(getQuarterTurn(fz / 90, 1, 3), getQuarterTurn(fy / 90, 1, 2)))
end

--- dx/dy/dz of the profile after turning it from one rotation to another, nil when either isn't quarter turns.
---@param profile IAArrangableProfile
---@param from    number[] fx, fy, fz
---@param to      number[] fx, fy, fz
---@return number?, number?, number?
local function getTurnedDimensions(profile, from, to)
  local before = getQuarterTurnMatrix(from[1], from[2], from[3])
  local after = getQuarterTurnMatrix(to[1], to[2], to[3])

  if not before or not after or not profile.dx or not profile.dy or not profile.dz then
    return nil, nil, nil
  end

  -- world extents in model axis order (x, up, y), back to the unrotated model, then turned the new way
  local world = { profile.dx, profile.dz * FLOOR_HEIGHT, profile.dy }
  local turned = transformVector(after, transformVector(before, world, true), false)

  return scaleDimension(turned[1], 1), scaleDimension(turned[3], 1), scaleDimension(turned[2] / FLOOR_HEIGHT, 1)
end

--- turns the result by the entry's flip keys, swapping the profile's dimensions to match. dimensions the entry sets
--- itself are final, they're applied after turning. measured profiles also move their offsets along, so the item stays
--- centred in its slot and rests on whichever side ends up at the bottom.
---@param result  IAArrangableProfile
---@param profile IAArrangableProfile the profile before the entry's fields, whose dimensions get turned
---@param manual  CAIAE_MeshOverride
local function applyFlips(result, profile, manual)
  local from = { result.fx or 0, result.fy or 0, result.fz or 0 }
  local to = { from[1], from[2], from[3] }
  local index = { fx = 1, fy = 2, fz = 3 }
  local flipped = false

  for key, field in pairs(FLIP_KEYS) do
    result[key] = nil

    if manual[key] then
      to[index[field]] = (to[index[field]] + 90) % 360
      flipped = true
    end
  end

  local dx, dy, dz

  if flipped then
    dx, dy, dz = getTurnedDimensions(profile, from, to)
    result.fx, result.fy, result.fz = to[1], to[2], to[3]
  end

  if profile.center then
    local own = { profile.fx or 0, profile.fy or 0, profile.fz or 0 }

    setCenterOffsets(result, turnPoint(turnPoint(profile.center, own, true), to, false), dz or profile.dz)
    result.mx, result.my, result.mz = manual.mx or result.mx, manual.my or result.my, manual.mz or result.mz
  elseif dz and dz ~= profile.dz and manual.mz == nil then
    -- the bottom offset belongs to the side the item lay on, so a turn onto another side drops it
    result.mz = nil
  end

  if dx then
    result.dx, result.dy, result.dz = manual.dx or dx, manual.dy or dy, manual.dz or dz

    if profile.lx or profile.ly then
      local real = { dx = profile.lx or profile.dx, dy = profile.ly or profile.dy, dz = profile.dz }
      local lx, ly = getTurnedDimensions(real, from, to)

      result.lx = lx and lx > result.dx and lx or nil
      result.ly = ly and ly > result.dy and ly or nil
    end
  end
end

---@param worldMesh CAIAE_WorldMesh
---@param profile   IAArrangableProfile
---@param name      string
---@param ratio     number
---@return IAArrangableProfile
local function applyOverrides(worldMesh, profile, name, ratio)
  local manual = IA.meshProfiles[worldMesh.mesh]

  -- an inline profile is the entry itself
  if type(manual) ~= "table" or name == INLINE then
    return profile
  end

  local own, ownRatio = getScaledEntry(manual, worldMesh)
  local hasOwn = false

  for _ in pairs(own) do
    hasOwn = true
    break
  end

  if not hasOwn then
    return profile
  end

  local key = string.format("%s@%s@%.3f@%.3f", worldMesh.mesh, name, ratio, ownRatio)
  local result = overriddenProfiles[key]

  ---@diagnostic disable-next-line: unnecessary-if
  if result then
    return result
  end

  result = {}

  for k, v in pairs(profile) do
    result[k] = v
  end

  for k, v in pairs(own) do
    result[k] = v
  end

  applyFlips(result, profile, own)

  overriddenProfiles[key] = result

  return result
end

---@param learned   table<string, CAIAE_LearnedProfile[]>
---@param worldMesh CAIAE_WorldMesh
---@return IAArrangableProfile?, string?, number?
local function resolveProfile(learned, worldMesh)
  local profile, name, ratio = resolveBaseProfile(learned, worldMesh)

  if not profile then
    return nil, nil, nil
  end

  ---@cast name string
  ---@cast ratio number
  return applyOverrides(worldMesh, profile, name, ratio), name, ratio
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
              'IA.arrangables["%-40s = IA.arrangableProfile.%-12s -- %s (%s @%s%s)', fullType .. '"]', profileName, modID,
              worldMesh and worldMesh.mesh or "N/A", tostring(worldMesh and worldMesh.scale or "N/A"), scaleNote
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
