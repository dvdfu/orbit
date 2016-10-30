local Class   = require 'modules.hump.class'
local Signal  = require 'modules.hump.signal'
local Vector  = require 'modules.hump.vector'
local Circle  = require 'src.mixins.circle'
local Movable = require 'src.mixins.movable'
local Weapon  = require 'src.classes.weapon'

local Player = Class {
    RADIUS = 12,
    MOVE_FORCE = 400
}
Player:include(Movable)

function Player:init(id, world, level, planet, planets, angle)
    local x, y = (planet.pos + (planet.radius + Player.RADIUS) * Vector(1, 0):rotated(angle)):unpack()
    Movable.init(self, world, planets, x, y, Player.RADIUS, true)

    self.id = id
    self.planet = planet
    self.weapon = Weapon(level, self, Const.weapons.pistol)
    self.level = level
    self.points = 0
    self.direction = 0

    self.body:setLinearDamping(4)

    self.fixture:setUserData({
        object = self,
        tag = 'Player',
        collide = function(data)
            if data.tag == 'Bit' then
                data.object.dead = true
                if data.object.owner > 0 and data.object.owner ~= self.id then
                    self.dead = true
                else
                    self.points = self.points + 1
                end
            end
        end,
        endCollide = function(data) end
    })

    self.joystick = love.joystick.getJoysticks()[id]
end

function Player:update(dt)
    local ls = Vector(self.joystick:getGamepadAxis('leftx'), self.joystick:getGamepadAxis('lefty'))
    if ls:len() > 0.25 then
        self.body:applyForce((ls:normalized() * Player.MOVE_FORCE):unpack())
    end

    local rs = Vector(self.joystick:getGamepadAxis('righty'), self.joystick:getGamepadAxis('rightx'))
    if rs:len() > 0.25 then
        self.direction = math.atan2(rs:unpack())
    end

    self.weapon:update(dt)
    if self.joystick:isGamepadDown('rightshoulder') then
        if self.weapon:shoot() then
            self.body:applyLinearImpulse(Vector(50, 0):rotated(self.direction + math.pi):unpack())
        end
    end

    if self.joystick:isGamepadDown('y') then
        if self.weapon.type == Const.weapons.pistol then
            self.weapon:setWeaponType(Const.weapons.machineGun)
        else
            self.weapon:setWeaponType(Const.weapons.pistol)
        end
    end

    Movable.update(self, dt)
end

function Player:draw()
    love.graphics.setColor(Const.colors[self.id]())
    love.graphics.print(self.points, self.pos.x - 4, self.pos.y - 4)
    love.graphics.circle('fill', self.pos.x + 16 * math.cos(self.direction), self.pos.y + 16 * math.sin(self.direction), 4)
    -- self.planet:draw()
    Movable.draw(self)
    love.graphics.setColor(255, 255, 255)
end

return Player
