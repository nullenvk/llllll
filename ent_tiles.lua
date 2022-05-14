require('gameobj')
require('sprite')

ObjTiles = GameObj:new({dat = nil, colDat = nil})

function ObjTiles:new(o, tilemap, x, y)
    o = o or GameObj:new()
    setmetatable(o, self)
    self.__index = self

    if (x and y) == nil then error("Failed to generate ObjTiles") end

    o.dat = tilemap.screens[x][y]

    return o
end

function ObjTiles:drawTile(tx, ty)
    local tile_w = 800/TILESCREEN_W
    local tile_h = 600/TILESCREEN_H

    local function isSeamless(ox, oy) 
        return self.dat[tx][ty] == self.dat[tx + ox][ty + oy]
    end

    love.graphics.rectangle("fill", (tx-1)*tile_w, (ty-1)*tile_h, tile_w, tile_h)
end

function ObjTiles:draw()
    love.graphics.setColor(0.2,0,0.9)

    for x=1,TILESCREEN_W do
        for y=1,TILESCREEN_H do
            if self.dat[x][y] ~= "0" then self:drawTile(x, y) end
        end
    end
end

function ObjTiles:update(_)

end
