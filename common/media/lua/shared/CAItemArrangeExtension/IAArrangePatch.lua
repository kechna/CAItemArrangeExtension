require("IAArrange")

local IA = IA or nil

if not IA or not IA.getSurfaceInfo or not IA.CheckSpace or not IA.ArrangeItems then return end

local pairs = pairs
local ipairs = ipairs
local print = print
local tostring = tostring
local stringFormat = string.format
local isServer = isServer
local isClient = isClient
local getCell = getCell
local getTimestampMs = getTimestampMs
local sendClientCommand = sendClientCommand
local Events = Events
local type = type
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
--  - optionally stack different items that share a mesh and profile together (mod option)
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

-- every piece of multi-tile furniture is a `Base.Moveable` that the game draws with the `Flatpack` model when it sets
-- this modData flag; single-tile moveables share the type but have no model, so they can't be arranged
local FLATPACK_TYPE = "Base.Moveable@Flatpack"

---@param item InventoryItem
---@return string type the arrange profile is looked up by
function IA.getArrangeType(item)
    if item:getModData().Flatpack == "true" then
        return FLATPACK_TYPE
    end

    return item:getFullType()
end

local getArrangeType = IA.getArrangeType

-- placements closer than this to the current ones aren't synced again
local OFFSET_EPSILON = 0.0005
-- FBORenderChunk.DIRTY_REDRAW, what `setOffset` invalidates
local RENDER_DIRTY = 256
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

-- an item's world rotation as a matrix (model space has y up, so fz turns it around the vertical)
local function mat3Item(fx, fy, fz)
    return mat3Mul(mat3RotX(fx), mat3Mul(mat3RotY(fz), mat3RotZ(fy)))
end

local function itemRotationOf(m)
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

local function applyYaw(fx, fy, fz, yaw)
    if yaw == 0 or fx == 0 then
        return fx, fy, (fz + yaw) % 360
    end

    return itemRotationOf(mat3Mul(mat3RotY(yaw), mat3Item(fx, fy, fz)))
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
---@param merge? boolean false arranges the square on its own, the player's mod option by default (on for a server)
---@return IAGroup
function IA.getArrangeGroup(square, merge)
    if merge == nil then
        merge = IA.MergeSurfaces ~= false
    end
    if not merge then
        return { square = square, members = { { square = square, gx = 0, gy = 0 } } }
    end

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

-- wall boards (cork boards, pegboards): items hang flat against the board in rows from its top, copies shingled a bit
-- further out and lower. they're packed by `arrangeGroundList` on a virtual surface (x along the board, y down from
-- its top, z out of it) and turned onto the wall afterwards.

local EMPTY = {}

-- items count as flat when their height is at most this part of their longest side
local FLAT_RATIO = 0.3
local WALL_MAX_STACK = 3
-- how far each copy in a stack hangs lower than the one under it, as a part of its height on the board
local SHINGLE_DROP = 0.2
local WALL_EPSILON = 0.02
local WALL_ANGLE_TOLERANCE = 1
-- a z level is this many tile widths tall: heights (`dz`, `mz`, offsets) are in levels, the board's x and y in tiles
local FLOOR_HEIGHT = 2.449

-- the item lies flat against the board with its top facing out and its front (south on the floor) down
local WALL_PITCH = -90
local WALL_YAW = { N = 0, W = 90 }

---@param arr IAArrangableProfile | nil
---@return boolean
local function canHang(arr)
    if not arr then
        return false
    end
    if arr.w ~= nil then
        return arr.w
    end

    local long = arr.dx > arr.dy and arr.dx or arr.dy

    return arr.dz <= long * FLAT_RATIO
end

-- turned so the long side runs along the board
local function rollsOnWall(arr)
    return arr.dy > arr.dx
end

