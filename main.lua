require('gameobj')
require('player')
require('scene')
require('letterbox')

function love.load()
    local winW, winH = 1280, 720

    LetterboxInit(winW, winH)
    love.window.setMode(winW, winH) -- may fail

    Player.preload()

    Scene[LAYERNUM_ENTS]["player"] = Player:new()
end

function love.update(dt)
    -- Run updates on all oll objects in all layers
    for _,sceneObjs in ipairs(Scene) do

        for k,v in pairs(sceneObjs) do
            v:runUpdate(dt)

            if v.runStatus == GAMEOBJ_STATUS_GARBAGE then
                table.remove(sceneObjs, k)
            end
        end
    end
end

function love.draw()
    LetterboxStart()

    love.graphics.rectangle("fill", 0, 0, 800, 600)

    -- Draw objects layer by layer
    for _,sceneObjs in ipairs(Scene) do
        for _,v in pairs(sceneObjs) do v:runDraw() end
    end

    LetterboxFinish()
end
