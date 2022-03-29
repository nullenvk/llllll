require('gameobj')
require('player')
require('scene')

function love.load()
    Player.preload()

    Scene[LAYERNUM_ENTS]["player"] = Player:new()
    Scene[LAYERNUM_ENTS]["player"].spriteFlipX = true
    Scene[LAYERNUM_ENTS]["player"].spriteFlipY = true
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
    -- Draw objects layer by layer
    for _,sceneObjs in ipairs(Scene) do
        for _,v in pairs(sceneObjs) do v:runDraw() end
    end
end
