require("IAArrange")

local IA = IA or nil

if not IA or not IA.getSurfaceInfo or not IA.CheckSpace or not IA.ArrangeItems then return end

local pairs = pairs
local ipairs = ipairs
local print = print
local tostring = tostring
local mathAbs = math.abs
local mathAsin = math.asin
local mathAtan2 = math.atan2
local mathCos = math.cos
local mathDeg = math.deg
local mathFloor = math.floor
local mathMax = math.max
local mathMin = math.min
local mathRad = math.rad
local mathSin = math.sin
local tableInsert = table.insert
local tableRemove = table.remove
local getPlayer = getPlayer

-- MOST OF THIS IS SLAYER'S OWN ITEM ARRANGE MOD, WHICH IS NOT MY WORK.
-- I (Kechna) AM NOT THE AUTHOR OF THE ORIGINAL MOD, AND I DO NOT CLAIM TO BE. I AM MERELY PROVIDING AN EXTENSION AND SOME PATCHES TO IT.
-- Original mod: https://steamcommunity.com/sharedfiles/filedetails/?id=3767639280
-- My extension: https://steamcommunity.com/sharedfiles/filedetails/?id=3813943783

-- This file replaces IA.getSurfaceInfo, IA.CheckSpace and IA.ArrangeItems with these patches:
--  - support multiple objects with surfaces per tile, such as shelves above counters
--  - allow arranging on top of tall furniture, such as stacked crates
--  - lift items off rugs and surfaces a little, so they don't clip into them
--  - keep long items (lx/ly) on the surface and start new rows by each item type's own size
--  - optionally orient items by the player instead of by the walls (mod option)
--  - fix the bounds check for S and E walls
--  - hold ctrl to not stack items, shift+alt to skip non-arrangeable items

-- I'm waiting for Slayer to have some time to potentially include some of my patches in the core mod.

local CURSOR_ORDER_N = 1
local CURSOR_ORDER_W = 2
local CURSOR_ORDER_S = 3
local CURSOR_ORDER_E = 4

-- rows start at the back of a counter, which is the side opposite its facing
local FACING_CURSOR_ORDER = { N = CURSOR_ORDER_S, E = CURSOR_ORDER_W, S = CURSOR_ORDER_N, W = CURSOR_ORDER_E }

local CURSOR_YAW = {
    [CURSOR_ORDER_N] = 0,
    [CURSOR_ORDER_W] = 270,
    [CURSOR_ORDER_S] = 180,
    [CURSOR_ORDER_E] = 90,
}

local SURFACE_CLEARANCE = 0.003

-- placements closer than this to the current ones aren't synced again
local OFFSET_EPSILON = 0.0005
local ANGLE_EPSILON = 0.05

local RUG_LIFT = 0.006

-- footprints at least this square count as symmetric
local SYMMETRIC_RATIO = 0.8

-- items with a round or square footprint (bottles, cans, jars) fit the same either way, so they keep their profile's
-- rotation instead of turning with the surface. a profile's `yaw` decides when it's set
local function turnsWithSurface(arr)
    if arr.yaw ~= nil then
        return arr.yaw
    end

    local dx, dy = arr.lx or arr.dx, arr.ly or arr.dy

    return mathMin(dx, dy) < mathMax(dx, dy) * SYMMETRIC_RATIO
end

local function isRug(spriteName)
    local name = spriteName:lower()
    local padded = "_" .. name .. "_"
    return padded:find("_rugs?_") ~= nil
end

local function mat3Mul(a, b)
    local m = {}
    for row = 0, 2 do
        for col = 1, 3 do
            m[row * 3 + col] = a[row * 3 + 1] * b[col] + a[row * 3 + 2] * b[col + 3] + a[row * 3 + 3] * b[col + 6]
        end
    end

    return m
end

local function mat3RotX(deg)
    local r = mathRad(deg)
    local c, s = mathCos(r), mathSin(r)
    return { 1, 0, 0, 0, c, -s, 0, s, c }
end

local function mat3RotY(deg)
    local r = mathRad(deg)
    local c, s = mathCos(r), mathSin(r)
    return { c, 0, s, 0, 1, 0, -s, 0, c }
end

local function mat3RotZ(deg)
    local r = mathRad(deg)
    local c, s = mathCos(r), mathSin(r)
    return { c, -s, 0, s, c, 0, 0, 0, 1 }
end

local function applyYaw(fx, fy, fz, yaw)
    if yaw == 0 or fx == 0 then
        return fx, fy, (fz + yaw) % 360
    end

    local m = mat3Mul(mat3RotY(yaw), mat3Mul(mat3RotX(fx), mat3Mul(mat3RotY(fz), mat3RotZ(fy))))
    local sinB = mathMax(-1, mathMin(1, m[3]))
    local a, b, c = 0.0, mathAsin(sinB), 0.0

    if mathAbs(sinB) < 0.99999 then
        a = mathAtan2(-m[6], m[9])
        c = mathAtan2(-m[2], m[1])
    else
        a = mathAtan2(m[8], m[5])
        c = 0
    end

    return mathDeg(a) % 360, mathDeg(c) % 360, mathDeg(b) % 360
end

---@alias IAFacingMode "walls" | "towards" | "away" | "view" | "look"

local OPPOSITE = { N = "S", E = "W", S = "N", W = "E" }

---@alias IAFacing "N" | "E" | "S" | "W" | "walls"

--- `auto` keeps the square's arranged orientation and arranges a square that isn't arranged by the player's facing
---@alias IAArrangeFacing IAFacing | "auto"

