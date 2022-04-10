require("sprite")

local TEXTURE_PATH_FADE = "res/fader.png"
local FADE_TIME = 0.75

FadeEffect = Sprite:new({
    reversed = false,
    enabled = false,
    startTime = nil,
})

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
    return o
end

function FadeEffect:draw()
    if self.enabled then
        -- Fade sprite
        local progress = math.min(1, (love.timer.getTime() - self.startTime) / FADE_TIME)

        if self.reversed then progress = 1 - progress end

        self.screenPos.x = progress * (800 + self.spriteSize.w) - self.spriteSize.w
        Sprite.draw(self)

        love.graphics.setColor(0,0,0)
        love.graphics.rectangle("fill", 0, 0, self.screenPos.x, 600)
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
