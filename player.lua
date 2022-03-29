require("sprite")
TEXTURE_PATH_PLAYER = "res/player.png"
Player = Sprite:new({timer = 0})

function Player:new(o)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    return o
end

function Player.preload()
    Player:loadTexture(TEXTURE_PATH_PLAYER)
end

function Player:update(dt)
    Sprite.update(self)

    self.timer = self.timer + dt

    local winW, winH = love.graphics.getDimensions()
    local texW, texH = self.texture:getDimensions()
    local trigT = self.timer * 1

    self.screenPos.x = math.sin(trigT) * 400 + winW/2 - texW/2
    self.screenPos.y = math.cos(trigT) * 300 + winH/2 - texH/2
end
