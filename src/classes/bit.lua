local Class = require 'modules.hump.class'
local Signal = require 'modules.hump.signal'
local Vector = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Bit = Class {
    RADIUS = 8,
    SPR_TRAIL = love.graphics.newImage('res/circle.png'),
}
Bit:include(Movable)

function Bit:init(world, planets, owner, x, y)
    Movable.init(self, world, planets, x, y, Bit.RADIUS)
    self.body:setBullet(true)

    self.body:setAngularDamping(3)
    -- self.body:setFixedRotation(true)
    -- self.fixture:setRestitution(0.7)
    self.fixture:setUserData({
        object = self,
        tag = 'Bit',
        collide = function(data)
            if data.tag == 'Planet' then
                self.owner = 0
            elseif data.tag == 'Sun' then
                self.dead = true
            elseif data.tag == 'Asteroid' then
                data.object.dead = true
            elseif data.tag == 'Bit' then
                self.owner = 0
                data.object.owner = 0
            end
        end,
        endCollide = function(data) end
    })

    self.owner = owner and owner.id or 0

    self.trail = love.graphics.newParticleSystem(Bit.SPR_TRAIL)
    self.trail:setParticleLifetime(1)
    self.trail:setColors(255, 255, 255, 255, 255, 255, 255, 32, 255, 255, 255, 0)
    self.trail:setSizes(Bit.RADIUS / 8, 0)
end

function Bit:update(dt)
    Movable.update(self, dt)

    self.trail:setPosition(self.pos.x, self.pos.y)
    self.trail:emit(1)
    self.trail:update(dt)
end

function Bit:draw()
    love.graphics.setBlendMode('add')
    love.graphics.setColor(Const.colors[self.owner]())
    love.graphics.draw(self.trail)
    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setBlendMode('alpha')
end

return Bit
