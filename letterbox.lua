-- This module should automatically make 800x600 viewport fit into a letterboxed window of a larger
-- size. Just run LetterboxInit whenever you update window size, run LetterboxStart before draw
-- calls and after they finish, run LetterboxFinish

local viewW, viewH, viewRatio = 800, 600, 4/3
local winW, winH, winRatio = 800, 600, 4/3

function LetterboxInit(w, h)
    winW, winH, winRatio = w, h, w/h

    if winW < viewW or winH < viewH then
        error("Loveletter library doesn't support resolutions smaller than "..viewW.."x"..viewH)
    end
end

function LetterboxStart()
    local offsetX, offsetY, newScale = 0, 0, 1

    love.graphics.push()

    if winRatio >= viewRatio then
        newScale = winH/viewH
        offsetX = winW/2 - viewW*newScale/2
    else
        newScale = winW/viewW
        offsetY = winH/2 - viewH*newScale/2
    end

    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(newScale)
end

function LetterboxFinish()
    love.graphics.pop()

    r,g,b,a = love.graphics.getColor()

    love.graphics.setColor(0,0,0)
    if winRatio >= viewRatio then
        local barW = winW/2 - viewW*(winH/viewH)/2
        love.graphics.rectangle("fill", 0, 0, barW, winH)
        love.graphics.rectangle("fill", winW - barW, 0, barW, winH)
    else
        local barH = winH/2 - viewH*(winW/viewW)/2
        love.graphics.rectangle("fill", 0, 0, winW, barH)
        love.graphics.rectangle("fill", 0, winH - barH, winW, barH)
    end

    love.graphics.setColor(r,g,b,a)
end
