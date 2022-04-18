require("sprite")

-- TODO: Make AABB collision detection here not so awful

PHYS_UPDATE_FREQ = 1/240
local SPEED_MAX = 750
local SIDE_ACCEL = 4000
local GRAV_ACCEL = 3000
local TEXTURE_PATH_PLAYER = "res/player.png"

Player = Sprite:new()

function Player:new(o)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    o.timer = 0
    o.physTimer = 0

    o.pos = {x = 0, y = 0}
    o.vel = {x = 0, y = 0}

    -- Controls
    o.moveDir = 0 -- -1 left, +1 right
    o.gravFlip = false -- false means fall down
    o.facingSide = false -- false means left

    o.isOnGround = false

    return o
end

function Player.preload()
    Player:loadTexture(TEXTURE_PATH_PLAYER)
end

function Player.free()
    Player.texture = nil
end

function Player:update(dt)
    Sprite.update(self)

    self.timer = self.timer + dt
    self.physTimer = self.physTimer + dt

    -- Gravity flipping
    self.spriteFlipY = self.gravFlip

    -- Movement
    self.moveDir = 0
    if love.keyboard.isDown("a") ~= love.keyboard.isDown("d") then
        self.moveDir = love.keyboard.isDown("a") and -1 or 1
    end

    -- Horizontal flipping
    if self.moveDir ~= 0 then
        self.spriteFlipX = self.moveDir ~= 1
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

    if xTimeStart >= yTimeStart then
        vNormal.x = dPos.x > 0 and -1 or 1
    else
        vNormal.y = dPos.y > 0 and -1 or 1
    end

    return true, timeStart, vNormal
end

local function isTileEmpty(tilemap, tx, ty, normVec)
    -- just some special cases
    local tdatx = tilemap.dat[tx + normVec.x]
    if tdatx == nil then return false end

    local tdat = tdatx[ty + normVec.y]
    return tdat == "0" or tdat == nil
end

function Player:testCollisionSweep(tilemap, dPos)
    local plyRect = {x = self.pos.x, y = self.pos.y, w = self.spriteSizeW, h = self.spriteSizeH}

    -- TODO: Write proper broad phase
    local tileW, tileH = 800/TILESCREEN_W, 600/TILESCREEN_H
    local tilerect = {x = 0, y = 0, w = tileW, h = tileH}

    local finHitTime = {1, 1}
    local finNormal = {x = 0, y = 0}

    for tx=1,TILESCREEN_W do
        for ty=1,TILESCREEN_H do
            tilerect.x = (tx-1)*tileW
            tilerect.y = (ty-1)*tileH

            local didHit, whenHit, normVec = colTestNarrow(plyRect, tilerect, dPos)
            if didHit and tilemap.dat[tx][ty] ~= "0" and isTileEmpty(tilemap, tx, ty, normVec) then -- second option should normally be handled by broad phase
                local hType = (normVec.x ~= 0) and 1 or 2
                finHitTime[hType] = math.min(finHitTime[hType], whenHit)
            end
        end
    end

    return finHitTime, finNormal
end

function Player:reactToCol(dPos, tHorz, tVert)
    local tFinal = math.min(tHorz, tVert)
    local newPos = {x = self.pos.x + dPos.x * tFinal, y = self.pos.y + dPos.y * tFinal}

    if tVert < 1 then
        newPos.y = self.pos.y
        self.vel.y = 0
        self.isOnGround = true
    else
        self.isOnGround = false

    end

    if tHorz < 1 then
        newPos.x = self.pos.x
        self.vel.x = 0
    end

    self.pos = newPos
end

function Player:runColTests(tilemap, dPos)
    if dPos.x == 0 and dPos.y == 0 then return 1 end

    local hitTime = self:testCollisionSweep(tilemap, dPos)
    self:reactToCol(dPos, hitTime[1], hitTime[2])

    return math.min(hitTime[1], hitTime[2], 1)
end

function Player:updatePhys(tilemap)
    -- Idea: Maybe zero out velocity when player tries to move to the opposite of current velocity

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

    local LEFT_TIME_MIN = 0.001
    local tTotal = 1

    while tTotal > LEFT_TIME_MIN do
        self.vel.x = clampVal(self.vel.x, -SPEED_MAX, SPEED_MAX)
        self.vel.y = clampVal(self.vel.y, -SPEED_MAX, SPEED_MAX)

        local dPos = {
            x = self.vel.x * PHYS_UPDATE_FREQ * tTotal,
            y = self.vel.y * PHYS_UPDATE_FREQ * tTotal
        }

        local tSingle = self:runColTests(tilemap, dPos)
        tTotal = tTotal - tTotal * tSingle * 1.05
    end
end

function Player:doFlip()
    if self.isOnGround then
        self.gravFlip = not self.gravFlip
        self.vel.y = 0
    end
end
