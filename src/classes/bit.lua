local Class = require 'modules.hump.class'
local Signal = require 'modules.hump.signal'
local Vector = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Bit = Class {
    RADIUS = 8,
    SPRITE = love.graphics.newImage('res/bit.png'),
    SPR_TRAIL = love.graphics.newImage('res/circle.png'),
    HIT_SOUND = love.audio.newSource("sfx/hit_planet.wav", "static"),
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
                if self.owner ~= 0 then
                  Bit.HIT_SOUND:play()
                end
                self.owner = 0
            elseif data.tag == 'Moon' then
                if self.owner ~= 0 then
                  Bit.HIT_SOUND:play()
                end
                self.owner = 0
            elseif data.tag == 'Sun' then
                Bit.HIT_SOUND:play()
                self.dead = true
            elseif data.tag == 'Asteroid' then
                if self.owner ~= 0 then
                  Bit.HIT_SOUND:play()
                end
                data.object.dead = true
            elseif data.tag == 'Bit' then
                if self.owner ~= 0 then
                  Bit.HIT_SOUND:play()
                end
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
    self.trail:setSizes(Bit.RADIUS / 6, 0)
end

function Bit:update(dt)
    Movable.update(self, dt)

    self.trail:setPosition(self.pos.x, self.pos.y)
    self.trail:emit(1)
    self.trail:update(dt)
end

function Bit:draw()
    if self.owner > 0 then
        love.graphics.setBlendMode('add')
        love.graphics.setColor(Const.colors[self.owner]())
        love.graphics.draw(self.trail)
        love.graphics.setColor(255, 255, 255, 255)
        love.graphics.setBlendMode('alpha')
    end
    love.graphics.draw(Bit.SPRITE, self.pos.x, self.pos.y, self.body:getAngle(), 1, 1, 8, 8)
end

return Bit
