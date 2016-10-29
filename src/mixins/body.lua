local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Circle = require 'src.mixins.circle'

local Body = Class {}
Body:include(Circle)

function Body:init(world, x, y, radius, dynamic)
    Circle.init(self, x, y, radius)

    -- setup physics
    local shape = love.physics.newCircleShape(radius)
    self.body = love.physics.newBody(world, x, y, dynamic and 'dynamic' or 'static')
    self.fixture = love.physics.newFixture(self.body, shape, 1)
end

function Body:update(dt)
    self.pos = Vector(self.body:getX(), self.body:getY())
end

return Body