--- The side items face when `character` arranges them on `square`, `walls` to orient them by the walls. Modes:
---  - `towards`/`away`: by where the player stands, because they may only turn towards the square later
---  - `view`/`look`: back at the player or the way they look, by where they look
--- On their own square the player's view decides in every mode.
---@param character IsoGameCharacter | nil
---@param square    IsoGridSquare
---@param mode?     IAFacingMode the client's mod option by default
---@return IAFacing | nil
local function facingOf(character, square, mode)
    mode = mode or IA.FacingMode
    if not mode or mode == "walls" then
        return "walls"
    end
    if not character then
        return nil
    end

    local dx, dy, adx, ady = 0, 0, 0, 0
    if mode ~= "view" and mode ~= "look" then
        dx = character:getX() - square:getX() - 0.5
        dy = character:getY() - square:getY() - 0.5
        adx, ady = dx < 0 and -dx or dx, dy < 0 and -dy or dy
    end

    if adx < 0.5 and ady < 0.5 then
        local forward = character:getForwardDirection()
        dx, dy = -forward:getX(), -forward:getY()
        adx, ady = dx < 0 and -dx or dx, dy < 0 and -dy or dy
    end

    local facing
    if adx > ady then
        facing = dx > 0 and "E" or "W"
    else
        facing = dy > 0 and "S" or "N"
    end

    return (mode == "away" or mode == "look") and OPPOSITE[facing] or facing
end

IA.getFacing = facingOf

---@param square IsoGridSquare
function IA.getSurfaceInfo(square)
    local cursorOrder = CURSOR_ORDER_N

    local ground = {
        zmin = 0.0,
        zmax = 1.0,
        xmin = 0.0,
        xmax = 1.0,
        ymin = 0.0,
        ymax = 1.0,
    }

    local squareN = square:getCell():getGridSquare(square:getX(), square:getY() - 1, square:getZ())
    local squareS = square:getCell():getGridSquare(square:getX(), square:getY() + 1, square:getZ())
    local squareW = square:getCell():getGridSquare(square:getX() - 1, square:getY(), square:getZ())
    local squareE = square:getCell():getGridSquare(square:getX() + 1, square:getY(), square:getZ())

    local wall = square:getWall()
    if wall then
        if wall:isWallN() then
            ground.ymin = 0.1
            cursorOrder = CURSOR_ORDER_N
        elseif wall:isWallW() then
            ground.xmin = 0.1
            cursorOrder = CURSOR_ORDER_W
        else
            ground.ymin = 0.1
            ground.xmin = 0.1
        end
    end

    if squareS then
        local wallS = squareS:getWall()
        if wallS and wallS:isWallN() then
            cursorOrder = CURSOR_ORDER_S
        end
        if (wallS and wallS:isWallN()) or not squareS:isFree(false) then
            ground.ymax = 0.9
        end
    end

    if squareE then
        local wallE = squareE:getWall()
        if wallE and wallE:isWallW() then
            cursorOrder = CURSOR_ORDER_E
        end
        if (wallE and wallE:isWallW()) or not squareE:isFree(false) then
            ground.xmax = 0.9
        end
    end

    if squareW then
        if not squareW:isFree(false) then
            ground.xmin = 0.1
        end
    end

    if squareN then
        if not squareN:isFree(false) then
            ground.ymin = 0.1
        end
    end

    local tileObjects = square:getLuaTileObjectList()
    local squareSurfaceOffset = 0
    local surfaces = {}
    local onRug = false
    for k, object in pairs(tileObjects) do
        local sprite = object:getSprite()
        if sprite then
            local surfaceOffsetNoTable = object:getSurfaceOffsetNoTable()
            if surfaceOffsetNoTable > squareSurfaceOffset then
                squareSurfaceOffset = surfaceOffsetNoTable
            end

            local surfaceOffset = object:getSurfaceOffset()
            if surfaceOffset > squareSurfaceOffset then
                squareSurfaceOffset = surfaceOffset
            end

            local surfaceZ = squareSurfaceOffset / 96

            local spriteName = sprite:getName()
            if spriteName and isRug(spriteName) then
                onRug = true
            end

            if IA.surfaces[spriteName] then
                -- a profile's own zmin is measured from the object's base, which is raised when it's stacked on
                -- another object (a crate on a crate)
                local baseZ = object:getRenderYOffset() / 96

                -- copy the surfaces so several objects on one square can be merged without changing the shared profiles
                for _, surface in ipairs(IA.surfaces[spriteName]) do
                    -- a counter's own facing wins over the walls around it
                    if surface.facing then
                        cursorOrder = FACING_CURSOR_ORDER[surface.facing] or cursorOrder
                    end

                    local copy = {}
                    for key, value in pairs(surface) do
                        copy[key] = value
                    end
                    if copy.zmin then
                        copy.zmin = copy.zmin + baseZ
                        if copy.zmax then
                            copy.zmax = copy.zmax + baseZ
                        end
                    else
                        copy.zmin = surfaceZ
                    end
                    tableInsert(surfaces, copy)
                end

                object:setOverlaySprite("")
            else
                ground.zmin = surfaceZ
                -- the game puts items on top of furniture as high as a floor, give them a floor of room above it
                if surfaceZ >= 1 then
                    ground.zmax = surfaceZ + 1
                end
            end
        end
    end

    -- only on the floor itself, furniture standing on the rug keeps its own height
    if onRug and ground.zmin == 0 then
        ground.zmin = RUG_LIFT
    end

    if #surfaces == 0 then
        tableInsert(surfaces, ground)
    end

    -- recognized objects with known surfaces
    local sourceSurfaces = surfaces

    -- Build per-square surfaces and compute vertical clearance against the next
    -- overlapping higher surface so items only fit if their dz fits the gap.
    local normalized = {}
    for i, src in ipairs(sourceSurfaces) do
        normalized[i] = {
            xmin = src.xmin or ground.xmin,
            xmax = src.xmax or ground.xmax,
            ymin = src.ymin or ground.ymin,
            ymax = src.ymax or ground.ymax,
            zmin = src.zmin or ground.zmin,
            zmax = src.zmax or ground.zmax,
        }
    end

    local clearancePad = 0.001
    for i, surface in ipairs(normalized) do
        local nearestAbove
        for j, other in ipairs(normalized) do
            if i ~= j and other.zmin > surface.zmin then
                local overlapX = (surface.xmin < other.xmax) and (other.xmin < surface.xmax)
                local overlapY = (surface.ymin < other.ymax) and (other.ymin < surface.ymax)
                if overlapX and overlapY then
                    if not nearestAbove or other.zmin < nearestAbove then
                        nearestAbove = other.zmin
                    end
                end
            end
        end

        if nearestAbove then
            local capped = nearestAbove - clearancePad
            if capped < surface.zmax then
                surface.zmax = capped
            end
        end

        -- tall furniture (stacked crates) has its top at a full floor, so cap the room at a floor above the surface
        if surface.zmax > surface.zmin + 1 then
            surface.zmax = surface.zmin + 1
        end
        if surface.zmax < surface.zmin then
            surface.zmax = surface.zmin
        end
    end

    surfaces = normalized
    return cursorOrder, surfaces

