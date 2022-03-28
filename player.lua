Player = GameObj:new({timer = 0})

function Player:new(o)
    o = o or GameObj:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Player:update(dt)
    self.timer = self.timer + dt

    if self.timer > 5.0 then self.runStatus = GAMEOBJ_STATUS_GARBAGE end
end

function Player:draw()
    love.graphics.rectangle("fill", 64, 64, 64, 64)
end
