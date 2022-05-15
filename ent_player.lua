require("ent_sprite")

PHYS_UPDATE_FREQ = 1/120
local SPEED_MAX = 800
local SIDE_ACCEL = 5000
local GRAV_ACCEL = 3000
local FLIP_DELAY = 0.15
local DEATH_TIMEOUT = 1

local COLOR_ALIVE = {0.2, 0.2, 1, 1}
local COLOR_DEATH = {1, 0.2, 0.2, 1}

local TEXTURE_PATH_PLAYER = "res/player.png"

Player = Sprite:new()

function Player:new(o)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    o.timer = 0
    o.physTimer = 0
    o.flipTimer = 0
    o.deathTimer = 0

    o.pos = {x = 0, y = 0}
    o.vel = {x = 0, y = 0}
    o.respawnDest = {x = 400, y = 500, sx = 1, sy = 1, reset = true}
    o.teleportDest = o.respawnDest -- nil if shouldn't get teleported

    -- Controls
    o.moveDir = 0 -- -1 left, +1 right
    o.gravFlip = false -- false means fall down
    o.facingSide = false -- false means left

    o.isOnGround = false
    o.isDead = false

    return o
end

function Player.preload()
    Player:loadTexture(TEXTURE_PATH_PLAYER)
end

function Player.free()
    Player.texture = nil
end

function Player:updateNormal(dt)
    -- Gravity flipping
    self.spriteFlipY = not self.gravFlip

    -- Movement
    self.moveDir = 0
    if love.keyboard.isDown("a") ~= love.keyboard.isDown("d") then
        self.moveDir = love.keyboard.isDown("a") and -1 or 1
    end

    -- Horizontal flipping
    if self.moveDir ~= 0 then
        self.spriteFlipX = self.moveDir ~= 1
    end
end

function Player:updateDeath(dt)
    if self.isDead then
        if self.deathTimer > DEATH_TIMEOUT then
            self:teleport(self.respawnDest)
            self.isDead = false
        end
    end
end

function Player:update(dt)
    Sprite.update(self)

    self.timer = self.timer + dt
    self.physTimer = self.physTimer + dt
    self.flipTimer = self.flipTimer + dt
    self.deathTimer = self.deathTimer + dt

    if not self.isDead then
        self.spriteColor = COLOR_ALIVE
        self:updateNormal(dt)
    else
        self.spriteColor = COLOR_DEATH
        self:updateDeath(dt)
    end

    self.spritePosX = self.pos.x
    self.spritePosY = self.pos.y
end

local function clampVal(x, min, max)
    if x < min then
        return min
    elseif  x > max then
        return max
    else
        return x
    end
end

local function colTestNarrow(r1, r2, dPos)
    local xDistStart, xDistEnd, yDistStart, yDistEnd
    local xTimeStart, xTimeEnd, yTimeStart, yTimeEnd

    -- X axis
    if dPos.x == 0 then
        if r1.x < r2.x + r2.w and r2.x < r1.x + r1.w then
            xDistStart = -math.huge
            xDistEnd = math.huge
        else
            return false
        end
    else
        if dPos.x > 0 then
            xDistStart = r2.x - (r1.x + r1.w)
            xDistEnd = r2.x + r2.w - r1.x
        else
            xDistStart = r1.x - (r2.x + r2.w)
            xDistEnd = r1.x + r1.w - r2.x
        end
    end

    -- Y axis
    if dPos.y == 0 then
        if r1.y < r2.y + r2.h and r2.y < r1.y + r1.h then
            yDistStart = -math.huge
            yDistEnd = math.huge
        else
            return false
        end
    else
        if dPos.y > 0 then
            yDistStart = r2.y - (r1.y + r1.h)
            yDistEnd = r2.y + r2.h - r1.y
        else
            yDistStart = r1.y - (r2.y + r2.h)
            yDistEnd = r1.y + r1.h - r2.y
        end
    end

    -- Both
    xTimeStart = xDistStart / math.abs(dPos.x)
    xTimeEnd = xDistEnd / math.abs(dPos.x)

    yTimeStart = yDistStart/ math.abs(dPos.y)
    yTimeEnd = yDistEnd / math.abs(dPos.y)

    if xTimeStart > yTimeEnd or yTimeStart > xTimeEnd then return false end

    local timeStart = math.max(xTimeStart, yTimeStart)
    if timeStart < 0 or timeStart > 1 then return false end

    local vNormal = {x = 0, y = 0}

    if xTimeStart > yTimeStart then
        vNormal.x = dPos.x > 0 and -1 or 1
    else
        vNormal.y = dPos.y > 0 and -1 or 1
    end

    return true, timeStart, vNormal
