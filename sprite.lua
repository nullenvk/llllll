require('gameobj')
Sprite = GameObj:new({
    spritePosX = 0,
    spritePosY = 0,
    spriteFlipX = false,
    spriteFlipY = false,
    spriteSub = 1,

    -- read only
    spriteTexture = nil,
    spriteQuads = nil,
    spriteSizeW = 0,
    spriteSizeH = 0,
})

function Sprite:new(o)
    o = o or GameObj:new(o)
    setmetatable(o, self)
    self.__index = self

    return o
end

function Sprite:loadTexture(path, subspriteNum)
    self.texture = love.graphics.newImage(path)
    local texW, texH = self.texture:getDimensions()

    subspriteNum = subspriteNum or 1

    self.spriteSizeW = texW / subspriteNum
    self.spriteSizeH = texH
    self.spriteSub = subspriteNum

    self.spriteQuads = {}

    local spriteW = self.spriteSizeW
    for i=1,subspriteNum do
        table.insert(self.spriteQuads,
            love.graphics.newQuad(spriteW * (i-1), 0, spriteW, texH, texW, texH))
    end
end

function Sprite:update(dt)
end

function Sprite:draw()
    if self.texture == nil then error("Tried to draw a sprite without a loaded texture") end

    local flipScaleX = self.spriteFlipX and -1 or 1
    local flipScaleY = self.spriteFlipY and -1 or 1
    --local offsetX = self.spriteFlipX and self.texture:getWidth() or 0
    --local offsetY = self.spriteFlipY and self.texture:getHeight() or 0
    local offsetX = self.spriteFlipX and self.spriteSizeW or 0
    local offsetY = self.spriteFlipY and self.spriteSizeH or 0
    local curQuad = self.spriteQuads[self.spriteSub]

    love.graphics.setColor(1,1,1)
    love.graphics.draw(self.texture, curQuad,
        self.spritePosX + offsetX,
        self.spritePosY + offsetY,
        0, flipScaleX, flipScaleY)
end

