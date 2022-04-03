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
    if self.moveDir == 1 then
        self.facingSide = true
    elseif self.moveDir == -1 then
        self.facingSide = false
    end

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

-- TODO: replace this with the Minkowski sum method
local function checkIntersectAABB(rect1, rect2)
    local function genRectVerts(tr)
        return {
            {x = tr.x, y = tr.y},
            {x = tr.x + tr.w, y = tr.y},
            {x = tr.x, y = tr.y + tr.h},
            {x = tr.x + tr.w, y = tr.y + tr.h},
        }
    end

    local function isPtInsideRect(pt, rect)
        return pt.x >= rect.x and pt.x <= rect.x + rect.w and pt.y >= rect.y and pt.y <= rect.y + rect.h
    end

    local function checkPtsInRect(pts, rect)
        for _,p in pairs(pts) do
            if isPtInsideRect(p, rect) then return true end
        end

        return false
    end

    local rect1Pts, rect2Pts = genRectVerts(rect1), genRectVerts(rect2)

    return checkPtsInRect(rect1Pts, rect2) or checkPtsInRect(rect2Pts, rect1)
end

local function testCollisionTile(tilemap, x, y, px, py, psize)
    if tilemap.dat[x][y] ~= "0" then
        local tileW, tileH = 800/TILESCREEN_W, 600/TILESCREEN_H
        local playerRect = {x = px, y = py, w = psize.w, h = psize.h}
        local tileRect = {x = (x-1)*tileW, y = (y-1)*tileH, w = tileW, h = tileH}

        if checkIntersectAABB(playerRect, tileRect) then
            return true
        end
    end

    return false
end

function Player:updatePhys(tilemap)
    -- Idea: Maybe zero out velocity when player tries to move to the opposite of current velocity

    local gravDir = self.gravFlip and 1 or -1
    self.vel.x = self.vel.x + PHYS_UPDATE_FREQ * self.moveDir * SIDE_ACCEL
    --self.vel.y = self.vel.y + PHYS_UPDATE_FREQ * gravDir * GRAV_ACCEL

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

    self.pos.x = self.pos.x + self.vel.x * PHYS_UPDATE_FREQ
    self.pos.y = self.pos.y + self.vel.y * PHYS_UPDATE_FREQ
end

function Player:doFlip()
    self.gravFlip = not self.gravFlip
end
