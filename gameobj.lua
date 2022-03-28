GAMEOBJ_STATUS_OK = 0
GAMEOBJ_STATUS_GARBAGE = -1

GameObj = { runStatus = GAMEOBJ_STATUS_OK}

function GameObj:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function GameObj:runUpdate(dt)
    if self.runStatus == GAMEOBJ_STATUS_OK then
        self:update(dt)
    end
end

function GameObj:runDraw()
    if self.runStatus == GAMEOBJ_STATUS_OK then
        self:draw()
    end
end

function GameObj:draw()
end

function GameObj:update(_)
    error("update method not defined for a game object")
end

function GameObj:destroyObj()
    self.runStatus = GAMEOBJ_STATUS_GARBAGE
end
