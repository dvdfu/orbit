local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Bit = Class {
    density = 1,
    sprTrail = love.graphics.newImage('res/circle.png'),
}
Bit:include(Movable)

function Bit:init(world, planets, owner, x, y)
    Movable.init(self, world, planets, x, y, 3)

    self.body:setFixedRotation(true)
    self.fixture:setRestitution(0.8)
    self.fixture:setUserData({
        object = self,
        tag = 'Bit',
        collide = function(data)
            if data.tag == 'Planet' then
                self.owner = nil
            end
        end,
        endCollide = function(data) end
    })

    self.owner = owner

    self.trail = love.graphics.newParticleSystem(Bit.sprTrail)
    self.trail:setParticleLifetime(0.3)
    self.trail:setSizes(0.3, 0)
end

function Bit:update(dt)
    Movable.update(self, dt)

    self.trail:setPosition(self.pos.x, self.pos.y)
    self.trail:emit(1)
    self.trail:update(dt)
end

function Bit:draw()
    if owner then
        love.graphics.setColor(255, 0, 0)
        Movable.draw(self)
        love.graphics.setColor(255, 255, 255)
    else
        Movable.draw(self)
    end

    love.graphics.draw(self.trail)
end

return Bit
