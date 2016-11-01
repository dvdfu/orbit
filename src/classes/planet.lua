local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'
local Station = require 'src.classes.Station.station'

local Planet = Class {
    SPRITES = {
        [1] = love.graphics.newImage('res/water_planet.png'),
        [2] = love.graphics.newImage('res/brown_planet.png'),
        [3] = love.graphics.newImage('res/pink_planet.png'),
    },
    SHADER = love.graphics.newShader(Const.gradientShader)
}
Planet:include(Body)

function Planet:init(world, x, y, radius, hasStation)
    Body.init(self, world, x, y, radius)
    self.hasStation = hasStation
    if hasStation then
      self.station = Station(world, self, x - radius, y, 48)
    end
    self.fixture:setFriction(1)

    self.fixture:setUserData({
        object = self,
        tag = 'Planet',
        collide = function(data) end,
        endCollide = function(data) end
    })

    self.sprite = RNG:random(1, 3)
    self.rotation = RNG:random(0, math.pi * 2)
end

function Planet:update(dt)
    if self.hasStation then
      self.station:update(dt)
    end
end

function Planet:draw(dt)
    love.graphics.setShader(Planet.SHADER)
    love.graphics.draw(Planet.SPRITES[self.sprite], self.pos.x, self.pos.y, 0, self.radius / 32, self.radius / 32, 32, 32)
    love.graphics.setShader()
    if self.hasStation then
      self.station:draw()
    end
end

return Planet
