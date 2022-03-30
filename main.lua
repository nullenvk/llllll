require('letterbox')
require('state_mainmenu')

local curGameState

function love.load()
    local winW, winH = 1024, 768

    LetterboxInit(winW, winH)
    love.window.setMode(winW, winH) -- may fail

    curGameState = State_MainMenu
    curGameState:init()
end

function love.update(dt)
    local newState = curGameState:update(dt)
    if newState ~= nil then
        curGameState:fini()
        curGameState = newState
        curGameState:init()
    end
end

function love.draw()
    LetterboxStart()

    curGameState:draw()

    LetterboxFinish()
end

function love.quit()
    curGameState:fini()

    return false -- Do not abort quit
end
