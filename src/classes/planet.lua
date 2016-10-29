local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'

local Planet = Class {}

function Planet:init(x, y, radius)
    self.pos = Vector(x, y)
    self.radius = radius
end

function Planet:update(dt)
end

function Planet:draw()
    love.graphics.circle('line', self.pos.x, self.pos.y, self.radius)
end

return Planet
