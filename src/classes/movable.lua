local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Circle = require 'src.classes.circle'

local Movable = Class {
    G = 1
}
Movable:include(Circle)

function Movable:init(world, attractors, x, y, radius)
    Circle.init(self, x, y, radius)
    self.attractors = attractors

    -- setup physics
    local shape = love.physics.newCircleShape(radius)
    self.body = love.physics.newBody(world, x, y, 'dynamic')
    self.fixture = love.physics.newFixture(self.body, shape, 1)
end

function Movable:update(dt)
    for _, attractor in pairs(self.attractors) do
        local direction = (attractor.pos - self.pos):normalized()
        local magnitude = Movable.G * self:getArea() * attractor:getArea() / self:getSquaredLengthTo(attractor.pos)
        self.body:applyForce((direction * magnitude):unpack())
    end

    self.pos = Vector(self.body:getX(), self.body:getY())
end

return Movable
