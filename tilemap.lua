TILESCREEN_W = 40
TILESCREEN_H = 30

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

end

function TileMap:loadFile(path)
    local fDat, fSize = love.filesystem.read(path)
    if fDat == nil then error("Failed to open a tilemap file") end
    local fSections = splitBySections( splitByLines(fDat) )

    -- read metadata
    self.mapW, self.mapH = parseMetadata(fSections[1])

    for i=2,#fSections do
        table.insert(self.screens, parseScreen(fSections[i]))
    end
end
