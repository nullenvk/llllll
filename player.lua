require("sprite")
Player = Sprite:new({timer = 0})

function Player:new(o)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Player:update(dt)
    Sprite.update(self)

    self.timer = self.timer + dt

    if self.timer > 5.0 then
        self:destroyObj()
    end
end
