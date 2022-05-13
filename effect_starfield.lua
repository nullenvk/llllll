require("gameobj")

--local TEXTURE_PATH_FADE = "res/fader.png"
local COLOR_STARFIELD = {0.64, 0.64, 0.64}

StarfieldEffect = GameObj:new()

function StarfieldEffect:new(o, randomized)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    o.randomized = randomized or false
    o.stars = {}
    o.startTime = nil
    o.flyTime = 5 -- seconds, const
    o.initStarCount= 20

    if o.randomized then o:addRandomStars(o.initStarCount) end

    return o
end

function StarfieldEffect:addStar(startTime)
    local star = {t = startTime}
    table.insert(self.stars, star)
end

function StarfieldEffect:addRandomStars(n)
    local function addRandomStar()
        local t = love.math.random() * self.flyTime
        self:addStar(t)
    end

    for _=1,n do addRandomStar() end
end

function StarfieldEffect:draw()
    --love.graphics.setColor(0,0,1)
    --love.graphics.rectangle("fill", 0, 0, 800, 600) 
end

function StarfieldEffect:update()
    Sprite.update(self)
end
