local Class   = require 'modules.hump.class'
local Signal  = require 'modules.hump.signal'
local Vector  = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Player = Class {
    density = 1,
    jumpForce = 400,
    moveForce = 20
}
Player:include(Movable)

function Player:init(world, planets, x, y)
    Movable.init(self, world, planets, x, y, 16)

    self.ground = nil
    self.points = 0

    self.body:setLinearDamping(0.5)
    self.body:setAngularDamping(0.5)
    self.body:setFixedRotation(true)

    self.fixture:setUserData({
        object = self,
        tag = 'Player',
        collide = function(data)
            if data.tag == 'Planet' then
                -- Signal.emit('cam_shake', 4)
                self.ground = data.object
            elseif data.tag == 'Bit' then
                data.object.dead = true
                self.points = self.points + 1
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
        local d = (self.pos - self.ground.pos):normalized() * Player.jumpForce

        self.body:applyLinearImpulse(d:unpack())
        self.ground = nil
    end

    if Keyboard.isDown('left') and self.ground then
        local d = -(self.pos - self.ground.pos):normalized():perpendicular() * Player.moveForce
        self.body:applyLinearImpulse(d:unpack())
    end

    if Keyboard.isDown('right') and self.ground then
        local d = (self.pos - self.ground.pos):normalized():perpendicular() * Player.moveForce
        self.body:applyLinearImpulse(d:unpack())
    end
end

function Player:draw()
    love.graphics.print(self.points, self.pos.x - 4, self.pos.y - 4)
    Movable.draw(self)
end

return Player
