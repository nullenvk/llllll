require("ent_gameobj")

local STAR_COLOR = {0.24, 0.24, 0.24}
local STAR_SIZE = {w = 6, h = 4}
local STAR_VARIATION = {lowb = 0.4, highb = 1}
local INIT_STAR_COUNT = 30
local FLY_TIME_NORMAL = 10

StarfieldEffect = GameObj:new()

function StarfieldEffect:new(o, randomized)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    o.randomized = randomized or false
    o.stars = {}
    o.startTime = nil

    if o.randomized then o:addRandomStars(INIT_STAR_COUNT) end

    self:start()

    return o
end

function StarfieldEffect:start()
    self.startTime = love.timer.getTime()
end

function StarfieldEffect:addStar(startTime, ycoord, scale)
    local star = {t = startTime, y = ycoord or 0, scale = scale or 1}
    table.insert(self.stars, star)
end

function StarfieldEffect:addRandomStars(n)
    local function addRandomStar()
        local t = love.math.random() * FLY_TIME_NORMAL
        local y = love.math.random(600 - STAR_SIZE.h)
        local s = love.math.random() 
                * (STAR_VARIATION.highb - STAR_VARIATION.lowb) + STAR_VARIATION.lowb

        self:addStar(t, y, s)
    end

    for _=1,n do addRandomStar() end
end

function StarfieldEffect:drawStar(star, elapsed)
    local starW, starH = STAR_SIZE.w * star.scale, STAR_SIZE.h * star.scale
    local tMov = ((elapsed - star.t) / (FLY_TIME_NORMAL / star.scale)) % 1
    local xCoord = tMov * (800 + starW) - starW

    love.graphics.setColor(STAR_COLOR)
    love.graphics.rectangle("fill", xCoord, star.y, starW, starH) 
end

function StarfieldEffect:draw()
    if self.startTime == nil then return end

    local elapsed = love.timer.getTime() - self.startTime
    for _,v in pairs(self.stars) do self:drawStar(v, elapsed) end
end

function StarfieldEffect:update()
    Sprite.update(self)
end
