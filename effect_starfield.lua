require("gameobj")

--local TEXTURE_PATH_FADE = "res/fader.png"
local STAR_COLOR = {0.34, 0.34, 0.34}
local STAR_SIZE = {w = 6, h = 3}

StarfieldEffect = GameObj:new()

function StarfieldEffect:new(o, randomized)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    o.randomized = randomized or false
    o.stars = {}
    o.startTime = nil
    o.flyTime = 10 -- seconds, const
    o.initStarCount = 50 -- const

    if o.randomized then o:addRandomStars(o.initStarCount) end

    self:start()

    return o
end

function StarfieldEffect:start()
    self.startTime = love.timer.getTime()
end

function StarfieldEffect:addStar(startTime, ycoord)
    local star = {t = startTime, y = ycoord or 0}
    table.insert(self.stars, star)
end

function StarfieldEffect:addRandomStars(n)
    local function addRandomStar()
        local t = love.math.random() * self.flyTime
        local y = love.math.random(600 - STAR_SIZE.h)
        self:addStar(t, y)
    end

    for _=1,n do addRandomStar() end
end

function StarfieldEffect:drawStar(star, elapsed)
    local tMov = (elapsed - star.t) % self.flyTime
    local xCoord = tMov * (800 + STAR_SIZE.w) - STAR_SIZE.w

    love.graphics.setColor(STAR_COLOR)
    love.graphics.rectangle("fill", xCoord, star.y, STAR_SIZE.w, STAR_SIZE.h) 
end

function StarfieldEffect:draw()
    if self.startTime == nil then return end

    local elapsed = love.timer.getTime() - self.startTime
    for _,v in pairs(self.stars) do self:drawStar(v, elapsed) end
end

function StarfieldEffect:update()
    Sprite.update(self)
end
