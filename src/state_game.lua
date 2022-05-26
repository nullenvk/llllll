require('src.gamestate')
require('src.tilemap')
require('src.effect_fade')
require('src.effect_starfield')
require('src.ent_tiles')
require('src.ent_sprite')
require('src.ent_player')

State_Game = GameState:new({})

local LAYERNUM_BACKGROUND = 1
local LAYERNUM_MAP = 2

local LAYERNUM_NUM = 2

function State_Game:switchScreen(sx, sy)
    self.scene = {}
    for _=1,LAYERNUM_NUM do table.insert(self.scene, {}) end

    self.player.tmPos.x = sx
    self.player.tmPos.y = sy

    self.scene[LAYERNUM_BACKGROUND]["starfield"] = StarfieldEffect:new(nil, true)
    self.scene[LAYERNUM_MAP]["player"] = self.player
    self.scene[LAYERNUM_MAP]["tiles"] = Tiles:new(nil, self.tmap, self.player.tmPos.x, self.player.tmPos.y)
end

function State_Game:init()
    self.tmap = TileMap:new(nil, "res/main.map")
    FadeEffect.preload()
    Player.preload()
    Tiles.preload()


    self.player = Player:new()
    self.player.tmPos = {x = 1, y = 1}
    self:switchScreen(1,1)

    self.fadeIntro = FadeEffect:new(nil, true)
    self.fadeExit = FadeEffect:new(nil, false)
    self.fadeIntro:start()
end

function State_Game:draw()
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("fill", 0, 0, 800, 600)

    --Draw objects layer by layer
    for _,sceneObjs in ipairs(self.scene) do
        for _,v in pairs(sceneObjs) do v:runDraw() end
    end

    -- Effects
    self.fadeIntro:draw()
    self.fadeExit:draw()
end

function State_Game:testScrSwitchOOB() -- Out of bounds case
    -- TODO: ugly code, change later
    local dx, dy = 0, 0

    if self.player.pos.x > 800 then
        dx = 1
        self.player.pos.x = 1
    end

    if self.player.pos.x < 0 then
        self.player.pos.x = 799
        dx = -1
    end

    if self.player.pos.y > 600 then
        self.player.pos.y = 1
        dy = 1
    end

    if self.player.pos.y < 0 then
        self.player.pos.y = 599
        dy = -1
    end

    if dx ~= 0 or dy ~= 0 then 
        self:switchScreen(self.player.tmPos.x + dx, self.player.tmPos.y + dy)
        return true
    end

    return false
end

function State_Game:testScrSwitchTeleport()
    local tdest = self.player.teleportDest
    if tdest ~= nil then
        if tdest.reset then self.player = Player:new() end

        self.player.pos = {x = tdest.x, y = tdest.y}
        self:switchScreen(tdest.sx, tdest.sy)
        self.player.teleportDest = nil
    end
end

function State_Game:testScrSwitch()
    return self:testScrSwitchTeleport() --or self:testScrSwitchOOB()
end

function State_Game:updateNormal(dt)
    local newState = nil

    -- Screen switch test
    self:testScrSwitch()

    --Run updates on all oll objects in all layers
    for _,sceneObjs in ipairs(self.scene) do
        for k,v in pairs(sceneObjs) do

            v:runUpdate(dt)

            if v.runStatus == GAMEOBJ_STATUS_GARBAGE then
                table.remove(sceneObjs, k)
            end
        end
    end

    -- Physics
    local mapTiles = self.scene[LAYERNUM_MAP]["tiles"]

    while self.player.physTimer > PHYS_UPDATE_FREQ do
        self.player:updatePhys(mapTiles)
        self.player.physTimer = self.player.physTimer - PHYS_UPDATE_FREQ
    end

    self.player:testOnGround(mapTiles)

    -- Inputs
    if love.keyboard.isDown("space") then self.player:doFlip() end

    return newState
end

function State_Game:updateExiting()
    if self.fadeExit:hasFinished() then
        return State_MainMenu
    end

    return nil
end

function State_Game:update(dt)
    if not self.fadeExit:hasStarted() then
        return self:updateNormal(dt)
    else
        return self:updateExiting(dt)
    end
end

function State_Game:fini()
    for _,sceneObjs in ipairs(self.scene) do
        for _,v in pairs(sceneObjs) do v:destroyObj() end
    end

    Tiles.free()
    Player.free()
    FadeEffect.free()
end

function GameState:keypressed(key, _, isrepeat)
    if key == "escape" and not self.fadeExit:hasStarted() then
        self.fadeExit:start()
    end
end
