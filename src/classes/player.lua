local Class   = require 'modules.hump.class'
local Signal  = require 'modules.hump.signal'
local Vector  = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Player = Class {
    radius = 12,
    density = 1,
    thrust = 16,
    sprTrail = love.graphics.newImage('res/circle.png')
}
Player:include(Movable)

function Player:init(world, planets, x, y)
    Movable.init(self, world, planets, x, y, Player.radius)

    self.ground = nil
    self.points = 0
    self.direction = 0

    self.body:setLinearDamping(0.5)
    self.body:setAngularDamping(0.5)
    self.body:setFixedRotation(true)

    self.fixture:setUserData({
        object = self,
        tag = 'Player',
        collide = function(data)
            if data.tag == 'Planet' then
                -- Signal.emit('cam_shake', 40, self.direction)
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

    self.trail = love.graphics.newParticleSystem(Player.sprTrail)
    self.trail:setParticleLifetime(0.3)
    self.trail:setSizes(1, 0)
end

function Player:update(dt)
    Movable.update(self, dt)

    if Keyboard.isDown('up') then
        local vec = Player.thrust * Vector(1, 0):rotated(self.direction)
        self.body:applyLinearImpulse(vec:unpack())
    end

    if Keyboard.isDown('left') then
        self.direction = self.direction - 4 * math.pi / 180
    end

    if Keyboard.isDown('right') then
        self.direction = self.direction + 4 * math.pi / 180
    end

    self.trail:setPosition(self.pos:unpack())
    self.trail:emit(1)
    self.trail:update(dt)
end

function Player:draw()
    love.graphics.print(self.points, self.pos.x - 4, self.pos.y - 4)
    love.graphics.circle('fill', self.pos.x + 16 * math.cos(self.direction), self.pos.y + 16 * math.sin(self.direction), 4)
    Movable.draw(self)
    love.graphics.draw(self.trail)
end

return Player
