TILESCREEN_W = 32
TILESCREEN_H = 24

TileMap = {mapW = 0, mapH = 0, screens = {}}

function TileMap:new(o, mapFile)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    if mapFile ~= nil then
        o:loadFile(mapFile)
    end

    return o
end

local function splitByLines(str)
    local ret = {}
    for line in str:gmatch("([^\n]*)\n?") do
        table.insert(ret, line)
    end

    return ret
end

local function splitBySections(strTab)
    local ret = {{}}

    for _,l in ipairs(strTab) do
        if l:match("([^%s])") == nil then
            table.insert(ret, {})
        else
            table.insert(ret[#ret], l)
        end
    end

    table.remove(ret)

    return ret
end

local function parseMetadata(sct)
    local mapW, mapH = tonumber(sct[1]), tonumber(sct[2])

    if (mapW and mapH) == nil then
        error("Failed to parse map's metadata")
    end

    return mapW, mapH
end

local function parseScreen(sct)
    local tiles = {}

    for _=1,TILESCREEN_W do
        table.insert(tiles, {})
    end

    for i=1,TILESCREEN_H do
        for j=1, TILESCREEN_W do
            tiles[j][i] = sct[i]:sub(j,j)
        end
    end

    -- Idea: maybe add optional data after reading tiles?

    -- Reading screen color

    return tiles
end

function TileMap:loadFile(path)
    local fDat, fSize = love.filesystem.read(path)
    if fDat == nil then error("Failed to open a tilemap file") end
    local fSections = splitBySections( splitByLines(fDat) )

    -- read metadata
    self.mapW, self.mapH = parseMetadata(fSections[1])

    -- initialize screens table
    for i=1,self.mapW+1 do
        table.insert(self.screens, {})
    end

    -- read all screens
    for i=2,#fSections do
        local x = 1 + ((i - 2) % self.mapW)
        local y = 1 + math.floor((i - 2) / self.mapH)

        self.screens[x][y] = parseScreen(fSections[i])
    end
end
