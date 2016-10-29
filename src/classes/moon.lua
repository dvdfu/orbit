local Class = require 'modules.hump.class'
local Body = require 'src.mixins.body'
local Vector  = require 'modules.hump.vector'

local Moon = Class {
  density = 1
}
Moon:include(Body)

function Moon:init(world, planet, x, y, radius)
    Body.init(self, world, x, y, radius)
    self.fixture:setFriction(1)

    self.planet = planet;
    self.angle = 0;

    self.fixture:setUserData({
        object = self,
        tag = 'Moon',
        collide = function(data) end,
        endCollide = function(data) end
    })
end

function Moon:update(dt)
  self.angle = self.angle + dt/2;
  if self.angle >= 2*math.pi then
    self.angle = 0;
  end
  self.pos.x = (self.radius+self.planet.radius + 50)*math.cos(self.angle) + self.planet.pos.x
  self.pos.y = (self.radius+self.planet.radius + 30)*math.sin(self.angle) + self.planet.pos.y
end

function Moon:draw()
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.radius)
end

return Moon
