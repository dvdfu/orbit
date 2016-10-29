local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'

local Circle = Class {}

function Circle:init(x, y, radius)
    self.pos = Vector(x, y)
    self.radius = radius
end

function Circle:getArea()
    return math.pi * self.radius * self.radius
end

function Circle:getSquaredLengthTo(vec)
    return (self.pos - vec):len2()
end

function Circle:draw()
    love.graphics.circle('line', self.pos.x, self.pos.y, self.radius)
end

return Circle