end

-- TODO: This is ugly and may cause problems in the future
local function isTileBlocking(tile)
    local TILE_RET = {
        ['0'] = false,
        ['1'] = true,
        ['2'] = false,
    }

    return TILE_RET[tile] or false
end

local function isTileEmpty(tilemap, tx, ty, normVec)
    local tdatx = tilemap.dat[tx + normVec.x]
    if tdatx == nil then return false end

    local tdat = tdatx[ty + normVec.y]
    --return tdat == "0" or tdat == nil
    return not isTileBlocking(tdat)
end

-- Collision detection broad phase
function Player:genColTileBounds(dPos)
    local xStart, yStart = self.pos.x, self.pos.y
    local xEnd, yEnd = xStart + dPos.x, yStart + dPos.y
    local xMin, xMax = math.min(xStart, xEnd), math.max(xStart, xEnd) + self.spriteSizeW
    local yMin, yMax = math.min(yStart, yEnd), math.max(yStart, yEnd) + self.spriteSizeH
    local tileW, tileH = 800/TILESCREEN_W, 600/TILESCREEN_H

    local txMin, txMax = math.max(1, math.floor(xMin / tileW)), math.min(math.ceil(xMax / tileW), TILESCREEN_W)
    local tyMin, tyMax = math.max(1, math.floor(yMin / tileH)), math.min(math.ceil(yMax / tileH), TILESCREEN_H)

    return {x1 = txMin, x2 = txMax, y1 = tyMin, y2 = tyMax}
end

function Player:testCollisionSweep(tilemap, dPos)
    local plyRect = {x = self.pos.x, y = self.pos.y, w = self.spriteSizeW, h = self.spriteSizeH}

    local tileW, tileH = 800/TILESCREEN_W, 600/TILESCREEN_H
    local tilerect = {x = 0, y = 0, w = tileW, h = tileH}
    local tBounds = self:genColTileBounds(dPos)

    local allHits = {}

    for tx = tBounds.x1, tBounds.x2 do
        for ty = tBounds.y1, tBounds.y2 do
            tilerect.x = (tx-1)*tileW
            tilerect.y = (ty-1)*tileH

            local didHit, whenHit, normVec = colTestNarrow(plyRect, tilerect, dPos)
            if didHit and tilemap.dat[tx][ty] ~= "0" and isTileEmpty(tilemap, tx, ty, normVec) then
                local hitObj = {
                    isHorz = (normVec.x ~= 0),
                    time = whenHit,
                    tile = {x = tx, y = ty},
                    doesBlock = isTileBlocking(tilemap.dat[tx][ty])
                }

                table.insert(allHits, hitObj)
            end
        end
    end

    table.sort(allHits, function(a, b) return a.time < b.time end) -- Sort by hit time

    return allHits 
end

function Player:reactToColSlide(dPos, tFinal, isVert, tile)
    if isVert then
        self.vel.y = 0
    else
        self.vel.x = 0
    end

    local newPos = {x = self.pos.x + dPos.x * tFinal, y = self.pos.y + dPos.y * tFinal}
    self.pos = newPos

end

function Player:reactToColIgnore(dPos, tFinal, isVert, tile)
    local newPos = {x = self.pos.x + dPos.x * tFinal, y = self.pos.y + dPos.y * tFinal}
    self.pos = newPos
end

function Player:reactToColKill(dPos, tFinal, isVert, tile)
    self:kill()
    self:reactToColIgnore(dPos, tFinal, isVert, tile)
end

function Player:reactToColBounce(dPos, tFinal, isVert, tile)
    if isVert then
        self.vel.y = -self.vel.y
        self.gravFlip = not self.gravFlip
    else
        self.vel.x = -self.vel.x
    end
    
    local newPos = {x = self.pos.x + dPos.x * tFinal, y = self.pos.y + dPos.y * tFinal}
    self.pos = newPos
end

