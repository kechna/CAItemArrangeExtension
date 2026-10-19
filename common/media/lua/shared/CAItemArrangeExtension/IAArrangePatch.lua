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
local mathMax = math.max
local mathMin = math.min
local mathRad = math.rad
local mathSin = math.sin
local tableInsert = table.insert
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

local RUG_LIFT = 0.006

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

local function buildGroundList(square, extraItem)
    local arrangables = IA.arrangables
    local groundList = {}
    local wobs = square:getWorldObjects()
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

-- kahlua's `%` keeps the sign of negative numbers
local function sameAngle(a, b)
    local d = (a - b) % 360
    if d < 0 then
        d = d + 360
    end
    return d < 0.5 or d > 359.5
end

-- The cursor order the square was last arranged with, read back from the items' synced rotations: each one is its
-- profile's rotation turned by that order's yaw. Most votes wins, so loose items with random rotations don't decide.
local function arrangedCursorOrder(groundList)
    local arrangables = IA.arrangables
    local votes = {}
    local best, bestVotes = nil, 0
    for fType, entries in pairs(groundList) do
        local arr = arrangables[fType]
        local ax, ay, az = arr.fx or 0, arr.fy or 0, arr.fz or 0
        for i = 1, #entries do
            local entry = entries[i]
            if entry.witem then
                local item = entry.item
                local rx, ry, rz = item:getWorldXRotation(), item:getWorldYRotation(), item:getWorldZRotation()
                for j = 1, #ARRANGED_ORDERS do
                    local order = ARRANGED_ORDERS[j]
                    local fx, fy, fz = applyYaw(ax, ay, az, CURSOR_YAW[order])
                    if sameAngle(fx, rx) and sameAngle(fy, ry) and sameAngle(fz, rz) then
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

    return best
end

local function arrangeGroundList(square, groundList, placements, ignoreQz, facing)
    local arrangables = IA.arrangables

    local wallCursorOrder, surfaces = IA.getSurfaceInfo(square)
    local cursorOrder = FACING_CURSOR_ORDER[facing]
    if not cursorOrder and facing ~= "walls" then
        -- without a facing (rearranging after a pickup) the square keeps the orientation it was arranged with
        cursorOrder = arrangedCursorOrder(groundList) or FACING_CURSOR_ORDER[facingOf(getPlayer(), square)]
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

    local totalTypes = 0
    for _ in pairs(groundList) do
        totalTypes = totalTypes + 1
    end

    local processedTypes = 0
    for fType, witems in pairs(groundList) do
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
                    yaw = CURSOR_YAW[cursorOrder],
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

---@param facing? IAFacing side the items face. without one the square keeps its last orientation
function IA.CheckSpace(square, item, skip, facing)
    if not square or not item then
        return false, false
    end

    local fType = item:getFullType()
    local arr = IA.arrangables[fType]
    if not arr then
        return true, skip
    end

    local groundList = buildGroundList(square)
    local sameTypeItems = groundList[fType]
    if sameTypeItems and #sameTypeItems > 0 then
        local qz = arr.qz or 3
        local currentStackSize = #sameTypeItems % qz
        if currentStackSize ~= 0 then
            local _, surfaces = IA.getSurfaceInfo(square)
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

    return arrangeGroundList(square, buildGroundList(square, item), nil, false, facing), false
end

local function applyPlacements(placements)
    for i = 1, #placements do
        local p = placements[i]
        local entry, arr = p.entry, p.arr
        entry.witem:setOffset(p.x, p.y, p.z)

        local item = entry.item
        local fx, fy, fz = applyYaw(arr.fx or 0, arr.fy or 0, arr.fz or 0, p.yaw)
        item:setWorldXRotation(fx)
        item:setWorldYRotation(fy)
        item:setWorldZRotation(fz)

        item:setDoingExtendedPlacement(false)
        entry.witem:syncExtendedPlacement()
    end
end

---@param facing? IAFacing side the items face. without one the square keeps its last orientation
function IA.ArrangeItems(square, simulate, ctrlKey, facing)
    if simulate then
        return arrangeGroundList(square, buildGroundList(square), nil, ctrlKey, facing)
    end

    local placements = {}
    local ok = arrangeGroundList(square, buildGroundList(square), placements, ctrlKey, facing)
    applyPlacements(placements)

    return ok
end
