local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Player = Class {
    density = 1
}
Player:include(Movable)

function Player:init(world, planets, x, y)
    Movable.init(self, world, planets, x, y, 16)

    self.ground = nil

    self.body:setLinearDamping(0.5)
    self.body:setAngularDamping(0.5)
    self.body:setFixedRotation(true)

    self.fixture:setUserData({
        object = self,
        tag = 'Player',
        collide = function(data)
            if data.tag == 'Planet' then
                self.ground = data.object
            end
        end,
        endCollide = function(data)
            if data.tag == 'Planet' and data.object == self.ground then
                self.ground = nil
            end
        end
    })
end

function Player:update(dt)
    Movable.update(self, dt)

    if Keyboard.isDown('up') and self.ground then
        local d = (self.pos - self.ground.pos):normalized() * 400

        self.body:applyLinearImpulse(d:unpack())
        self.ground = nil
    end

    if Keyboard.isDown('left') and self.ground then
        local d = -(self.pos - self.ground.pos):normalized():perpendicular() * 20
        self.body:applyLinearImpulse(d:unpack())
    end

    if Keyboard.isDown('right') and self.ground then
        local d = (self.pos - self.ground.pos):normalized():perpendicular() * 20
        self.body:applyLinearImpulse(d:unpack())
    end
end

return Player
