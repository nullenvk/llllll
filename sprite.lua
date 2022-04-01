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

    local posScale

    local flipScaleX = self.spriteFlipX and -1 or 1
    local flipScaleY = self.spriteFlipY and -1 or 1
    local offsetX = self.spriteFlipX and self.texture:getWidth() or 0
    local offsetY = self.spriteFlipY and self.texture:getHeight() or 0

    love.graphics.setColor(1,1,1)
    love.graphics.draw(self.texture, self.screenPos.x + offsetX, self.screenPos.y + offsetY, 0, scaleX, scaleY)
end
