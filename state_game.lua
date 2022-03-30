require('gamestate')
require('sprite')
require('player')

State_Game = GameState:new({})

local LAYERNUM_BACKGROUND = 0
local LAYERNUM_MAP = 1
local LAYERNUM_ENTS = 2

local LAYERNUM_NUM = 4

local Scene = {}

function State_Game:init()
    Scene = {}
    for _=1,LAYERNUM_NUM do table.insert(Scene, {}) end

    Player.preload()
    Scene[LAYERNUM_ENTS]["player"] = Player:new()
end

function State_Game:draw()
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    --Draw objects layer by layer
    for _,sceneObjs in ipairs(Scene) do
        for _,v in pairs(sceneObjs) do v:runDraw() end
    end

end

function State_Game:update(dt)
    local newState = nil

    --Run updates on all oll objects in all layers
    for _,sceneObjs in ipairs(Scene) do
        for k,v in pairs(sceneObjs) do

            v:runUpdate(dt)

            if v.runStatus == GAMEOBJ_STATUS_GARBAGE then
                table.remove(sceneObjs, k)
            end
        end
    end

    if love.keyboard.isDown("escape") then newState = State_MainMenu end

    return newState
end

function State_Game:fini()
    for _,sceneObjs in ipairs(Scene) do
        for _,v in pairs(sceneObjs) do v:destroyObj() end
    end

    Scene = nil

    Player.free()
end
