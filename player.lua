require("sprite")

-- TODO: Make AABB collision detection here not awful

local SPEED_MAX = 750
local SIDE_ACCEL = 4000
local GRAV_ACCEL = 3000

PHYS_UPDATE_FREQ = 1/120
local TEXTURE_PATH_PLAYER = "res/player.png"

Player = Sprite:new({
    timer = 0,
    physTimer = 0,

    pos = {x = 0, y = 0},
    vel = {x = 0, y = 0},
    size = {w = 0, y = 0},

    -- Controls
    moveDir = 0, -- -1 left, +1 right
    gravFlip = false, -- false means fall down
    facingSide = false, -- false means left
})

function Player:new(o)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    local tw, th = Player.texture:getDimensions()
    o.size = {w = tw, h = th}

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
    self.facingSide = self.moveDir == 1
    self.spriteFlipX = not self.facingSide

    self.screenPos.x = self.pos.x
    self.screenPos.y = self.pos.y
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

-- TODO: write this
-- Returns true if obj should stop, false if should pass through
function Player:reactCol(tiletype)
    --if tiletype == "0" then
    --    return false
    --end

    return true
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

    local firstHitX = false
    if xTimeStart > yTimeStart then firstHitX = true end

    return true, timeStart, firstHitX
end

function Player:runColTests(tilemap, dPos)
    local plyRect = {x = self.pos.x, y = self.pos.y, w = self.size.w, h = self.size.h}

    -- TODO: Write proper broad phase
    local tileW, tileH = 800/TILESCREEN_W, 600/TILESCREEN_H
    local tilerect = {x = 0, y = 0, w = tileW, h = tileH}

    local finHitTime = {2, 2}

    for tx=1,TILESCREEN_W do
        for ty=1,TILESCREEN_H do
            tilerect.x = (tx-1)*tileW
            tilerect.y = (ty-1)*tileH

            local didHit, whenHit, didHitX = colTestNarrow(plyRect, tilerect, dPos)
            if didHit and tilemap.dat[tx][ty] ~= "0" then -- second option should normally be handled by broad phase
                if self:reactCol(tilemap.dat[tx][ty]) then
                    local hType = didHitX and 1 or 2
                    finHitTime[hType] = math.min(finHitTime[hType], whenHit)
                end
            end
        end
    end

    local travTime = math.min(finHitTime[1], finHitTime[2])
    local newPos = {x = self.pos.x + dPos.x, y = self.pos.y + dPos.y}

    local VERY_SMOL = 0.000001
    if math.abs(finHitTime[1] - finHitTime[2]) < VERY_SMOL and finHitTime[1] < 2 and finHitTime[2] < 2 then
        newPos.x = self.pos.x
        newPos.y = self.pos.y
        self.vel.x = 0
        self.vel.y = 0
    elseif finHitTime[2] < 2 then
        self.vel.y = 0
        newPos.y = self.pos.y
    elseif finHitTime[1] < 2 then
        self.vel.x = 0
        newPos.x = self.pos.x
    end

    self.pos = newPos
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

    self.vel.x = clampVal(self.vel.x, -SPEED_MAX, SPEED_MAX)
    self.vel.y = clampVal(self.vel.y, -SPEED_MAX, SPEED_MAX)

    local dPos = {
        x = self.vel.x * PHYS_UPDATE_FREQ,
        y = self.vel.y * PHYS_UPDATE_FREQ
    }

    self:runColTests(tilemap, dPos)
end

function Player:doFlip()
    self.gravFlip = not self.gravFlip
    self.vel.y = 0
end
