require "TimedActions/ISBaseTimedAction"

---@class IAArrangeAction: ISBaseTimedAction
---@field character IsoPlayer
---@field item InventoryItem
---@field srcContainer ItemContainer
---@field dropSquare IsoGridSquare
---@field startTime number
---@field maxTime number
---@field loopSound integer
---@field skipItem boolean
---@field altKey boolean
---@field ctrlKey boolean
IAArrangeAction = ISBaseTimedAction:derive("IAArrangeAction")

local CLIENT_DELAY_FOR_MULTI_TRANSACTION = 10
-- keep only one instance of this action so we can queue item to transfer and avoid ton of instance when moving lot of items.

local function isStale(action)
  local item = action.item
  local srcContainer = action.srcContainer

  return
    item:getContainer() ~= srcContainer
    or not srcContainer:contains(item)
    or item:getWorldItem() ~= nil
end

function IAArrangeAction:isValid()
    if not self.item then
        return false
    end
    if not self.dropSquare or not self.srcContainer then
        return false
    end
    if isStale(self) then
        self.skipItem = true
        return true
    end
    if self.character:getSquare():isSomethingTo(self.dropSquare) then
        return false
    end

    local spaceValid, skipItem = IA.CheckSpace(self.dropSquare, self.item, self.altKey)

    if not spaceValid then
        return false
    elseif skipItem then
        self.skipItem = true
    end

    return true
end

function IAArrangeAction:stopLoopingSound()
    if self.loopSound then
        self.character:getEmitter():stopSound(self.loopSound)
        self.loopSound = nil
	end
end

function IAArrangeAction:update()

    self.item:setJobDelta(self.action:getJobDelta())

    self.character:setMetabolicTarget(Metabolics.LightWork)

end

function IAArrangeAction:waitToStart()
    if not isClient() then
        return false
    else
        local timePassed = getTimestampMs() - self.startTime
        return timePassed < CLIENT_DELAY_FOR_MULTI_TRANSACTION
    end
end

function IAArrangeAction:start()
    self:setActionAnim("Loot")
    self.loopSound = self.character:getEmitter():playSound("RummageInInventory")
end

function IAArrangeAction:stop()
    self:stopLoopingSound()
    self.item:setJobDelta(0.0)
    if self.action then
        self.action:setLoopedAction(false)
    end
    ISBaseTimedAction.stop(self)
end

function IAArrangeAction:perform()

    if isServer() then
        return
    end

    self:stopLoopingSound()
    self.item:setJobDelta(0.0)

    -- needed to remove from queue / start next.
    ISBaseTimedAction.perform(self)

    ISInventoryPage.renderDirty = true
end

function IAArrangeAction:complete()
  if self.skipItem or isStale(self) then return true end

  local item = self.item

  self.srcContainer:DoRemoveItem(item)
  sendRemoveItemFromContainer(self.srcContainer, item)
  self.srcContainer:setDrawDirty(true)
  self.srcContainer:setHasBeenLooted(true)

  local parent = self.srcContainer:getParent()

  if ItemPicker and parent and parent:getOverlaySprite() then
    ItemPicker.updateOverlaySprite(parent)
  end

  if ISTransferAction:removeItemOnCharacter(self.character, item) then
    self.dropSquare:AddWorldInventoryItem(item, 0.5, 0.5, 0.0)
  end

  return IA.ArrangeItems(self.dropSquare, false, self.ctrlKey)
end

function IAArrangeAction:getTimeDelta()
    return 0
end

function IAArrangeAction:getDuration()
    if self.character:isTimedActionInstant() then
        return 1
    end

    local time = 120
    local w = self.item:getActualWeight()
    if w > 3 then
        w = 3
    end
    time = time * (w)

    if self.srcContainer == self.character:getInventory() then
        time = time * 0.1
    elseif self.srcContainer:isInCharacterInventory(self.character) then
        -- Unpack -> drop
    else
        time = time * 0.2
    end

    if self.character:hasTrait(CharacterTrait.DEXTROUS) then
        time = time * 0.5
    end
    if self.character:hasTrait(CharacterTrait.ALL_THUMBS) or self.character:isWearingAwkwardGloves() then
        time = time * 2.0
    end

    return time
end

function IAArrangeAction:new (character, item, srcContainer, dropSquare)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.character = character
    o.item = item
    o.srcContainer = srcContainer
    o.dropSquare = dropSquare
    o.startTime = getTimestampMs()
    o.maxTime = o:getDuration()
    o.skipItem = false
    o.altKey = isAltKeyDown()
    o.ctrlKey = isCtrlKeyDown()
    return o
end
