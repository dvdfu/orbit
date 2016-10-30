local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'

local Movable = Class {
    G = 1
}
Movable:include(Body)

function Movable:init(world, attractors, x, y, radius)
    Body.init(self, world, x, y, radius, true)
    self.attractors = attractors
end

function Movable:update(dt)
    -- apply force per attractor
    for _, attractor in pairs(self.attractors) do
        local direction = (attractor.pos - self.pos):normalized()
        local magnitude = Movable.G * self:getArea() * attractor:getArea() / self:getSquaredLengthTo(attractor.pos)
        self.body:applyForce((direction * magnitude):unpack())
    end

    Body.update(self, dt)
end

return Movable
