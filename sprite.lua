require('gameobj')
Sprite = GameObj:new({
    screenPos = {x = 0, y = 0},
    spriteFlipX = false,
    spriteFlipY = false,

    texture = nil
})

function Sprite:new(o)
    o = o or GameObj:new(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function Sprite:loadTexture(path)
    self.texture = love.graphics.newImage(path)
end

function Sprite:update(dt)
end

function Sprite:draw()
    if self.texture == nil then error("Tried to draw a sprite without a loaded texture") end
    --love.graphics.rectangle("fill", 64, 64, 64, 64)
    love.graphics.draw(self.texture, self.screenPos.x, self.screenPos.y)
end
