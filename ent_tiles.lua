require('ent_sprite')

local TILETYPE_NUM = 2

Tiles = GameObj:new({dat = nil, colDat = nil, textures = nil})

function Tiles.preload()
    local PATH_PREFIX = "res/tile"
    local PATH_SUFFIX = ".png"

    Tiles.textures = {}

    for i=1,TILETYPE_NUM do
        local path = PATH_PREFIX..tostring(i)..PATH_SUFFIX
        local texture = love.graphics.newImage(path)
        local quads = {}

        local texW, texH = texture:getDimensions()
        texW = texW/16

        for j=1,16 do
            table.insert(quads,
                love.graphics.newQuad(texW * (j-1), 0, texW, texH, texW*16, texH))
        end

        local txt = {
            texture = texture,
            quads = quads,
            texW = texW,
            texH = texH,
        }

        Tiles.textures[tostring(i)] = txt
    end
end

function Tiles.free()
    Tiles.textures = nil
end

function Tiles:new(o, tilemap, x, y)
    o = o or GameObj:new()
    setmetatable(o, self)
    self.__index = self

    if (x and y) == nil then error("Failed to generate Tiles") end

    o.dat = tilemap.screens[x][y]

    return o
end

function Tiles:drawTile(tx, ty)
    local tile_w = 800/TILESCREEN_W
    local tile_h = 600/TILESCREEN_H
    local tile = self.dat[tx][ty]

    -- Assumes that tiles out of bounds of current screen aren't connected
    local function isSeamless(ox, oy)
        if tx + ox < 1 or tx + ox > TILESCREEN_W then return false end
        if ty + oy < 1 or ty + oy > TILESCREEN_H then return false end

        return tile == self.dat[tx + ox][ty + oy]
    end

    love.graphics.setColor(0.2, 1, 0.9)
    love.graphics.rectangle("fill", (tx-1)*tile_w, (ty-1)*tile_h, tile_w, tile_h)
    if self.textures[tile] == nil then return end

    local qnum = 1
    qnum = qnum + (isSeamless(0, 1) and 0 or 1)
    qnum = qnum + (isSeamless(0, -1) and 0 or 2)
    qnum = qnum + (isSeamless(-1, 0) and 0 or 4)
    qnum = qnum + (isSeamless(1, 0) and 0 or 8)

    local tex = Tiles.textures[tile]
    local x, y = (tx-1) * tile_w, (ty-1) * tile_h
    love.graphics.draw(tex.texture, tex.quads[qnum], x, y)
end

function Tiles:draw()

    for x=1,TILESCREEN_W do
        for y=1,TILESCREEN_H do
            if self.dat[x][y] ~= "0" then self:drawTile(x, y) end
        end
    end
end

function Tiles:update(_) end
