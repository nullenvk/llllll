GameState = {}

function GameState:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function GameState:init() end
function GameState:fini() end
function GameState:update(_) end -- Accepts deltaTime, normally returns nil, returns another GameState when a switch occurs
function GameState:draw() end
