require("sprite")

local SPEED_MAX = 250
local SIDE_ACCEL = 1000
local PHYS_UPDATE_FREQ = 1/60
local TEXTURE_PATH_PLAYER = "res/player.png"

Player = Sprite:new({
    timer = 0,
    physTimer = 0,

    pos = {x = 0, y = 0},
    vel = {x = 0, y = 0},

    -- Controls
    moveDir = 0, -- -1 left, +1 right
    gravFlip = false, -- false means fall down
})

function Player:new(o)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self
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

    --local texW, texH = self.texture:getDimensions()
    --local trigT = self.timer * 1
    --self.screenPos.x = math.sin(trigT) * 400 + 400 - texW/2
    --self.screenPos.y = math.cos(trigT) * 300 + 300 - texH/2

    self.moveDir = 0
    if love.keyboard.isDown("a") ~= love.keyboard.isDown("d") then
        self.moveDir = love.keyboard.isDown("a") and -1 or 1
    end

    while self.physTimer > PHYS_UPDATE_FREQ do
        self:updatePhys()
        self.physTimer = self.physTimer - PHYS_UPDATE_FREQ
    end

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

function Player:updatePhys()
    -- Idea: Maybe zero out velocity when player tries to move to the opposite of current velocity

    self.vel.x = self.vel.x + PHYS_UPDATE_FREQ * self.moveDir * SIDE_ACCEL

    -- Brake when not moving
    if self.moveDir == 0 then
        if self.vel.x > 0 then
            self.vel.x = math.max(0, self.vel.x - SIDE_ACCEL * PHYS_UPDATE_FREQ)
        else
            self.vel.x = math.min(0, self.vel.x + SIDE_ACCEL * PHYS_UPDATE_FREQ)
        end
    end

    self.vel.x = clampVal(self.vel.x, -SPEED_MAX, SPEED_MAX)
    self.vel.y = clampVal(self.vel.x, -SPEED_MAX, SPEED_MAX)

    self.pos.x = self.pos.x + self.vel.x * PHYS_UPDATE_FREQ
end
