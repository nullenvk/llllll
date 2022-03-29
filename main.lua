require('gameobj')
require('player')

local sceneObjs = {}

function love.load()
    Player.preload()

    sceneObjs["player"] = Player:new()
end

function love.update(dt)
    -- Run updates on all objects
    for k,v in pairs(sceneObjs) do 
        v:runUpdate(dt)
        
        if v.runStatus == GAMEOBJ_STATUS_GARBAGE then
            table.remove(sceneObjs, k)
        end
    end
end

function love.draw()
    for _,v in pairs(sceneObjs) do v:runDraw() end
end
