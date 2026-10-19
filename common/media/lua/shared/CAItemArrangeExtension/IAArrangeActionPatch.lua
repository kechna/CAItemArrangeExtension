require("TimedActions/IAArrangeAction")
require("TimedActions/ISTransferAction")
require("CAItemArrangeExtension/IAArrangePatch")

local IAArrangeAction = IAArrangeAction or nil
local IA = IA or nil

if not IAArrangeAction or not IA or not IA.getFacing then return end

local ISTransferAction = ISTransferAction
local sendRemoveItemFromContainer = sendRemoveItemFromContainer
local isAltKeyDown = isAltKeyDown
local isCtrlKeyDown = isCtrlKeyDown
local isServer = isServer

-- patches Item Arrange's arrange action:
--  - skip items that are no longer in their container, so they don't turn into ghost items
--  - hold Shift+Alt to skip items that can't be arranged, hold Ctrl to not stack items
--  - only check the space again when the items on the square changed
--  - orient the items by the player's facing mode option, on the server too where there's no mod option

---@class IAArrangeAction: ISBaseTimedAction
---@field character IsoPlayer
---@field item InventoryItem
---@field srcContainer ItemContainer
---@field dropSquare IsoGridSquare
---@field skipItem boolean
---@field altKey boolean
---@field ctrlKey boolean
---@field facingMode IAFacingMode

IAArrangeAction._originalNew = IAArrangeAction._originalNew or IAArrangeAction.new
local originalNew = IAArrangeAction._originalNew

local function isStale(action)
  local item = action.item
  local srcContainer = action.srcContainer

  return
    item:getContainer() ~= srcContainer
    or not srcContainer:contains(item)
    or item:getWorldItem() ~= nil
end

function IAArrangeAction:isValid()
  if not self.item or not self.dropSquare or not self.srcContainer then
    return false
  end

  if isStale(self) then
    self.skipItem = true
    return true
  end

  if self.character:getSquare():isSomethingTo(self.dropSquare) then
    return false
  end

  -- isValid runs every tick, so only check the space again when the items on the square changed
  local worldItemCount = self.dropSquare:getWorldObjects():size()
  if self.checkedWorldItemCount ~= worldItemCount then
    self.checkedWorldItemCount = worldItemCount
    local facing = IA.getFacing(self.character, self.dropSquare, self.facingMode)
    self.spaceValid, self.spaceSkipItem = IA.CheckSpace(self.dropSquare, self.item, self.altKey, facing)
  end

  if not self.spaceValid then
    return false
  elseif self.spaceSkipItem then
    self.skipItem = true
  end

  return true
end

function IAArrangeAction:complete()
  if self.skipItem or isStale(self) then return true end

  local item = self.item

  self.srcContainer:DoRemoveItem(item)
  sendRemoveItemFromContainer(self.srcContainer, item)
  self.srcContainer:setDrawDirty(true)
  self.srcContainer:setHasBeenLooted(true)

  local parent = self.srcContainer:getParent()

  local ItemPicker = ItemPicker
  if ItemPicker and parent and parent:getOverlaySprite() then
    ItemPicker.updateOverlaySprite(parent)
  end

  if ISTransferAction:removeItemOnCharacter(self.character, item) then
    self.dropSquare:AddWorldInventoryItem(item, 0.5, 0.5, 0.0)
  end

  -- the item is on the square already, so the action succeeded even when it doesn't fit the arrangement
  local facing = IA.getFacing(self.character, self.dropSquare, self.facingMode)
  IA.ArrangeItems(self.dropSquare, false, self.ctrlKey, facing)

  return true
end

-- in MP the client sends the fields named after `new`'s parameters and the server calls `new` with them, so the
-- parameters must be named (no `...`) and the held keys are parameters too, read on the client only. Item Arrange
-- passes its own fifth argument (ctrl key or time), so the client always reads them itself
function IAArrangeAction:new(character, item, srcContainer, dropSquare, altKey, ctrlKey, facingMode)
  local o = originalNew(self, character, item, srcContainer, dropSquare)
  o.skipItem = false

  if not isServer() then
    altKey = isAltKeyDown()
    ctrlKey = isCtrlKeyDown()
    facingMode = IA.FacingMode
  end

  o.altKey = altKey == true
  o.ctrlKey = ctrlKey == true
  o.facingMode = facingMode or "walls"

  return o
end
