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
    self.angle = RNG:random(0, math.pi * 2)
    self.speed = RNG:random(0.5, 1.5)

    self.fixture:setUserData({
        object = self,
        tag = 'Moon',
        collide = function(data) end,
        endCollide = function(data) end
    })
end

function Moon:update(dt)
  Body.update(self, dt)
  self.angle = self.angle + dt/2 * self.speed;
  if self.angle >= 2*math.pi then
    self.angle = 0;
  end
  self.body:setPosition(
      (self.radius+self.planet.radius + 50)*math.cos(self.angle) + self.planet.pos.x
    , (self.radius+self.planet.radius + 30)*math.sin(self.angle) + self.planet.pos.y)
end

function Moon:draw()
  love.graphics.circle('fill', self.pos.x, self.pos.y, self.radius)
end

return Moon
