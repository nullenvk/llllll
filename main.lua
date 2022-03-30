require('gameobj')
require('player')
require('scene')
require('letterbox')

require('state_mainmenu')

local curGameState

function love.load()
    local winW, winH = 1024, 768

    LetterboxInit(winW, winH)
    love.window.setMode(winW, winH) -- may fail

    --Player.preload()
    --Scene[LAYERNUM_ENTS]["player"] = Player:new()

    curGameState = State_MainMenu
    curGameState:init()
end

function love.update(dt)
    -- Run updates on all oll objects in all layers
    --for _,sceneObjs in ipairs(Scene) do
    --
    --    for k,v in pairs(sceneObjs) do
    --        v:runUpdate(dt)
    --    if v.runStatus == GAMEOBJ_STATUS_GARBAGE then
                --table.remove(sceneObjs, k)
            --end
        --end
    --end

    local newState = curGameState:update(dt)
    if newState ~= nil then
        curGameState:fini()
        curGameState = newState
        curGameState:init()
    end
end

function love.draw()
    LetterboxStart()

    --love.graphics.rectangle("fill", 0, 0, 800, 600)
    -- Draw objects layer by layer
    --for _,sceneObjs in ipairs(Scene) do
    --    for _,v in pairs(sceneObjs) do v:runDraw() end
    --end

    curGameState:draw()

    LetterboxFinish()
end
