local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'
local Moon = require 'src.classes.moon'

local Planet = Class {
    SPR_GRASS = love.graphics.newImage('res/grass_planet.png')
}
Planet:include(Body)

function Planet:init(world, x, y, radius, hasMoon)
    Body.init(self, world, x, y, radius)
    self.hasMoon = hasMoon
    if hasMoon then
      self.moon = Moon(world, self, x - radius*2, y, RNG:random(20, 40))
    end
    self.fixture:setFriction(1)

    self.fixture:setUserData({
        object = self,
        tag = 'Planet',
        collide = function(data) end,
        endCollide = function(data) end
    })
end

function Planet:update(dt)
    if hasMoon then
      self.moon:update(dt)
    end
end

function Planet:draw(dt)
    love.graphics.draw(Planet.SPR_GRASS, self.pos.x, self.pos.y, 0, self.radius / 32, self.radius / 32, 32, 32)
    if hasMoon then
      self.moon:draw()
    end
end

return Planet
