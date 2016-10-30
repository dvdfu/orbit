local Class = require 'modules.hump.class'
local Movable = require 'src.mixins.movable'
local Vector  = require 'modules.hump.vector'

local Asteroid = Class {
    SPRITE = love.graphics.newImage('res/asteroid.png'),
    SPR_TRAIL = love.graphics.newImage('res/circle.png'),
    EXPLODE_SOUND = love.audio.newSource('sfx/asteroid_explode.wav', "static")
}
Asteroid:include(Movable);

function Asteroid:init(world, planets, x, y, radius)
    Movable.init(self, world, planets, x, y, radius)
    -- self.body:setLinearDamping(1)

    self.fixture:setUserData({
        object = self,
        tag = 'Asteroid',
        collide = function(data)
              Asteroid.EXPLODE_SOUND:play()
              self.dead = true
        end,
        endCollide = function(data) end
    })

    self.trail = love.graphics.newParticleSystem(Asteroid.SPR_TRAIL)
    self.trail:setParticleLifetime(0, 0.5)
    self.trail:setColors(255, 255, 128, 255, 255, 32, 0, 255, 0, 0, 0, 0)
    self.trail:setSpread(math.pi * 2)
    self.trail:setSizes(radius / 6, 0)
    self.trail:setSpeed(0, 30)
end

function Asteroid:update(dt)
    Movable.update(self, dt)
    self.trail:setPosition(self.pos:unpack())
    self.trail:emit(1)
    self.trail:update(dt)
end

function Asteroid:draw()
    love.graphics.setBlendMode('add')
    love.graphics.draw(self.trail)
    love.graphics.setBlendMode('alpha')
    love.graphics.draw(Asteroid.SPRITE, self.pos.x, self.pos.y, self.body:getAngle(), self.radius / 16, self.radius / 16, 16, 16)
end

return Asteroid