end

-- surfaces of two tiles of one piece of furniture merge when they're at the same height and both end within this
-- distance of the edge between the tiles
local MERGE_Z_TOLERANCE = 0.02
local MERGE_SEAM_TOLERANCE = 0.1

-- an item placed at exactly 0 or 1 lands on the neighboring square
local OFFSET_MIN = 0.001
local OFFSET_MAX = 0.999

---@class IAGroupMember
---@field square IsoGridSquare
---@field gx     integer position in the furniture's sprite grid
---@field gy     integer

---@class IAGroup
---@field square  IsoGridSquare the square that was asked for
---@field members IAGroupMember[]

local function hasSpriteNamed(square, name)
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local sprite = objects:get(i):getSprite()
        if sprite and sprite:getName() == name then
            return true
        end
    end

    return false
end

--- The squares of the multi-tile furniture with surfaces on `square` (both halves of a metal shelf), with `square` as
--- the only member when there's none. Squares can be missing from a grid when the furniture is broken up.
---@param square IsoGridSquare
---@return IAGroup
function IA.getArrangeGroup(square)
    local surfaceProfiles = IA.surfaces
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local sprite = objects:get(i):getSprite()
        local grid = sprite and sprite:getSpriteGrid()
        if grid and surfaceProfiles[sprite:getName()] then
            local cell = square:getCell()
            local z = square:getZ()
            local ax = square:getX() - grid:getSpriteGridPosX(sprite)
            local ay = square:getY() - grid:getSpriteGridPosY(sprite)
            local members = {}
            for gx = 0, grid:getWidth() - 1 do
                for gy = 0, grid:getHeight() - 1 do
                    local part = grid:getSprite(gx, gy)
                    local partSquare = part and cell:getGridSquare(ax + gx, ay + gy, z)
                    if partSquare and hasSpriteNamed(partSquare, part:getName()) then
                        tableInsert(members, { square = partSquare, gx = gx, gy = gy })
                    end
                end
            end

            if #members > 1 then
                return { square = square, members = members }
            end
        end
    end

    return { square = square, members = { { square = square, gx = 0, gy = 0 } } }
end

local function nearSeam(a, b)
    local seam = mathFloor(b + 0.5)
    return seam >= 1 and mathAbs(a - seam) <= MERGE_SEAM_TOLERANCE and mathAbs(b - seam) <= MERGE_SEAM_TOLERANCE
end

local function overlaps(amin, amax, bmin, bmax)
    return mathMax(amin, bmin) < mathMin(amax, bmax)
end

local function mergedSurface(a, b)
    if mathAbs(a.zmin - b.zmin) > MERGE_Z_TOLERANCE then
        return nil
    end

    local alongX = (nearSeam(a.xmax, b.xmin) or nearSeam(b.xmax, a.xmin)) and overlaps(a.ymin, a.ymax, b.ymin, b.ymax)
    local alongY = (nearSeam(a.ymax, b.ymin) or nearSeam(b.ymax, a.ymin)) and overlaps(a.xmin, a.xmax, b.xmin, b.xmax)
    if not alongX and not alongY then
        return nil
    end

    local merged = {
        zmin = mathMax(a.zmin, b.zmin),
        zmax = mathMin(a.zmax, b.zmax),
        rank = mathMin(a.rank, b.rank),
    }
    if alongX then
        merged.xmin, merged.xmax = mathMin(a.xmin, b.xmin), mathMax(a.xmax, b.xmax)
        merged.ymin, merged.ymax = mathMax(a.ymin, b.ymin), mathMin(a.ymax, b.ymax)
    else
        merged.xmin, merged.xmax = mathMax(a.xmin, b.xmin), mathMin(a.xmax, b.xmax)
        merged.ymin, merged.ymax = mathMin(a.ymin, b.ymin), mathMax(a.ymax, b.ymax)
    end
    if merged.zmax < merged.zmin then
        merged.zmax = merged.zmin
    end

    return merged
end

local function findMergePair(surfaces)
    for i = 1, #surfaces do
        for j = i + 1, #surfaces do
            local merged = mergedSurface(surfaces[i], surfaces[j])
            if merged then
                return i, j, merged
            end
        end
    end

    return nil
end

--- The cursor order and surfaces of a group, in the group's coordinates (the first member's square is 0..1). Touching
--- surfaces of different members are merged into one.
---@param group IAGroup
function IA.getGroupSurfaceInfo(group)
    local members = group.members
    if #members == 1 then
        return IA.getSurfaceInfo(members[1].square)
    end

    local cursorOrder
    local surfaces = {}
    for m = 1, #members do
        local member = members[m]
        local order, memberSurfaces = IA.getSurfaceInfo(member.square)
        if member.square == group.square or not cursorOrder then
            cursorOrder = order
        end

        for i = 1, #memberSurfaces do
            local s = memberSurfaces[i]
            tableInsert(surfaces, {
                xmin = s.xmin + member.gx,
                xmax = s.xmax + member.gx,
                ymin = s.ymin + member.gy,
                ymax = s.ymax + member.gy,
                zmin = s.zmin,
                zmax = s.zmax,
                rank = i,
            })
        end
    end

    local i, j, merged = findMergePair(surfaces)
    while i do
        surfaces[i] = merged
        tableRemove(surfaces, j)
        i, j, merged = findMergePair(surfaces)
    end

    -- keep the profile's order (insertion sort: a handful of surfaces, and table.sort overflows in Kahlua)
    for a = 2, #surfaces do
        local s = surfaces[a]
        local b = a - 1
        while b >= 1 and surfaces[b].rank > s.rank do
            surfaces[b + 1] = surfaces[b]
            b = b - 1
        end
        surfaces[b + 1] = s
    end

    return cursorOrder, surfaces
