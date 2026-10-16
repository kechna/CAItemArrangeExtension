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

return Utils