local function wallRotation(arr, wall)
    local m = mat3Item(arr.fx or 0, arr.fy or 0, arr.fz or 0)
    if rollsOnWall(arr) then
        m = mat3Mul(mat3RotY(90), m)
    end
    m = mat3Mul(mat3RotY(WALL_YAW[wall] or 0), mat3Mul(mat3RotX(WALL_PITCH), m))

    return itemRotationOf(m)
end

-- kahlua's `%` keeps the sign of negative numbers
local function sameAngle(a, b, tolerance)
    local d = (a - b) % 360
    if d < 0 then
        d = d + 360
    end
    return d < tolerance or d > 360 - tolerance
end

local function wallSurfaces()
    return IA.wallSurfaces or EMPTY
end

---@param square IsoGridSquare
---@return string[] | nil sprite names of the square's wall boards
local function getWallSprites(square)
    local profiles = wallSurfaces()
    local result
    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local sprite = objects:get(i):getSprite()
        local name = sprite and sprite:getName()
        if name and profiles[name] then
            result = result or {}
            result[#result + 1] = name
        end
    end

    return result
end

-- matched by position and rotation instead of modData, so items dropped below a board never count. hung items sit
-- `plane` further along and `plane / 3` higher than the spot they cover (see `toWallPlacement`), hence the margins
---@param sprites string[] the boards on the item's square
local function isOnWall(witem, arr, sprites, profiles)
    local ox, oy, oz = witem:getOffX(), witem:getOffY(), witem:getOffZ()
    for i = 1, #sprites do
        local s = profiles[sprites[i]]
        local along, out = ox, oy
        if s.wall == "W" then
            along, out = oy, ox
        end

        local height = oz - s.plane / 3
        if along >= s.min - WALL_EPSILON and along <= s.max + s.plane + WALL_EPSILON
            and out >= s.plane - WALL_EPSILON and out <= s.plane + s.depth + WALL_EPSILON
            and height >= s.zmin - WALL_EPSILON and height <= s.zmax + WALL_EPSILON then
            local item = witem:getItem()
            local fx, fy, fz = wallRotation(arr, s.wall)
            if sameAngle(item:getWorldXRotation(), fx, WALL_ANGLE_TOLERANCE)
                and sameAngle(item:getWorldYRotation(), fy, WALL_ANGLE_TOLERANCE)
                and sameAngle(item:getWorldZRotation(), fz, WALL_ANGLE_TOLERANCE) then
                return true
            end
        end
    end

    return false
end

-- whether the arrangement running now lets items that share a mesh and profile share stacks
local mixing = false

local stackKeyCache = {}
local stackProfiles = {}

local function num(v)
    return v and stringFormat("%.3f", v) or "-"
end

-- full types, or with mixing on the mesh plus every profile field that affects packing and rendering, so only items of
-- the same size and rotation share a stack
local function stackKeyOf(fType, arr)
    if not mixing then
        return fType
    end

    local cached = stackKeyCache[fType]
    if cached and cached.arr == arr then
        return cached.key
    end

    local meshOf = IA.meshOf
    local mesh = meshOf and meshOf[fType]
    local key = fType
    if mesh then
        key = stringFormat("%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s|%s", mesh, num(arr.dx), num(arr.dy), num(arr.dz),
            num(arr.mx), num(arr.my), num(arr.mz), num(arr.fx), num(arr.fy), num(arr.fz), num(arr.qz), num(arr.lx),
            num(arr.ly), tostring(arr.w), tostring(arr.yaw))
        stackProfiles[key] = arr
    end

    stackKeyCache[fType] = { arr = arr, key = key }

    return key
end

-- the profile of a ground list key
local function profileOf(key)
    return IA.arrangables[key] or stackProfiles[key]
end

---@param mixed? boolean the player's mod option by default, off on a server
local function setMixing(mixed)
    if mixed == nil then
        mixed = not isServer() and IA.MixedStacks == true
    end
    mixing = mixed == true
end

-- equal items next to each other in a mixed stack. insertion sort, kahlua's table.sort overflows on sorted input
local function sortByType(entries)
    for i = 2, #entries do
        local entry = entries[i]
        local fType = entry.fType
        local j = i - 1
        while j > 0 and entries[j].fType > fType do
            entries[j + 1] = entries[j]
            j = j - 1
        end
        entries[j + 1] = entry
    end
end

--- The items of a group by stack key (see `stackKeyOf`), without the ones hanging on wall boards. For a `wallGroup` only the ones hanging on
--- its board, plus `newItem`.
---@param group      IAGroup
---@param extraItem? InventoryItem an item that isn't on the square yet
---@param wallGroup? boolean
---@param newItem?   InventoryItem just dropped on the square to go on the board
local function buildGroundList(group, extraItem, wallGroup, newItem)
    local arrangables = IA.arrangables
    local profiles = wallSurfaces()
    local groundList = {}
    local members = group.members
    for m = 1, #members do
        local member = members[m]
        local square = member.square
        local wobs = square:getWorldObjects()
        local wobCount = wobs:size()
        local sprites
        if wallGroup then
            sprites = { member.sprite }
        elseif wobCount > 0 then
            sprites = getWallSprites(square)
        end

        for i = 0, wobCount - 1 do
            local witem = wobs:get(i)
            local item = witem:getItem()
            local fType = getArrangeType(item)
            local arr = arrangables[fType]
            local include = arr ~= nil
            if include and wallGroup then
                include = item == newItem or isOnWall(witem, arr, sprites, profiles)
            elseif include and sprites then
                include = not isOnWall(witem, arr, sprites, profiles)
            end

            if include then
                local key = stackKeyOf(fType, arr)
                if not groundList[key] then
                    groundList[key] = {}
                end
                tableInsert(groundList[key], { item = item, witem = witem, fType = fType })
            end
        end
    end

    if extraItem then
        local fType = getArrangeType(extraItem)
        local arr = arrangables[fType]
        if arr then
            local key = stackKeyOf(fType, arr)
            if not groundList[key] then
                groundList[key] = {}
            end
            tableInsert(groundList[key], { item = extraItem, fType = fType })
        end
    end

    if mixing then
        for key, entries in pairs(groundList) do
            if key ~= entries[1].fType then
                sortByType(entries)
            end
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

local function placedRotation(arr, order)
    if turnsWithSurface(arr) then
        return applyYaw(arr.fx or 0, arr.fy or 0, arr.fz or 0, CURSOR_YAW[order])
    end

    return arr.fx or 0, arr.fy or 0, ((arr.fz or 0) + ORDER_MARK[order]) % 360
end

-- The cursor order the square was last arranged with, read back from the items' synced rotations, or nil when it
-- isn't arranged. Dropped items get a random rotation, so at least half of the items must match one order.
local function arrangedCursorOrder(groundList)
    local votes = {}
    local best, bestVotes = nil, 0
    local total = 0
    for key, entries in pairs(groundList) do
        local arr = profileOf(key)
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
---@param merge? boolean
---@return IAFacing | nil
function IA.getArrangedFacing(square, merge)
    local order = arrangedCursorOrder(buildGroundList(IA.getArrangeGroup(square, merge)))

    return order and CURSOR_FACING[order]
end

local function placesBefore(a, b, arrangables)
    local pa, pb = arrangables[a], arrangables[b]
    local areaA, areaB = pa.dx * pa.dy, pb.dx * pb.dy
    if areaA ~= areaB then
        return areaA > areaB
    end

    if pa.dz ~= pb.dz then
        return pa.dz > pb.dz
    end

    return a < b
end

-- largest footprint first packs fuller surfaces than the order types were added in, which also changes when items
-- move between the squares of a group. insertion sort: there are only a few types, and kahlua's table.sort overflows
-- on sorted input
local function sortTypesForPacking(groundList, arrangables)
    local types = {}
    for fType in pairs(groundList) do
        local i = #types
        while i > 0 and placesBefore(fType, types[i], arrangables) do
            types[i + 1] = types[i]
            i = i - 1
        end
        types[i + 1] = fType
    end

    return types
end

---@class IAArrangeLayout
---@field order       integer cursor order
---@field surfaces    table[]
---@field arrangables table<string, IAArrangableProfile>

---@param group   IAGroup
---@param layout? IAArrangeLayout packs on these surfaces with these profiles instead of the group's
local function arrangeGroundList(group, groundList, placements, ignoreQz, facing, layout)
    local arrangables = layout and layout.arrangables
    if not arrangables then
        arrangables = {}
        for key in pairs(groundList) do
            arrangables[key] = profileOf(key)
        end
    end
    local square = group.square

    local wallCursorOrder, surfaces
    if layout then
        wallCursorOrder, surfaces = layout.order, layout.surfaces
    else
        wallCursorOrder, surfaces = IA.getGroupSurfaceInfo(group)
    end
    ---@type integer | nil
    local cursorOrder = FACING_CURSOR_ORDER[facing]
    if layout then
        cursorOrder = layout.order
    elseif not cursorOrder and facing ~= "walls" then
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

    local types = sortTypesForPacking(groundList, arrangables)
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
                    layer = z,
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

-- defined further down, after the placements they apply
local arrangeWall

---@param facing?     IAArrangeFacing side the items face. without one an arranged square keeps its orientation and any
---other square is left alone
---@param wallSprite? string check the wall board on the square instead, for items that can hang
---@param mixed?      boolean see `IA.ArrangeItems`
function IA.CheckSpace(square, item, skip, facing, wallSprite, mixed, merge)
    if not square or not item then
        return false, false
    end

    local fType = getArrangeType(item)
    local arr = IA.arrangables[fType]
    if not arr then
        return true, skip
    end

    setMixing(mixed)

    -- items that can't hang are skipped like misfits, not dropped on the floor under the board
    if wallSprite then
        return canHang(arr) and arrangeWall(square, wallSprite, true, false, item) or false, false
    end

    local group = IA.getArrangeGroup(square, merge)
    local groundList = buildGroundList(group)
    local sameTypeItems = groundList[stackKeyOf(fType, arr)]
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

-- the item becomes a new world object on `target`. clients get it once, complete with its placement: a sync sent
-- after the add is unordered and can arrive before the object. `unsent` items never reached the clients
local function moveWorldItem(witem, item, target, x, y, z, fx, fy, unsent)
    local source = witem:getSquare()
    if source and not unsent then
        source:transmitRemoveItemFromSquare(witem)
    end
    witem:removeFromWorld()
    witem:removeFromSquare()
    witem:setSquare(nil)
    item:setWorldItem(nil)

    target:AddWorldInventoryItem(item, x, y, z, false)
    -- a new world object resets the item's x and y rotation
    item:setWorldXRotation(fx)
    item:setWorldYRotation(fy)

    local moved = item:getWorldItem()
    if moved and not unsent and isServer() then
        moved:transmitCompleteItemToClients()
    end

    return moved
end

-- `setOffset` would send a SyncIsoObject, which finds the object by its index on the square and carries the fluid
-- container, so on a client whose list differs it lands on another item
local function setOffsets(witem, x, y, z)
    witem:setOffX(x)
    witem:setOffY(y)
    witem:setOffZ(z)
    if not isServer() then
        witem:invalidateRenderChunkLevel(RENDER_DIRTY)
    end
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

        local fType = getArrangeType(entry.item)
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
---@param unsent? InventoryItem dropped item the clients don't have yet, sent by the caller afterwards
local function applyPlacements(placements, group, unsent)
    resolvePlacements(placements, group)

    for i = 1, #placements do
        local p = placements[i]
        local entry, arr = p.entry, p.arr
        local item = entry.item
        local witem = entry.witem

        local fx, fy, fz
        if p.rotation then
            fx, fy, fz = p.rotation[1], p.rotation[2], p.rotation[3]
        else
            fx, fy, fz = placedRotation(arr, p.order)
        end
        local changed = not (sameAngle(item:getWorldXRotation(), fx, ANGLE_EPSILON)
            and sameAngle(item:getWorldYRotation(), fy, ANGLE_EPSILON)
            and sameAngle(item:getWorldZRotation(), fz, ANGLE_EPSILON))
        if changed then
            item:setWorldXRotation(fx)
            item:setWorldYRotation(fy)
            item:setWorldZRotation(fz)
        end

        local isUnsent = item == unsent
        local target = p.target
        local moved = false
        if not target or isSameSquare(entry.sq, target) then
            if not isInPlace(entry, p) then
                setOffsets(witem, p.ox, p.oy, p.z)
                changed = true
            end
        else
            witem = moveWorldItem(witem, item, target, p.ox, p.oy, p.z, fx, fy, isUnsent)
            moved = true
        end

        item:setDoingExtendedPlacement(false)
        -- each sync is one reliable packet per nearby player, so unchanged items are skipped
        if witem and changed and not moved and not isUnsent then
            witem:syncExtendedPlacement()
        end
    end
end

---@class IAWallGroupMember: IAGroupMember
---@field sprite string

--- The squares of the wall board `spriteName` on `square` (both halves of a pegboard), or nil when it isn't there.
---@param square     IsoGridSquare
---@param spriteName string
---@return IAGroup | nil
local function getWallGroup(square, spriteName)
    local profiles = wallSurfaces()
    if not profiles[spriteName] then
        return nil
    end

    local objects = square:getObjects()
    for i = 0, objects:size() - 1 do
        local sprite = objects:get(i):getSprite()
        if sprite and sprite:getName() == spriteName then
            local grid = sprite:getSpriteGrid()
            local members = {}
            if grid then
                local cell = square:getCell()
                local z = square:getZ()
                local ax = square:getX() - grid:getSpriteGridPosX(sprite)
                local ay = square:getY() - grid:getSpriteGridPosY(sprite)
                for gx = 0, grid:getWidth() - 1 do
                    for gy = 0, grid:getHeight() - 1 do
                        local part = grid:getSprite(gx, gy)
                        local partName = part and part:getName()
                        local partSquare = partName and profiles[partName] and cell:getGridSquare(ax + gx, ay + gy, z)
                        if partSquare and hasSpriteNamed(partSquare, partName) then
                            tableInsert(members, { square = partSquare, gx = gx, gy = gy, sprite = partName })
                        end
                    end
                end
            end

            if #members < 2 then
                members = { { square = square, gx = 0, gy = 0, sprite = spriteName } }
            end

            return { square = square, members = members }
        end
    end

    return nil
end

-- the board of a wall group in group coordinates, its tiles joined along the wall
local function getWallSurface(group)
    local profiles = wallSurfaces()
    local result
    local members = group.members
    for m = 1, #members do
        local member = members[m]
        local s = profiles[member.sprite]
        local along, across = member.gx, member.gy
        if s.wall == "W" then
            along, across = member.gy, member.gx
        end

        if not result then
            result = {
                wall = s.wall,
                plane = s.plane + across,
                shift = s.plane,
                min = s.min + along,
                max = s.max + along,
                zmin = s.zmin,
                zmax = s.zmax,
                depth = s.depth,
            }
        else
            result.min = mathMin(result.min, s.min + along)
            result.max = mathMax(result.max, s.max + along)
            result.zmin = mathMax(result.zmin, s.zmin)
            result.zmax = mathMin(result.zmax, s.zmax)
            result.depth = mathMin(result.depth, s.depth)
        end
    end

    return result
end

-- the profiles items are packed with on a board's virtual surface: x along the board (their long side), y down from
-- its top (their short side, plus the shingle of a stack), z out of the board, all in tile widths
local function getWallProfiles(groundList, ignoreQz)
    local result = {}
    for fType in pairs(groundList) do
        local arr = profileOf(fType)
        local roll = rollsOnWall(arr)
        local along = roll and arr.dy or arr.dx
        local down = roll and arr.dx or arr.dy
        local qz = ignoreQz and 1 or mathMin(arr.qz or 3, WALL_MAX_STACK)
        local drop = down * SHINGLE_DROP
        result[fType] = {
            dx = along,
            dy = down + (qz - 1) * drop,
            dz = arr.dz * FLOOR_HEIGHT,
            qz = qz,
            lx = roll and arr.ly or arr.lx,
            item = arr,
            down = down,
            drop = drop,
        }
    end

    return result
end

-- turns a placement on a board's virtual surface into one on the board. items render where their position projects, so
-- one hanging `p` in front of the wall moves +p along it and +p/3 up to cover the same spot on the drawn board
local function toWallPlacement(p, surface)
    local virtual = p.arr
    local arr = virtual.item
    local top = p.y - virtual.dy / 2
    local along = p.x
    local height = surface.zmax - (top + virtual.down / 2 + p.layer * virtual.drop) / FLOOR_HEIGHT
    local out = surface.plane + p.z + (arr.mz or 0) * FLOOR_HEIGHT

    local mx, my = arr.mx or 0, arr.my or 0
    if rollsOnWall(arr) then
        mx, my = my, -mx
    end
    along = along + mx + surface.shift
    height = height - my / FLOOR_HEIGHT + surface.shift / 3

    if surface.wall == "W" then
        p.x, p.y = out, along
    else
        p.x, p.y = along, out
    end
    p.z = height
    p.arr = arr
    p.rotation = { wallRotation(arr, surface.wall) }
end

-- arranges the items on the wall board `spriteName` on `square`. `extraItem` is checked as if it were dropped there
-- too, `newItem` was just dropped on the square to go on the board
function arrangeWall(square, spriteName, simulate, ignoreQz, extraItem, newItem, unsent)
    local group = getWallGroup(square, spriteName)
    if not group then
        return false
    end

    local surface = getWallSurface(group)
    local groundList = buildGroundList(group, extraItem, true, newItem)
    for fType in pairs(groundList) do
        if not canHang(profileOf(fType)) then
            groundList[fType] = nil
        end
    end

    local layout = {
        order = CURSOR_ORDER_N,
        surfaces = {
            {
                xmin = surface.min,
                xmax = surface.max,
                ymin = 0,
                ymax = (surface.zmax - surface.zmin) * FLOOR_HEIGHT,
                zmin = 0,
                zmax = surface.depth,
            },
        },
        arrangables = getWallProfiles(groundList, ignoreQz),
    }

    local placements = not simulate and {} or nil
    local ok = arrangeGroundList(group, groundList, placements, ignoreQz, nil, layout)
    if placements then
        for i = 1, #placements do
            toWallPlacement(placements[i], surface)
        end
        applyPlacements(placements, group, unsent and newItem or nil)
    end

    return ok
end

-- rearranges every wall board on the squares of `group`, once per board
local function arrangeWalls(group)
    local done = {}
    local members = group.members
    for m = 1, #members do
        local square = members[m].square
        local sprites = getWallSprites(square)
        if sprites then
            for i = 1, #sprites do
                local wallGroup = getWallGroup(square, sprites[i])
                local first = wallGroup and wallGroup.members[1]
                local key = first and (first.square:getX() .. "," .. first.square:getY() .. "," .. first.sprite)
                if key and not done[key] then
                    done[key] = true
                    arrangeWall(square, sprites[i], false, false)
                end
            end
        end
    end
end

CAIAE_State = CAIAE_State or { hooks = {}, pending = {}, pendingCount = 0 }
local State = CAIAE_State

local COMMAND_MODULE = "CAIAE"
local REQUEST_DELAY_MS = 250
local MAX_REQUEST_DISTANCE = 12
local VALID_FACING = { N = true, E = true, S = true, W = true, auto = true }

local function registerHook(event, hook)
    if State.hooks[event] then
        Events[event].Remove(State.hooks[event])
    end
    Events[event].Add(hook)
    State.hooks[event] = hook
end

-- a client never moves world items itself: they'd only move in its own object list, which then disagrees with the
-- server's for good, so later pickups by index take the wrong items. pickups re-sort a square several times in a
-- row, so the requests wait a moment and only the last one per square is sent
local function requestArrange(square, ctrlKey, facing, wallSprite, mixed, merge)
    local x, y, z = square:getX(), square:getY(), square:getZ()
    local key = x .. "," .. y .. "," .. z .. "," .. tostring(wallSprite)
    if not State.pending[key] then
        State.pendingCount = State.pendingCount + 1
    end
    State.pending[key] = {
        due = getTimestampMs() + REQUEST_DELAY_MS,
        args = { x = x, y = y, z = z, ctrl = ctrlKey == true, facing = facing, wall = wallSprite, mixed = mixed,
            merge = merge },
    }
end

local function sendPendingRequests()
    if State.pendingCount == 0 then return end

    local now = getTimestampMs()
    for key, request in pairs(State.pending) do
        if request.due <= now then
            State.pending[key] = nil
            State.pendingCount = State.pendingCount - 1
            sendClientCommand(COMMAND_MODULE, "Arrange", request.args)
        end
    end
end

local function onClientCommand(module, command, player, args)
    if module ~= COMMAND_MODULE or command ~= "Arrange" or type(args) ~= "table" or not player then return end

    local x, y, z = args.x, args.y, args.z
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then return end
    if mathAbs(player:getX() - x) > MAX_REQUEST_DISTANCE or mathAbs(player:getY() - y) > MAX_REQUEST_DISTANCE
        or mathAbs(player:getZ() - z) > 2 then
        return
    end

    local facing = args.facing
    if facing ~= nil and not VALID_FACING[facing] then return end
    local wall = args.wall
    if wall ~= nil and type(wall) ~= "string" then return end

    local square = getCell():getGridSquare(x, y, z)
    if not square then return end

    IA.ArrangeItems(square, false, args.ctrl == true, facing, wall, nil, args.mixed == true, nil, args.merge ~= false)
end

if isServer() then
    registerHook("OnClientCommand", onClientCommand)
elseif isClient() then
    registerHook("OnTick", sendPendingRequests)
end

---@param facing?     IAArrangeFacing side the items face. without one an arranged square keeps its orientation and any
---other square is left alone
---@param wallSprite? string arrange the items on this wall board on the square instead
---@param newItem?    InventoryItem the item just dropped on the square, which goes on the wall board when it can hang
---@param mixed?      boolean stack items that share a mesh and profile together, the player's mod option by default
---@param unsent?     boolean `newItem` isn't on the clients yet: the caller sends it once it's placed
---@param merge?      boolean arrange multi-tile furniture as one surface, the player's mod option by default
function IA.ArrangeItems(square, simulate, ctrlKey, facing, wallSprite, newItem, mixed, unsent, merge)
    if not simulate and isClient() then
        if mixed == nil then
            mixed = IA.MixedStacks
        end
        if merge == nil then
            merge = IA.MergeSurfaces ~= false
        end
        requestArrange(square, ctrlKey, facing, wallSprite, mixed, merge)

        return true
    end

    setMixing(mixed)
    if wallSprite and (not newItem or canHang(IA.arrangables[getArrangeType(newItem)])) then
        return arrangeWall(square, wallSprite, simulate, ctrlKey, nil, newItem, unsent)
    end

    local group = IA.getArrangeGroup(square, merge)
    if simulate then
        return arrangeGroundList(group, buildGroundList(group), nil, ctrlKey, facing)
    end

    local placements = {}
    local ok = arrangeGroundList(group, buildGroundList(group), placements, ctrlKey, facing)
    applyPlacements(placements, group, unsent and newItem or nil)

    -- after a pickup the boards close their gaps too
    if not wallSprite then
        arrangeWalls(group)
    end

    return ok
end
