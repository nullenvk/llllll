SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600

FlyText = {text = "", sTime = 0, y = 0}

function FlyText:new(o, text, y)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    o.text = text
    o.y = y
    o.sTime = love.timer.getTime()
    return o
end

function FlyText:draw()
    textx = SCREEN_WIDTH * 0.5 * (love.timer.getTime() - self.sTime) % SCREEN_WIDTH
    love.graphics.print(self.text, textx, self.y)

end

function love.load()
    fly1 = FlyText:new(nil, "KILL", 100)
    fly2 = FlyText:new(nil, "BAE", 200)
end

function love.draw()
    fly1:draw()
    fly2:draw()
end
