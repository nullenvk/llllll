Vector2 = {}

function Vector2:new(o, x, y)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    o.x = x or 0
    o.y = y or 0
    return o
end

function Vector2.__eq(a, b)
    return a.x == b.x and a.y == b.y
end

function Vector2.__add(a, b)
    return Vector2:new(nil, a.x + b.x, a.y + b.y)
end

function Vector2.__sub(a, b)
    return Vector2:new(nil, a.x + b.x, a.y + b.y)
end
