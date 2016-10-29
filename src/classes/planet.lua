local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'
local Moon = require 'src.classes.moon'

local Planet = Class {
    density = 1
}
Planet:include(Body)

function Planet:init(world, x, y, radius)
    Body.init(self, world, x, y, radius)
    self.moon = Moon(world, self, x - radius*2, y, RNG:random(10,20))
    self.fixture:setFriction(1)

    self.fixture:setUserData({
        object = self,
        tag = 'Planet',
        collide = function(data) end,
        endCollide = function(data) end
    })
end

function Planet:update(dt)
    self.moon:update(dt)
end

function Planet:draw(dt)
  Body.draw(self)
  self.moon:draw()
end

return Planet
