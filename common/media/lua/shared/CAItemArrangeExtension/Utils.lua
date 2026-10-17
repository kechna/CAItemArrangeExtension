local Utils = {}

---@generic T: table
---@param profile T
---@param fields  table
---@return T
function Utils.extend(profile, fields)
  local newProfile = {}
  for k, v in pairs(profile) do
    newProfile[k] = v
  end
  for k, v in pairs(fields) do
    newProfile[k] = v
  end

  return newProfile
end

---@generic T: table
---@param profile T
---@param offsets table<string, number>
---@return T
function Utils.modify(profile, offsets)
  local newProfile = {}
  for k, v in pairs(profile) do
    newProfile[k] = v
  end
  for k, v in pairs(offsets) do
    newProfile[k] = (newProfile[k] or 0) + v
  end

  return newProfile
end

--- Sets the surfaces of a sprite in `IA.surfaces`. Write surfaces through this, so a dev build can track them.
---@param sprite   string
---@param surfaces table<integer, IASurfaceProfile> | nil
function Utils.setSurfaces(sprite, surfaces)
  IA.surfaces[sprite] = surfaces
end

--- Adds `offsets` to the surface at `index` of a sprite, or to every surface when `index` is nil, see
--- `Utils.modify`. Several calls on one sprite add up: `modifySurfaces("x", { ymin = 0.2, xmax = -0.1 }, 2)`.
---@param sprite  string
---@param offsets table<string, number>
---@param index   integer?
function Utils.modifySurfaces(sprite, offsets, index)
  local current = IA.surfaces[sprite]

  if not current then
    print(string.format("CAItemArrangeExtension: no surfaces to modify for %s", sprite))
    return
  end

  ---@type table<integer, IASurfaceProfile>
  local result = {}
  for i = 1, #current do
    result[i] = (index == nil or index == i) and Utils.modify(current[i], offsets) or current[i]
  end

  Utils.setSurfaces(sprite, result)
end

return Utils