end

-- the member square under group coordinates `x, y`, and the offsets on it
local function locateInGroup(group, x, y)
    local gx, gy = mathFloor(x), mathFloor(y)
    local members = group.members
    for i = 1, #members do
        local member = members[i]
        if member.gx == gx and member.gy == gy then
            local ox = mathMax(OFFSET_MIN, mathMin(OFFSET_MAX, x - gx))
            local oy = mathMax(OFFSET_MIN, mathMin(OFFSET_MAX, y - gy))
            return member.square, ox, oy
        end
    end

    return nil
end

-- Moves an item's centre so all of its real length stays on the surface: long items get a shorter footprint
-- than they are, which would otherwise overhang the edge their row starts at. One longer than the whole surface
-- is centred on it.
local function keepOnSurface(center, length, low, high)
    if not length then
        return center
    end
    if length >= high - low then
        return (low + high) / 2
    end
    return mathMax(low + length / 2, mathMin(high - length / 2, center))
end

---@param group IAGroup
local function buildGroundList(group, extraItem)
    local arrangables = IA.arrangables
    local groundList = {}
    local members = group.members
    for m = 1, #members do
        local wobs = members[m].square:getWorldObjects()
        for i = 0, wobs:size() - 1 do
            local witem = wobs:get(i)
            local item = witem:getItem()
            local fType = item:getFullType()
            if arrangables[fType] then
                if not groundList[fType] then
                    groundList[fType] = {}
                end
                tableInsert(groundList[fType], { item = item, witem = witem })
            end
        end
    end

    if extraItem then
        local fType = extraItem:getFullType()
        if arrangables[fType] then
            if not groundList[fType] then
                groundList[fType] = {}
            end
            tableInsert(groundList[fType], { item = extraItem })
        end
    end

    return groundList
end

local ARRANGED_ORDERS = { CURSOR_ORDER_N, CURSOR_ORDER_W, CURSOR_ORDER_S, CURSOR_ORDER_E }

local CURSOR_FACING = { [CURSOR_ORDER_S] = "N", [CURSOR_ORDER_W] = "E", [CURSOR_ORDER_N] = "S", [CURSOR_ORDER_E] = "W" }

-- items that don't turn with the surface look the same in every order, so a fraction of a degree of extra z rotation
-- records the order they were arranged in
local ORDER_MARK = {
    [CURSOR_ORDER_N] = 0,
    [CURSOR_ORDER_W] = 0.2,
    [CURSOR_ORDER_S] = 0.4,
    [CURSOR_ORDER_E] = 0.6,
}

-- kahlua's `%` keeps the sign of negative numbers
local function sameAngle(a, b, tolerance)
    local d = (a - b) % 360
    if d < 0 then
        d = d + 360
    end
    return d < tolerance or d > 360 - tolerance
end

local function placedRotation(arr, order)
    if turnsWithSurface(arr) then
        return applyYaw(arr.fx or 0, arr.fy or 0, arr.fz or 0, CURSOR_YAW[order])
    end

    return arr.fx or 0, arr.fy or 0, ((arr.fz or 0) + ORDER_MARK[order]) % 360
end

-- The cursor order the square was last arranged with, read back from the items' synced rotations, or nil when it
-- isn't arranged. Dropped items get a random rotation, so at least half of the items must match one order.
local function arrangedCursorOrder(groundList)
    local arrangables = IA.arrangables
    local votes = {}
    local best, bestVotes = nil, 0
    local total = 0
    for fType, entries in pairs(groundList) do
        local arr = arrangables[fType]
        local tolerance = turnsWithSurface(arr) and 0.5 or 0.05
        local expected = nil
        for i = 1, #entries do
            local entry = entries[i]
            if entry.witem then
                total = total + 1
                if not expected then
                    expected = {}
                    for j = 1, #ARRANGED_ORDERS do
                        local fx, fy, fz = placedRotation(arr, ARRANGED_ORDERS[j])
                        expected[j] = { fx, fy, fz }
                    end
                end

                local item = entry.item
                local rx, ry, rz = item:getWorldXRotation(), item:getWorldYRotation(), item:getWorldZRotation()
                for j = 1, #ARRANGED_ORDERS do
                    local e = expected[j]
                    if sameAngle(e[1], rx, tolerance) and sameAngle(e[2], ry, tolerance)
                        and sameAngle(e[3], rz, tolerance) then
                        local order = ARRANGED_ORDERS[j]
                        local count = (votes[order] or 0) + 1
                        votes[order] = count
                        if count > bestVotes then
                            best, bestVotes = order, count
                        end
                        break
                    end
                end
            end
        end
    end

    if bestVotes * 2 < total then
        return nil
    end

    return best
end

--- The side the items on `square` face, or nil when they aren't arranged.
---@param square IsoGridSquare
---@return IAFacing | nil
function IA.getArrangedFacing(square)
    local order = arrangedCursorOrder(buildGroundList(IA.getArrangeGroup(square)))

    return order and CURSOR_FACING[order]
end

---@param group IAGroup
-- insertion sort: there are only a few types, and kahlua's table.sort overflows on sorted input
local function sortedKeys(map)
    local keys = {}
    for key in pairs(map) do
        local i = #keys
        while i > 0 and keys[i] > key do
            keys[i + 1] = keys[i]
            i = i - 1
        end
        keys[i + 1] = key
    end

    return keys
end

