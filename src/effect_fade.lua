require("src.ent_sprite")

local TEXTURE_PATH_FADE = "res/fader.png"
local FADE_TIME = 0.35

FadeEffect = Sprite:new()

function FadeEffect.preload()
    FadeEffect:loadTexture(TEXTURE_PATH_FADE)
end

function FadeEffect.free()
    FadeEffect.texture = nil
end

function FadeEffect:new(o, reversed)
    o = o or Sprite:new(o)
    setmetatable(o, self)
    self.__index = self

    o.reversed = reversed or false
    o.environment = false
    o.startTime = nil

    return o
end

function FadeEffect:draw()
    if self.enabled then
        -- Fade sprite
        local progress = math.min(1, (love.timer.getTime() - self.startTime) / FADE_TIME)

        if self.reversed then progress = 1 - progress end

        self.spritePosX = progress * (800 + self.spriteSizeW) - self.spriteSizeW
        Sprite.draw(self)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 0, 0, self.spritePosX, 600)
    end
end

function FadeEffect:update()
    Sprite.update(self)
end

function FadeEffect:start()
    self.enabled = true
    self.startTime = love.timer.getTime()
end

function FadeEffect:reset()
    self.enabled = false
end

function FadeEffect:hasFinished()
    return love.timer.getTime() - self.startTime > FADE_TIME
end

function FadeEffect:hasStarted()
    return self.enabled
end