function Player:reactToCol(tilemap, dPos, tFinal, isVert, tilePos)
    local TILE_HANDLERS = {
        ['1'] = self.reactToColSlide,
        ['2'] = self.reactToColKill,
    }

    local tile = tilemap.dat[tilePos.x][tilePos.y] 

    local handler = TILE_HANDLERS[tile]
    if handler ~= nil then 
        handler(self, dPos, tFinal, isVert, tile)
    else
        self:reactToColIgnore(dPos, tFinal, isVert, tile)
    end
end

function Player:runColTests(tilemap, dPos)
    if dPos.x == 0 and dPos.y == 0 then return 1 end

    local hitList = self:testCollisionSweep(tilemap, dPos)

    local tHorz, tVert = nil, nil
    local hitTile = {nil, nil}

    local elapsed = 0

    for _,v in ipairs(hitList) do
        if tHorz ~= nil and tVert ~= nil then break end

        if tHorz == nil and tVert == nil and not v.doesBlock then
            self:reactToCol(tilemap, dPos, v.time - elapsed, (not v.isHorz), v.tile)
            elapsed = v.time
        end
        
        if v.doesBlock then
            if v.isHorz and tHorz == nil then
                tHorz = v.time
                hitTile[1] = v.tile
            end

            if not v.isHorz and tVert == nil then
                tVert = v.time
                hitTile[2] = v.tile
            end
        end
    end

    tHorz = tHorz or 2
    tVert = tVert or 2
    
    local tFinal = math.min(tHorz, tVert, 1)
    
    local neglDiff = PHYS_UPDATE_FREQ*2 -- Neglectibly small difference, TODO: Revise later

    if tVert < tHorz + neglDiff and tVert < 1 then
        self:reactToCol(tilemap, dPos, tFinal - elapsed, true, hitTile[2])
    end

    if tHorz < tVert + neglDiff and tHorz < 1 then
        self:reactToCol(tilemap, dPos, tFinal - elapsed, false, hitTile[1])
    end

    if tFinal >= 1 then self:reactToColIgnore(dPos, tFinal, false, '0') end

    return tFinal 
end

function Player:updatePhys(tilemap)
    -- Don't update pos if dead
    if self.isDead then return end

    local gravDir = self.gravFlip and 1 or -1
    self.vel.x = self.vel.x + PHYS_UPDATE_FREQ * self.moveDir * SIDE_ACCEL
    self.vel.y = self.vel.y + PHYS_UPDATE_FREQ * gravDir * GRAV_ACCEL

    -- Brake when not moving
    if self.moveDir == 0 then
        if self.vel.x > 0 then
            self.vel.x = math.max(0, self.vel.x - SIDE_ACCEL * PHYS_UPDATE_FREQ)
        else
            self.vel.x = math.min(0, self.vel.x + SIDE_ACCEL * PHYS_UPDATE_FREQ)
        end
    end

    local tTotal = 1
    while tTotal > 0 do
        self.vel.x = clampVal(self.vel.x, -SPEED_MAX, SPEED_MAX)
        self.vel.y = clampVal(self.vel.y, -SPEED_MAX, SPEED_MAX)

        local dPos = {
            x = self.vel.x * PHYS_UPDATE_FREQ * tTotal,
            y = self.vel.y * PHYS_UPDATE_FREQ * tTotal
        }

        local tSingle = self:runColTests(tilemap, dPos)
        tTotal = tTotal - tTotal * tSingle
    end
end

function Player:testOnGround(tilemap)
    local function isHitlistBlocking(l)
        for _,v in ipairs(l) do
            if v.doesBlock then return true end
        end

        return false
    end

    local testTopList = self:testCollisionSweep(tilemap, {x = 0, y = 3})
    local testBottomList = self:testCollisionSweep(tilemap, {x = 0, y = -3})

    self.isOnGround = isHitlistBlocking(testTopList) or isHitlistBlocking(testBottomList)
end

function Player:doFlip()
    if self.isOnGround and self.flipTimer > FLIP_DELAY and not self.isDead then
        self.gravFlip = not self.gravFlip
        self.vel.y = 0
        self.flipTimer = 0
    end
end

function Player:kill()
    self.isDead = true
    self.deathTimer = 0 
end

function Player:teleport(dst)
    self.teleportDest = dst
end