local function arrangeGroundList(group, groundList, placements, ignoreQz, facing)
    local arrangables = IA.arrangables
    local square = group.square

    local wallCursorOrder, surfaces = IA.getGroupSurfaceInfo(group)
    ---@type integer | nil
    local cursorOrder = FACING_CURSOR_ORDER[facing]
    if not cursorOrder and facing ~= "walls" then
        -- without a facing (rearranging after a pickup) the square keeps the orientation it was arranged with, and
        -- a square that isn't arranged stays as it is
        cursorOrder = arrangedCursorOrder(groundList)
        if not cursorOrder then
            if facing ~= "auto" then
                return true
            end
            cursorOrder = FACING_CURSOR_ORDER[facingOf(getPlayer(), square)]
        end
    end
    cursorOrder = cursorOrder or wallCursorOrder

    -- fill surfaces in the order the profile defines them, so the author decides which one is used first (a counter
    -- top before the floor below it). items that don't fit one still move on to the next
    local orderedSurfaceIndexes = {}
    for i = 1, #surfaces do
        orderedSurfaceIndexes[i] = i
    end

    -- surface cursor
    local cs = 1
    local exhaustedSurfaces = {}
    local surfaceCursorState = {}

    local surfaceInfo
    local xmin, xmax, ymin, ymax, zmin, zmax
    local cx, cy

    -- max stack dimensions per surface
    local dxmax = 0
    local dymax = 0

    local function saveCurrentSurfaceState()
        if not cs then
            return
        end

        if cx == nil or cy == nil then
            return
        end

        surfaceCursorState[cs] = {
            cx = cx,
            cy = cy,
            dxmax = dxmax,
            dymax = dymax,
        }
    end

    local function setSurface(index)
        local surfaceIndex = orderedSurfaceIndexes[index]
        local s = surfaceIndex and surfaces[surfaceIndex] or nil
        if not s then
            return false
        end

        saveCurrentSurfaceState()

        cs = index
        surfaceInfo = s

        xmin = surfaceInfo.xmin
        xmax = surfaceInfo.xmax
        ymin = surfaceInfo.ymin
        ymax = surfaceInfo.ymax
        zmin = surfaceInfo.zmin or 0
        zmax = surfaceInfo.zmax or 1
        if zmax > zmin + 1 then zmax = zmin + 1 end

        local state = surfaceCursorState[index]
        if state and state.cx ~= nil and state.cy ~= nil then
            cx = state.cx
            cy = state.cy
            dxmax = state.dxmax or 0
            dymax = state.dymax or 0
        else
            -- E and S use decrementing cursor, W and N use incrementing cursor
            cx = (cursorOrder == CURSOR_ORDER_E) and xmax or xmin
            cy = (cursorOrder == CURSOR_ORDER_S) and ymax or ymin
            dxmax = 0
            dymax = 0
        end

        return true
    end

    local function canSurfaceFitItem(index, dx, dy, dz, mz)
        local surfaceIndex = orderedSurfaceIndexes[index]
        local s = surfaceIndex and surfaces[surfaceIndex] or nil
        if not s then
            return false
        end

        local sxmin = s.xmin
        local sxmax = s.xmax
        local symin = s.ymin
        local symax = s.ymax
        local szmin = s.zmin or 0
        local szmax = s.zmax or 1
        if szmax > szmin + 1 then
            szmax = szmin + 1
        end

        local hasFootprintRoom = (sxmin + dx) <= sxmax and (symin + dy) <= symax
        if not hasFootprintRoom then
            return false
        end

        return (szmin + (mz or 0) + dz) <= szmax
    end

    local function selectLowestFittingSurface(dx, dy, dz, mz, skipIndex)
        for index = 1, #orderedSurfaceIndexes do
            if index ~= skipIndex and not exhaustedSurfaces[index] and canSurfaceFitItem(index, dx, dy, dz, mz) then
                return index
            end
        end
        return nil
    end

    local function switchSurfaceByFit(dx, dy, dz, mz, exhaustCurrent)
        local shouldExhaust = (exhaustCurrent ~= false)
        local previous = cs

        if shouldExhaust and previous then
            exhaustedSurfaces[cs] = true
        end

        local nextSurface = selectLowestFittingSurface(dx, dy, dz, mz, previous)
        if not nextSurface and not shouldExhaust then
            -- Fallback: if this was a temporary guard switch, allow staying put.
            nextSurface = selectLowestFittingSurface(dx, dy, dz, mz)
        end

        if not nextSurface then
            return false
        end

        return setSurface(nextSurface)
    end

    local function switchSurfaceByGuard(dx, dy, dz, mz, guardState)
        -- Guard switches should not permanently exhaust a surface on first miss,
        -- but must still terminate if we keep bouncing across candidates.
        if not guardState then
            return switchSurfaceByFit(dx, dy, dz, mz, false)
        end

        guardState.attempts = (guardState.attempts or 0) + 1

        if guardState.attempts <= #orderedSurfaceIndexes then
            return switchSurfaceByFit(dx, dy, dz, mz, false)
        end

        guardState.attempts = 0
        return switchSurfaceByFit(dx, dy, dz, mz, true)
    end

    -- S and E rows grow from the max edge towards the min edge, so their far edge is pos - size
    local function isOutOfBounds(xpos, ypos, dx, dy)
        return (cursorOrder == CURSOR_ORDER_N and ypos + dy > ymax)
            or (cursorOrder == CURSOR_ORDER_W and xpos + dx > xmax)
            or (cursorOrder == CURSOR_ORDER_S and ypos - dy < ymin)
            or (cursorOrder == CURSOR_ORDER_E and xpos - dx < xmin)
    end

    -- Starts a new row when this item doesn't fit in what's left of the current one, judged by this item's own
    -- size (not the previous type's), and grows the row depth to fit it. An item wider than the whole surface
    -- stays at the start of its row.
    local function fitRow(dx, dy)
        if cursorOrder == CURSOR_ORDER_W or cursorOrder == CURSOR_ORDER_E then
            if cy + dy > ymax and cy > ymin then
                cy = ymin
                if cursorOrder == CURSOR_ORDER_E then
                    cx = cx - dymax
                else
                    cx = cx + dymax
                end
                dymax = 0
            end
            if dx > dymax then
                dymax = dx
            end
        else
            if cx + dx > xmax and cx > xmin then
                cx = xmin
                if cursorOrder == CURSOR_ORDER_S then
                    cy = cy - dxmax
                else
                    cy = cy + dxmax
                end
                dxmax = 0
            end
            if dy > dxmax then
                dxmax = dy
            end
        end
    end

    local placedBoundsBySurface = {}

    local function getAnchorBounds(xpos, ypos, zpos, dx, dy, dz)
        local x1, x2, y1, y2
        if cursorOrder == CURSOR_ORDER_S then
            x1 = xpos
            x2 = xpos + dx
            y1 = ypos - dy
            y2 = ypos
        elseif cursorOrder == CURSOR_ORDER_E then
            x1 = xpos - dx
            x2 = xpos
            y1 = ypos
            y2 = ypos + dy
        else
            x1 = xpos
            x2 = xpos + dx
            y1 = ypos
            y2 = ypos + dy
        end

        return {
            x1 = x1,
            x2 = x2,
            y1 = y1,
            y2 = y2,
            z1 = zpos,
            z2 = zpos + dz,
        }
    end

    local function boundsOverlap(a, b)
        -- Use a tiny epsilon so numerically-adjacent bounds (touching faces)
        -- are not treated as collisions due to floating-point noise.
        local eps = 0.0005
        local overlapX = ((a.x1 + eps) < b.x2) and ((b.x1 + eps) < a.x2)
        local overlapY = ((a.y1 + eps) < b.y2) and ((b.y1 + eps) < a.y2)
        local overlapZ = ((a.z1 + eps) < b.z2) and ((b.z1 + eps) < a.z2)
        return overlapX and overlapY and overlapZ
    end

    local function isPositionOccupied(surfaceIndex, xpos, ypos, zpos, dx, dy, dz)
        local bounds = getAnchorBounds(xpos, ypos, zpos, dx, dy, dz)
        local placed = placedBoundsBySurface[surfaceIndex]
        if not placed then
            return false
        end

        for _, existing in ipairs(placed) do
            if boundsOverlap(bounds, existing) then
                return true
            end
        end

        return false
    end

    local function registerPlacedBounds(surfaceIndex, xpos, ypos, zpos, dx, dy, dz)
        if not placedBoundsBySurface[surfaceIndex] then
            placedBoundsBySurface[surfaceIndex] = {}
        end
        tableInsert(placedBoundsBySurface[surfaceIndex], getAnchorBounds(xpos, ypos, zpos, dx, dy, dz))
    end

    -- pairs order follows the order the types were added in, which changes when items move between the squares of a
    -- group, so a rearrange would lay out a different arrangement every time
    local types = sortedKeys(groundList)
    local totalTypes = #types

    local processedTypes = 0
    for t = 1, totalTypes do
        local fType = types[t]
        local witems = groundList[fType]
        local arr = arrangables[fType]

        -- item dimensions
        local dx = arr.dx
        local dy = arr.dy
        local dz = arr.dz

        -- item minimal z offset (used if had to be rotated)
        local mz = arr.mz or 0
        local mx = arr.mx or 0
        local my = arr.my or 0

        -- real length of items longer than their footprint
        local lx = arr.lx
        local ly = arr.ly

        -- profiles are defined with their back to N: swap the footprint for side orders and map the
        -- offset so my stays "towards the back" and mx "along it"
        if cursorOrder == CURSOR_ORDER_W or cursorOrder == CURSOR_ORDER_E then
            dx, dy = dy, dx
            lx, ly = ly, lx
        end

        if cursorOrder == CURSOR_ORDER_S then
            mx, my = -mx, -my
        elseif cursorOrder == CURSOR_ORDER_W then
            mx, my = my, -mx
        elseif cursorOrder == CURSOR_ORDER_E then
            mx, my = -my, mx
        end

        -- max item number on a single stack
        local qz = ignoreQz and 1 or (arr.qz or 3)

        -- Surface exhaustion is item-size specific. Reset per type, then pick the
        -- smallest fitting band for this type instead of inheriting prior type.
        exhaustedSurfaces = {}
        local firstSurface = selectLowestFittingSurface(dx, dy, dz, mz)
        if not firstSurface or not setSurface(firstSurface) then
            print ("ItemArranger: no fitting surface found for item type " .. tostring(fType))
            return false
        end

        -- the cursor was left where the previous type ended, which may not fit this type
        fitRow(dx, dy)

        local z = 0
        for i, entry in ipairs(witems) do
            local zpos = zmin + mz + (z * dz)
            local xpos = cx
            local ypos = cy

            while (zpos + dz) > zmax or z >= qz do
                z = 0

                -- If the first item in a stack cannot fit this z band, skip to next surface.
                local cannotFitSurface = (zmin + mz + dz) > zmax
                if cannotFitSurface then
                    if not switchSurfaceByFit(dx, dy, dz, mz) then
                        print ("ItemArranger: ran out of space to arrange items on surface (" .. cs .. "), cursorOrder:" .. cursorOrder .. ", xpos: " .. xpos .. ", ypos: " .. ypos .. ", zpos: " .. zpos .. ", dx: " .. dx .. ", dy: " .. dy .. " xmax: " .. xmax .. ", ymax: " .. ymax)
                        return false
                    end

                    zpos = zmin + mz + (z * dz)
                    xpos = cx
                    ypos = cy
                else
                    if cursorOrder == CURSOR_ORDER_W or cursorOrder == CURSOR_ORDER_E then
                        cy = cy + dy
                    else
                        cx = cx + dx
                    end
                    zpos = zmin + mz + (z * dz)
                    if cursorOrder == CURSOR_ORDER_W then
                        if cy + dy > ymax then
                            cy = ymin
                            cx = cx + dymax
                            dymax = dx
                        end
                    elseif cursorOrder == CURSOR_ORDER_E then
                        if cy + dy > ymax then
                            cy = ymin
                            cx = cx - dymax
                            dymax = dx
                        end
                    else
                        if cx + dx > xmax then
                            cx = xmin
                            if cursorOrder == CURSOR_ORDER_S then
                                cy = cy - dxmax
                            else
                                cy = cy + dxmax
                            end
                            dxmax = dy
                        end
                    end

                    xpos = cx
                    ypos = cy
                    if isOutOfBounds(xpos, ypos, dx, dy) then
                        if not switchSurfaceByFit(dx, dy, dz, mz) then
                            print ("ItemArranger: ran out of space to arrange items on this surface (1), cursorOrder:" .. cursorOrder .. ", xpos: " .. xpos .. ", ypos: " .. ypos .. ", zpos: " .. zpos .. ", dx: " .. dx .. ", dy: " .. dy .. " xmax: " .. xmax .. ", ymax: " .. ymax)
                            return false
                        end

                        zpos = zmin + mz + (z * dz)
                        xpos = cx
                        ypos = cy
                    end
                end
            end

            -- Restored cursor state can be stale for the current item dimensions.
            -- Re-validate XY bounds before placing this item.
            local xyGuardState = { attempts = 0 }
            while isOutOfBounds(xpos, ypos, dx, dy) do
                z = 0
                if not switchSurfaceByGuard(dx, dy, dz, mz, xyGuardState) then
                    print ("ItemArranger: ran out of space to arrange items on this surface (xy-guard), cursorOrder:" .. cursorOrder .. ", xpos: " .. xpos .. ", ypos: " .. ypos .. ", zpos: " .. zpos .. ", dx: " .. dx .. ", dy: " .. dy .. " xmax: " .. xmax .. ", ymax: " .. ymax)
                    return false
                end

                fitRow(dx, dy)
                zpos = zmin + mz + (z * dz)
                xpos = cx
                ypos = cy
            end

            while isPositionOccupied(cs, xpos, ypos, zpos, dx, dy, dz) do
                z = 0
                if cursorOrder == CURSOR_ORDER_W or cursorOrder == CURSOR_ORDER_E then
                    cy = cy + dy
                else
                    cx = cx + dx
                end

                zpos = zmin + mz + (z * dz)
                if cursorOrder == CURSOR_ORDER_W then
                    if cy + dy > ymax then
                        cy = ymin
                        cx = cx + dymax
                        dymax = dx
                    end
                elseif cursorOrder == CURSOR_ORDER_E then
                    if cy + dy > ymax then
                        cy = ymin
                        cx = cx - dymax
                        dymax = dx
                    end
                else
                    if cx + dx > xmax then
                        cx = xmin
                        if cursorOrder == CURSOR_ORDER_S then
                            cy = cy - dxmax
                        else
                            cy = cy + dxmax
                        end
                        dxmax = dy
                    end
                end

                zpos = zmin + mz + (z * dz)
                xpos = cx
                ypos = cy

                if isOutOfBounds(xpos, ypos, dx, dy) then
                    if not switchSurfaceByFit(dx, dy, dz, mz) then
                        print ("ItemArranger: ran out of space to arrange items on this surface (collision-guard), cursorOrder:" .. cursorOrder .. ", xpos: " .. xpos .. ", ypos: " .. ypos .. ", zpos: " .. zpos .. ", dx: " .. dx .. ", dy: " .. dy .. " xmax: " .. xmax .. ", ymax: " .. ymax)
                        return false
                    end

                    zpos = zmin + mz + (z * dz)
                    xpos = cx
                    ypos = cy
                end

                local xyAfterCollisionGuardState = { attempts = 0 }
                while isOutOfBounds(xpos, ypos, dx, dy) do
                    z = 0
                    if not switchSurfaceByGuard(dx, dy, dz, mz, xyAfterCollisionGuardState) then
                        print ("ItemArranger: ran out of space to arrange items on this surface (xy-after-collision), cursorOrder:" .. cursorOrder .. ", xpos: " .. xpos .. ", ypos: " .. ypos .. ", zpos: " .. zpos .. ", dx: " .. dx .. ", dy: " .. dy .. " xmax: " .. xmax .. ", ymax: " .. ymax)
                        return false
                    end

                    zpos = zmin + mz + (z * dz)
                    xpos = cx
                    ypos = cy
                end
            end

            local anchorX = xpos
            local anchorY = ypos

            if cursorOrder == CURSOR_ORDER_N then
                xpos = xpos + (dx / 2) + mx
                ypos = ypos + (dy / 2) + my
            elseif cursorOrder == CURSOR_ORDER_S then
                xpos = xpos + (dx / 2) + mx
                ypos = ypos - (dy / 2) + my
            elseif cursorOrder == CURSOR_ORDER_E then
                xpos = xpos - (dx / 2) + mx
                ypos = ypos + (dy / 2) + my
            elseif cursorOrder == CURSOR_ORDER_W then
                xpos = xpos + (dx / 2) + mx
                ypos = ypos + (dy / 2) + my
            end

            xpos = keepOnSurface(xpos - mx, lx, xmin, xmax) + mx
            ypos = keepOnSurface(ypos - my, ly, ymin, ymax) + my

            if placements and entry.witem then
                tableInsert(placements, {
                    entry = entry,
                    arr = arr,
                    order = cursorOrder,
                    x = xpos,
                    y = ypos,
                    z = zpos + SURFACE_CLEARANCE,
                })
            end

            registerPlacedBounds(cs, anchorX, anchorY, zpos, dx, dy, dz)
            z = z + 1
        end

        processedTypes = processedTypes + 1

        -- Move to the next stack slot only if another item type is pending. Whether that slot still fits is up to
        -- the next type (fitRow and the bounds guards), since it depends on that type's size, not this one's.
        if processedTypes < totalTypes then
            if cursorOrder == CURSOR_ORDER_W or cursorOrder == CURSOR_ORDER_E then
                cy = cy + dy
            else
                cx = cx + dx
            end
        end
    end

    return true
end

---@param facing? IAArrangeFacing side the items face. without one an arranged square keeps its orientation and any
---other square is left alone
function IA.CheckSpace(square, item, skip, facing)
    if not square or not item then
        return false, false
    end

    local fType = item:getFullType()
    local arr = IA.arrangables[fType]
    if not arr then
        return true, skip
    end

    local group = IA.getArrangeGroup(square)
    local groundList = buildGroundList(group)
    local sameTypeItems = groundList[fType]
    if sameTypeItems and #sameTypeItems > 0 then
        local qz = arr.qz or 3
        local currentStackSize = #sameTypeItems % qz
        if currentStackSize ~= 0 then
            local _, surfaces = IA.getGroupSurfaceInfo(group)
            local mz = arr.mz or 0
            for _, surfaceInfo in ipairs(surfaces) do
                local zmin = surfaceInfo.zmin or 0
                local zmax = surfaceInfo.zmax or 1
                if zmax > zmin + 1 then zmax = zmin + 1 end

                local nextZ = zmin + mz + (currentStackSize * arr.dz)
                if (nextZ + arr.dz) <= zmax then
                    return true, false
                end
            end
        end
    end

    return arrangeGroundList(group, buildGroundList(group, item), nil, false, facing), false
end

local function isSameSquare(a, b)
    return a and a:getX() == b:getX() and a:getY() == b:getY() and a:getZ() == b:getZ()
end

-- the item becomes a new world object on `target`, keeping its rotation
local function moveWorldItem(witem, item, target, x, y, z)
    local source = witem:getSquare()
    if source then
        source:transmitRemoveItemFromSquare(witem)
    end
    witem:removeFromWorld()
    witem:removeFromSquare()
    witem:setSquare(nil)
    item:setWorldItem(nil)

    target:AddWorldInventoryItem(item, x, y, z)

    return item:getWorldItem()
end

local function isNear(a, b)
    local d = a - b
    return d < OFFSET_EPSILON and d > -OFFSET_EPSILON
end

-- whether the entry's world item already sits where the placement puts it
local function isInPlace(entry, p)
    local target = p.target
    return (not target or entry.sq == target) and isNear(entry.ox, p.ox) and isNear(entry.oy, p.oy)
        and isNear(entry.oz, p.z)
end

-- Items of one type are interchangeable, but the arrangement hands their slots out in world-object order, which
-- changes whenever an item moves between the squares of a group. Giving each slot back to the item that already
-- fills it keeps a rearrange from shuffling (and resyncing) identical items.
---@param group IAGroup
local function resolvePlacements(placements, group)
    local single = #group.members == 1
    local byType = {}
    local types = {}
    for i = 1, #placements do
        local p = placements[i]
        if not single then
            p.target, p.ox, p.oy = locateInGroup(group, p.x, p.y)
        end
        if not p.target then
            p.ox, p.oy = p.x, p.y
        end

        local entry = p.entry
        local witem = entry.witem
        entry.sq = witem:getSquare()
        entry.ox, entry.oy, entry.oz = witem:getOffX(), witem:getOffY(), witem:getOffZ()

        local fType = entry.item:getFullType()
        local bucket = byType[fType]
        if not bucket then
            bucket = {}
            byType[fType] = bucket
            types[#types + 1] = fType
        end
        bucket[#bucket + 1] = p
    end

    for t = 1, #types do
        local bucket = byType[types[t]]
        local count = #bucket
        if count > 1 then
            local entries, claimed, assigned = {}, {}, {}
            for i = 1, count do
                entries[i] = bucket[i].entry
            end

            for i = 1, count do
                local p = bucket[i]
                for j = 1, count do
                    if not claimed[j] and isInPlace(entries[j], p) then
                        claimed[j] = true
                        assigned[i] = entries[j]
                        break
                    end
                end
            end

            local free = 1
            for i = 1, count do
                if not assigned[i] then
                    while claimed[free] do
                        free = free + 1
                    end
                    claimed[free] = true
                    assigned[i] = entries[free]
                end
                bucket[i].entry = assigned[i]
            end
        end
    end
end

---@param group IAGroup
local function applyPlacements(placements, group)
    resolvePlacements(placements, group)

    for i = 1, #placements do
        local p = placements[i]
        local entry, arr = p.entry, p.arr
        local item = entry.item
        local witem = entry.witem

        local fx, fy, fz = placedRotation(arr, p.order)
        local changed = not (sameAngle(item:getWorldXRotation(), fx, ANGLE_EPSILON)
            and sameAngle(item:getWorldYRotation(), fy, ANGLE_EPSILON)
            and sameAngle(item:getWorldZRotation(), fz, ANGLE_EPSILON))
        if changed then
            item:setWorldXRotation(fx)
            item:setWorldYRotation(fy)
            item:setWorldZRotation(fz)
        end

        local target = p.target
        if not target or isSameSquare(entry.sq, target) then
            if not isInPlace(entry, p) then
                witem:setOffset(p.ox, p.oy, p.z)
                changed = true
            end
        else
            witem = moveWorldItem(witem, item, target, p.ox, p.oy, p.z)
            changed = true
        end

        item:setDoingExtendedPlacement(false)
        -- each sync is one reliable packet per nearby player, so unchanged items are skipped
        if witem and changed then
            witem:syncExtendedPlacement()
        end
    end
end

---@param facing? IAArrangeFacing side the items face. without one an arranged square keeps its orientation and any
---other square is left alone
function IA.ArrangeItems(square, simulate, ctrlKey, facing)
    local group = IA.getArrangeGroup(square)
    if simulate then
        return arrangeGroundList(group, buildGroundList(group), nil, ctrlKey, facing)
    end

    local placements = {}
    local ok = arrangeGroundList(group, buildGroundList(group), placements, ctrlKey, facing)
    applyPlacements(placements, group)

    return ok
end
