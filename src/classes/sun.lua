local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'

local Sun = Class {
    SPRITE = love.graphics.newImage('res/sun.png'),
}
Sun:include(Body)

function Sun:init(world, x, y, radius)
    Body.init(self, world, x, y, radius)

    self.fixture:setUserData({
        object = self,
        tag = 'Sun',
        collide = function(data) end,
        endCollide = function(data) end
    })

    self.rotation = RNG:random(0, math.pi * 2)
    self.particles = love.graphics.newParticleSystem(Sun.SPRITE)
    self.particles:setParticleLifetime(1, 2)
    self.particles:setSpread(math.pi * 2)
    self.particles:setSizes(radius / 64)
    self.particles:setSpeed(0, 20)
    self.particles:setColors(255, 255, 255, 255, 255, 255, 255, 0)
end

function Sun:update(dt)
    Body.update(self, dt)
    self.particles:setPosition(self.pos:unpack())
    self.particles:emit(5)
    self.particles:update(dt)
end

function Sun:draw()
    love.graphics.draw(Sun.SPRITE, self.pos.x, self.pos.y, 0, self.radius / 64, self.radius / 64, 64, 64)
    love.graphics.setColor(255, 200, 128)
    love.graphics.setBlendMode('add')
    love.graphics.draw(self.particles)
    love.graphics.setBlendMode('alpha')
    love.graphics.setColor(255, 255, 255)
end

return Sun
