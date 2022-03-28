require('gameobj')
require('player')

sceneObjs = {}

function love.load()
    table.insert(sceneObjs, Player:new())
end

function love.update(dt)
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
