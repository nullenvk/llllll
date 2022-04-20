require('gamestate')
require('sprite')
require('player')
require('tilemap')
require('effect_fade')

-- TODO: reorganize this code

State_Game = GameState:new({})

local LAYERNUM_BACKGROUND = 0
local LAYERNUM_MAP = 1

local LAYERNUM_NUM = 2

local curScene = {}
local tmap = nil
local tilescrPos = nil
local playerObj = nil
local introFade = nil
local exitFade = nil

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

function State_Game:switchScreen(dx, dy)
    curScene = {}
    for _=1,LAYERNUM_NUM do table.insert(curScene, {}) end

    tilescrPos.x = tilescrPos.x + dx
    tilescrPos.y = tilescrPos.y + dy

    if playerObj == nil then
        playerObj = Player:new()
        playerObj.pos = {x = 400, y = 500}
    end

    curScene[LAYERNUM_MAP]["player"] = playerObj
    curScene[LAYERNUM_MAP]["tiles"] = ObjTiles:new(nil, tilescrPos.x, tilescrPos.y)
end

function State_Game:init()
    tmap = TileMap:new(nil, "res/main.map")
    FadeEffect.preload()
    Player.preload()

    tilescrPos = {x = 1, y = 1}
    self:switchScreen(0,0)

    introFade = FadeEffect:new(nil, true)
    exitFade = FadeEffect:new(nil, false)
    introFade:start()
end

function State_Game:draw()
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    --Draw objects layer by layer
    for _,sceneObjs in ipairs(curScene) do
        for _,v in pairs(sceneObjs) do v:runDraw() end
    end

    -- Effects
    introFade:draw()
    exitFade:draw()
end

function State_Game:testScrSwitch()
    local function unstuckPlayer(horz)
        if horz then
            playerObj.pos.y = playerObj.pos.y + (playerObj.gravFlip and -1 or 1)
        else
            playerObj.pos.x = playerObj.pos.x + (playerObj.facingSide and -1 or 1)
        end
    end

    -- TODO: ugly code, change later
    local dx, dy = 0, 0

    if playerObj.pos.x > 800 then
        dx = 1
        playerObj.pos.x = 0
        unstuckPlayer(true)
    end

    if playerObj.pos.x < 0 then
        playerObj.pos.x = 800
        dx = -1
        unstuckPlayer(true)
    end

    if playerObj.pos.y > 600 then
        playerObj.pos.y = 0
        dy = 1
        unstuckPlayer(false)
    end

    if playerObj.pos.y < 0 then
        playerObj.pos.y = 600
        dy = -1
        unstuckPlayer(false)
    end

    if dx ~= 0 or dy ~= 0 then self:switchScreen(dx, dy) end
end

function State_Game:updateNormal(dt)
    local newState = nil

    -- Screen switch test
    self:testScrSwitch()

    --Run updates on all oll objects in all layers
    for _,sceneObjs in ipairs(curScene) do
        for k,v in pairs(sceneObjs) do

            v:runUpdate(dt)

            if v.runStatus == GAMEOBJ_STATUS_GARBAGE then
                table.remove(sceneObjs, k)
            end
        end
    end

    -- Physics
    local mapTiles = curScene[LAYERNUM_MAP]["tiles"]

    while playerObj.physTimer > PHYS_UPDATE_FREQ do
        playerObj:updatePhys(mapTiles)
        playerObj.physTimer = playerObj.physTimer - PHYS_UPDATE_FREQ
    end

    playerObj:testOnGround(mapTiles)

    -- Inputs
    if love.keyboard.isDown("space") then playerObj:doFlip() end

    return newState
end

function State_Game:updateExiting()
    if exitFade:hasFinished() then
        return State_MainMenu
    end

    return nil
end

function State_Game:update(dt)
    if not exitFade:hasStarted() then
        return self:updateNormal(dt)
    else
        return self:updateExiting(dt)
    end
end

function State_Game:fini()
    for _,sceneObjs in ipairs(curScene) do
        for _,v in pairs(sceneObjs) do v:destroyObj() end
    end

    curScene = nil
    tmap = nil
    tilescrPos = nil
    playerObj = nil
    introFade = nil
    exitFade = nil

    Player.free()
    FadeEffect.free()
end

function GameState:keypressed(key, _, isrepeat)
    if key == "escape" and not exitFade:hasStarted() then
        exitFade:start()
    end
end
