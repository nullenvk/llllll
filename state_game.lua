require('gamestate')
require('sprite')
require('player')
require('tilemap')

State_Game = GameState:new({})

local LAYERNUM_BACKGROUND = 0
local LAYERNUM_MAP = 1
local LAYERNUM_ENTS = 2

local LAYERNUM_NUM = 4

local curScene = {}
local tmap = nil
local screenPos = nil

ObjTiles = GameObj:new({dat = nil})

function ObjTiles:new(o, x, y)
    o = o or GameObj:new()
    setmetatable(o, self)
    self.__index = self

    if (x and y) == nil then error("Failed to generate ObjTiles") end

    o.dat = tmap.screens[x][y]

    return o
end

function ObjTiles:draw()
    local tile_w = 800/TILESCREEN_W
    local tile_h = 600/TILESCREEN_H

    local function drawTile(tx, ty)
        love.graphics.rectangle("fill", (tx-1)*tile_w, (ty-1)*tile_h, tile_w, tile_h)
    end

    love.graphics.setColor(0.2,0,0.9)

    for x=1,TILESCREEN_W do
        for y=1,TILESCREEN_H do
            if self.dat[x][y] ~= "0" then drawTile(x, y) end
        end
    end
end

function ObjTiles:update(_)

end

function State_Game:init()
    curScene = {}
    for _=1,LAYERNUM_NUM do table.insert(curScene, {}) end

    tmap = TileMap:new(nil, "res/main.map")
    screenPos = {x = 1, y = 1}

    Player.preload()
    curScene[LAYERNUM_ENTS]["player"] = Player:new()
    curScene[LAYERNUM_MAP]["tiles"] = ObjTiles:new(nil, screenPos.x, screenPos.y)
end

function State_Game:draw()
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    --Draw objects layer by layer
    for _,sceneObjs in ipairs(curScene) do
        for _,v in pairs(sceneObjs) do v:runDraw() end
    end

end

function State_Game:update(dt)
    local newState = nil

    --Run updates on all oll objects in all layers
    for _,sceneObjs in ipairs(curScene) do
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
    for _,sceneObjs in ipairs(curScene) do
        for _,v in pairs(sceneObjs) do v:destroyObj() end
    end

    curScene = nil
    tmap = nil
    screenPos = nil

    Player.free()
end

function GameState:keypressed(key, scancode, isrepeat)

end
