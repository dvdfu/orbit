local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Bit = Class {
    RADIUS = 2,
    SPEED = 6,
    density = 1,
    sprTrail = love.graphics.newImage('res/circle.png'),
}
Bit:include(Movable)

function Bit:init(world, planets, owner, x, y)
    Movable.init(self, world, planets, x, y, Bit.RADIUS)
    self.body:setBullet(true)

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
    self.trail:setParticleLifetime(1)
    self.trail:setSizes(0.3, 0)
end

function Bit:update(dt)
    Movable.update(self, dt)

    self.trail:setPosition(self.pos.x, self.pos.y)
    self.trail:emit(1)
    self.trail:update(dt)
end

function Bit:draw()
    if self.owner then
        love.graphics.setColor(Const.colors[self.owner.id]())
        Movable.draw(self)
        -- love.graphics.draw(self.trail)
        love.graphics.setColor(255, 255, 255)
    else
        Movable.draw(self)
        -- love.graphics.draw(self.trail)
    end

end

return Bit
