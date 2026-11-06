require("TimedActions/IAInventoryTransferUtil")

-- picks the tile item arrange drops onto when shift+dropping, and highlights it while dragging items with shift held.
--  - the highlight goes on the tile's furniture with a surface to put items on, or on the floor when there is none.
--    it's registered with `ISInventoryPage.OnObjectHighlighted` and re-applied every frame so it wins over the loot
--    window's container highlight. the tile's other objects (e.g. the container next to a counter top) are registered
--    too and kept unhighlighted, so their highlight doesn't flicker through.
--  - item arrange turns the mouse into a tile with isometric screen maths, which is wrong under viewpoint's 3d
--    camera. when viewpoint has a fresh pick under the cursor (`Viewpoint.Mouse.worldX/Y`), use that instead.
--  - like item arrange, the tile is clamped to the player's own tile and the 8 around it.

local floor = math.floor
local mathMax = math.max
local mathMin = math.min

local HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, HIGHLIGHT_A = 0.4, 0.8, 1.0, 1.0

CAIAE_DropTarget = CAIAE_DropTarget or { hooks = {} }
local DropTarget = CAIAE_DropTarget

---@return number|nil, number|nil
local function viewpointWorldXY()
  local mouse = Viewpoint and Viewpoint.Mouse
  if not mouse or not mouse.worldX then return nil, nil end

  local okX, wx = pcall(mouse.worldX)
  local okY, wy = pcall(mouse.worldY)
  if not okX or not okY or not wx or not wy then return nil, nil end

  return wx, wy
end

---@param character IsoGameCharacter
---@return IsoGridSquare|nil
function DropTarget.getDropSquare(character)
  local square = character:getSquare()
  if not square then return nil end

  local cx, cy, cz = square:getX(), square:getY(), square:getZ()
  local tx, ty = viewpointWorldXY()

  if tx then
    tx, ty = floor(tx), floor(ty)
  else
    local mx, my = getMouseX(), getMouseY()
    local playerNum = character.getPlayerNum and character:getPlayerNum() or 0
    tx = floor(screenToIsoX(playerNum, mx, my, cz))
    ty = floor(screenToIsoY(playerNum, mx, my, cz))
  end

  tx = mathMax(cx - 1, mathMin(cx + 1, tx))
  ty = mathMax(cy - 1, mathMin(cy + 1, ty))

  return getCell():getGridSquare(tx, ty, cz)
end

ISInventoryTransferUtil.getDropSquare = DropTarget.getDropSquare

local function isDraggingItems()
  local dragging = ISMouseDrag and ISMouseDrag.dragging
  return dragging ~= nil and #dragging > 0
end

local function applyHighlight(playerNum, object)
  object:setHighlighted(playerNum, true, false)
  object:setHighlightColor(playerNum, HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, HIGHLIGHT_A)
  object:setOutlineHighlight(playerNum, true)
  object:setOutlineHlAttached(playerNum, true)
  object:setOutlineHighlightCol(playerNum, HIGHLIGHT_R, HIGHLIGHT_G, HIGHLIGHT_B, HIGHLIGHT_A)
end

local function setHighlightedElsewhere(playerNum, object, isHighlighted)
  if ISInventoryPage and ISInventoryPage.OnObjectHighlighted then
    ISInventoryPage.OnObjectHighlighted(playerNum, object, isHighlighted)
  end
end

local function removeHighlight(playerNum, object)
  object:setHighlighted(playerNum, false, false)
  object:setOutlineHighlight(playerNum, false)
  object:setOutlineHlAttached(playerNum, false)
end

local function clearHighlight()
  local current = DropTarget.highlighted
  if not current then return end

  DropTarget.highlighted = nil
  local playerNum = current.playerNum
  local lists = { current.objects or { current.object }, current.others or {} }
  for l = 1, #lists do
    local objects = lists[l]
    for i = 1, #objects do
      local object = objects[i]
      removeHighlight(playerNum, object)
      -- the loot window re-applies its own highlight if this is its container
      setHighlightedElsewhere(playerNum, object, false)
    end
  end
end

---@param object IsoObject
---@return boolean
local function hasSurface(object)
  local sprite = object:getSprite()
  local name = sprite and sprite:getName()
  if name and IA and IA.surfaces and IA.surfaces[name] then return true end

  return object:getSurfaceOffsetNoTable() > 0 or object:getSurfaceOffset() > 0
end

--- The furniture on the square that items can be put on, or the floor when there is none.
---@param square IsoGridSquare
---@return IsoObject[], IsoObject[] highlighted, the square's other objects
local function getHighlightObjects(square)
  local highlighted = {}
  local others = {}
  local objects = square:getObjects()
  for i = 0, objects:size() - 1 do
    local object = objects:get(i)
    if hasSurface(object) then
      highlighted[#highlighted + 1] = object
    else
      others[#others + 1] = object
    end
  end

  if #highlighted == 0 then
    local floorObject = square:getFloor()
    if floorObject then
      highlighted[1] = floorObject
      for i = 1, #others do
        if others[i] == floorObject then
          table.remove(others, i)
          break
        end
      end
    end
  end

  return highlighted, others
end

local function onRenderTick()
  -- runs every frame: check the drag first, it's a plain lua table lookup, so idle frames make no java calls
  if not isDraggingItems() or not isShiftKeyDown() then
    clearHighlight()
    return
  end

  local player = getPlayer()
  if not player then
    clearHighlight()
    return
  end

  local square = DropTarget.getDropSquare(player)
  local current = DropTarget.highlighted
  if not current or current.square ~= square then
    clearHighlight()
    if not square then return end

    local playerNum = player:getPlayerNum()
    local objects, others = getHighlightObjects(square)
    for i = 1, #objects do
      setHighlightedElsewhere(playerNum, objects[i], true)
    end
    for i = 1, #others do
      setHighlightedElsewhere(playerNum, others[i], true)
    end
    current = { square = square, objects = objects, others = others, playerNum = playerNum }
    DropTarget.highlighted = current
  end

  -- re-applied every frame: other code (loot window hover, other mods) may recolor the same objects
  local playerNum = current.playerNum
  local objects = current.objects
  for i = 1, #objects do
    applyHighlight(playerNum, objects[i])
  end

  local others = current.others
  for i = 1, #others do
    removeHighlight(playerNum, others[i])
  end
end

local function registerHook(event, hook)
  if DropTarget.hooks[event] then
    Events[event].Remove(DropTarget.hooks[event])
  end

  DropTarget.hooks[event] = hook
  Events[event].Add(hook)
end

clearHighlight()
registerHook("OnRenderTick", onRenderTick)
