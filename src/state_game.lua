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
    self.player.tilemap = Tiles:new(nil, self.tmap, self.player.tmPos.x, self.player.tmPos.y)

    self.scene[LAYERNUM_BACKGROUND]["starfield"] = StarfieldEffect:new(nil, true)
    self.scene[LAYERNUM_MAP]["player"] = self.player
    self.scene[LAYERNUM_MAP]["tiles"] = self.player.tilemap
end

function State_Game:init()
    self.tmap = TileMap:new(nil, "res/main.map")
    FadeEffect.preload()
    Player.preload()
    Tiles.preload()

    self.player = Player:new()
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

function State_Game:testTeleport()
    local tdest = self.player.teleportDest
    local rdest = self.player.respawnDest

    if tdest ~= nil then
        if tdest.reset then 
            self.player = Player:new()
            self.player.respawnDest = rdest -- Make respawn points persist between deaths
            self.player.gravFlip = tdest.gravFlip or false
        end

        self.player.pos = {x = tdest.x, y = tdest.y}
        self:switchScreen(tdest.sx, tdest.sy)
        self.player.teleportDest = nil
    end
end

function State_Game:updateNormal(dt)
    local newState = nil

    self:testTeleport()

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
    while self.player.physTimer > PHYS_UPDATE_FREQ do
        self.player:updatePhys()
        self.player.physTimer = self.player.physTimer - PHYS_UPDATE_FREQ
    end

    self.player:testOnGround()

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
