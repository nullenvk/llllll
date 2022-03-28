require('gameobj')
Sprite = GameObj:new({})

function Sprite:new(o)
    o = o or GameObj:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Sprite:update(dt)
end

function Sprite:draw()
    love.graphics.rectangle("fill", 64, 64, 64, 64)
end
