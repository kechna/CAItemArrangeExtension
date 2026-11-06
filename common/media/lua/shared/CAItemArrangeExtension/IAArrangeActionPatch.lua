require("TimedActions/IAArrangeAction")
require("TimedActions/ISTransferAction")
require("CAItemArrangeExtension/IAArrangePatch")

local IAArrangeAction = IAArrangeAction or nil
local IA = IA or nil

if not IAArrangeAction or not IA or not IA.getFacing or not IA.getArrangedFacing or not IA.getArrangeGroup then return end

local ISTransferAction = ISTransferAction
local sendRemoveItemFromContainer = sendRemoveItemFromContainer
local isAltKeyDown = isAltKeyDown
local isCtrlKeyDown = isCtrlKeyDown
local isServer = isServer

-- patches Item Arrange's arrange action:
--  - skip items that are no longer in their container, so they don't turn into ghost items
--  - skip items that don't fit instead of cancelling the rest of the queue
--  - hold Shift+Alt to skip items that can't be arranged, hold Ctrl to not stack items
--  - only check the space again when the items on the square changed
--  - orient the items by the player's facing mode option, on the server too where there's no mod option. a square
--    that is arranged already keeps its orientation

---@class IAArrangeAction: ISBaseTimedAction
---@field character IsoPlayer
---@field item InventoryItem
---@field srcContainer ItemContainer
---@field dropSquare IsoGridSquare
---@field skipItem boolean
---@field altKey boolean
---@field ctrlKey boolean
---@field facingMode IAFacingMode
---@field wallSprite string | nil wall board on `dropSquare` the item goes on

IAArrangeAction._originalNew = IAArrangeAction._originalNew or IAArrangeAction.new
local originalNew = IAArrangeAction._originalNew

-- read before the item lands on the square, so its own leftover rotation doesn't count
local function facingOf(action)
  local square = action.dropSquare

  return IA.getArrangedFacing(square) or IA.getFacing(action.character, square, action.facingMode)
end

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
  local worldItemCount = 0
  local members = IA.getArrangeGroup(self.dropSquare).members
  for i = 1, #members do
    worldItemCount = worldItemCount + members[i].square:getWorldObjects():size()
  end
  if self.checkedWorldItemCount ~= worldItemCount then
    self.checkedWorldItemCount = worldItemCount
    local facing = facingOf(self)
    self.spaceValid, self.spaceSkipItem = IA.CheckSpace(self.dropSquare, self.item, self.altKey, facing, self.wallSprite)
  end

  -- an invalid action clears the whole queue, so items after this one would never be dropped
  if not self.spaceValid or self.spaceSkipItem then
    self.skipItem = true
  end

  return true
end

IAArrangeAction._originalUpdate = IAArrangeAction._originalUpdate or IAArrangeAction.update
local originalUpdate = IAArrangeAction._originalUpdate

-- each skipped action still takes a few frames, so with hundreds of items that don't fit the character would keep
-- "placing" for a long time. the square doesn't change while skipping, so drop the queued items that won't fit either
local function dropQueuedMisfits(action)
  local ISTimedActionQueue = ISTimedActionQueue
  if not ISTimedActionQueue or not ISTimedActionQueue.getTimedActionQueue then return end

  local queue = ISTimedActionQueue.getTimedActionQueue(action.character)
  local list = queue and queue.queue
  if not list or list[1] ~= action then return end

  local square = action.dropSquare
  local facing = facingOf(action)
  local fitsByType = {}
  local kept = { action }

  for i = 2, #list do
    local queued = list[i]
    local keep = true

    if queued.Type == "IAArrangeAction" and queued.dropSquare == square and queued.item and not queued.altKey
      and queued.wallSprite == action.wallSprite then
      local fullType = queued.item:getFullType()
      local fits = fitsByType[fullType]

      if fits == nil then
        fits = IA.CheckSpace(square, queued.item, false, facing, action.wallSprite) and true or false
        fitsByType[fullType] = fits
      end

      keep = fits
    end

    if keep then
      kept[#kept + 1] = queued
    else
      queued:forceCancel()
    end
  end

  for i = #list, 1, -1 do
    list[i] = kept[i]
  end
end

-- the duration is fixed once the action started, so finish skipped items right away instead of playing the animation
function IAArrangeAction:update()
  if self.skipItem and self.action then
    if not self.spaceValid then
      dropQueuedMisfits(self)
    end

    self:forceComplete()
    return
  end

  originalUpdate(self)
end

function IAArrangeAction:complete()
  if self.skipItem or isStale(self) then return true end

  local item = self.item
  local facing = facingOf(self)

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
  IA.ArrangeItems(self.dropSquare, false, self.ctrlKey, facing, self.wallSprite, item)

  return true
end

-- in MP the client sends the fields named after `new`'s parameters and the server calls `new` with them, so the
-- parameters must be named (no `...`) and the held keys are parameters too, read on the client only. Item Arrange
-- passes its own fifth argument (ctrl key or time), so the client always reads them itself
function IAArrangeAction:new(character, item, srcContainer, dropSquare, altKey, ctrlKey, facingMode, wallSprite)
  local o = originalNew(self, character, item, srcContainer, dropSquare)
  o.skipItem = false

  if not isServer() then
    altKey = isAltKeyDown()
    ctrlKey = isCtrlKeyDown()
    facingMode = IA.FacingMode
    local board = CAIAE_DropTarget and CAIAE_DropTarget.board
    wallSprite = board and board.square == dropSquare and board.sprite or nil
  end

  o.altKey = altKey == true
  o.ctrlKey = ctrlKey == true
  o.facingMode = facingMode or "walls"
  o.wallSprite = wallSprite

  return o
end
