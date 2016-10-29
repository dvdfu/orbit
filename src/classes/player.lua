local Class   = require 'modules.hump.class'
local Signal  = require 'modules.hump.signal'
local Vector  = require 'modules.hump.vector'
local Body    = require 'src.mixins.body'
local Movable = require 'src.mixins.movable'

local Player = Class {
    RADIUS = 12,
    MOVE_FORCE = 400,
}
Player:include(Body)

function Player:init(id, world, level, planet, angle)
    local x, y = (planet.pos + (planet.radius + Player.RADIUS) * Vector(1, 0):rotated(angle)):unpack()
    Body.init(self, world, x, y, Player.RADIUS, true)

    self.id = id
    self.level = level
    self.planet = planet
    self.points = 0
    self.direction = 0

    self.body:setLinearDamping(4)

    self.fixture:setUserData({
        object = self,
        tag = 'Player',
        collide = function(data)
            if data.tag == 'Bit' then
                data.object.dead = true
                self.points = self.points + 1
            end
        end,
        endCollide = function(data) end
    })

    self.joystick = love.joystick.getJoysticks()[id]
end

function Player:update(dt)
    local direction = (self.planet.pos - self.pos):normalized()
    local magnitude = Movable.G * self:getArea() * self.planet:getArea() / self:getSquaredLengthTo(self.planet.pos)
    self.body:applyForce((direction * magnitude):unpack())

    local force = Player.MOVE_FORCE * direction:rotated(math.pi / 2)

    local lsx = self.joystick:getGamepadAxis('leftx')
    if lsx > 0.1 then
        self.body:applyForce((-force):unpack())
    elseif lsx < -0.1 then
        self.body:applyForce(force:unpack())
    end

    local rsx = self.joystick:getGamepadAxis('rightx')
    local rsy = self.joystick:getGamepadAxis('righty')
    self.direction = math.atan2(rsy, rsx)

    if self.joystick:isGamepadDown('rightshoulder') then
        if self.points > 0 then
            self.points = self.points - 1
            self.level:shoot(self)
        end
    end

    Body.update(self, dt)
end

function Player:draw()
    love.graphics.setColor(Const.colors[self.id]())
    love.graphics.print(self.points, self.pos.x - 4, self.pos.y - 4)
    love.graphics.circle('fill', self.pos.x + 16 * math.cos(self.direction), self.pos.y + 16 * math.sin(self.direction), 4)
    Body.draw(self)
    love.graphics.setColor(255, 255, 255)
end

return Player
