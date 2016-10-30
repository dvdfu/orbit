local Class   = require 'modules.hump.class'
local Signal  = require 'modules.hump.signal'
local Vector  = require 'modules.hump.vector'
local Circle  = require 'src.mixins.circle'
local Movable = require 'src.mixins.movable'
local Weapon  = require 'src.classes.weapon'

local Player = Class {
    RADIUS = 12,
    MOVE_FORCE = 4,
    LAUNCH_FORCE = 200,
    THRUST_FORCE = 200,
    SPRITE = love.graphics.newImage('res/rocket.png'),
    SPR_TRAIL = love.graphics.newImage('res/circle.png')
}
Player:include(Movable)

function Player:init(id, world, level, planet, planets, angle)
    local x, y = (planet.pos + (planet.radius + Player.RADIUS) * Vector(1, 0):rotated(angle)):unpack()
    Movable.init(self, world, planets, x, y, Player.RADIUS, true)

    self.id = id
    self.planet = planet
    self.groundPlanet = nil
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
                    Signal.emit('cam_shake')
                    self.dead = true
                else
                    self.points = self.points + 1
                end
            elseif data.tag == 'Planet' then
                self.groundPlanet = data.object
            end
        end,
        endCollide = function(data)
            if data.tag == 'Planet' and data.object == self.groundPlanet then
                self.groundPlanet = nil
            end
        end
    })

    self.trail = love.graphics.newParticleSystem(Player.SPR_TRAIL)
    self.trail:setParticleLifetime(0.5, 1)
    self.trail:setColors(255, 255, 255, 255, 32, 32, 32, 255)
    self.trail:setSpread(math.pi * 2)
    self.trail:setSizes(0.8, 0)
    self.trail:setSpeed(0, 30)

    self.joystick = love.joystick.getJoysticks()[id]
end

function Player:update(dt)
    if self.groundPlanet then
        local pp = (self.pos - self.groundPlanet.pos):normalized()
        self.direction = pp:angleTo()
    end

    local ls = Vector(self.joystick:getGamepadAxis('leftx'), self.joystick:getGamepadAxis('lefty'))
    if ls:len() > 0.25 then
        if self.groundPlanet then
            local pp = (self.pos - self.groundPlanet.pos):normalized()
            local angle = pp:angleTo(ls)
            if angle < 0 then angle = angle + math.pi * 2 end

            if pp * ls < 0 then
                if angle < math.pi then
                    pp = -pp
                end
                self.body:applyLinearImpulse((pp:perpendicular():normalized() * Player.MOVE_FORCE):unpack())
            else
                self.body:applyLinearImpulse((ls:normalized() * Player.MOVE_FORCE):unpack())
            end
        else
            self.direction = math.atan2(ls.y, ls.x)
            self.body:applyLinearImpulse((ls:normalized() * Player.MOVE_FORCE):unpack())
        end
    end

    self.weapon:update(dt)

    if self.joystick:getGamepadAxis('triggerleft') > 0.2 then
        self.trail:setPosition((self.pos - Vector(12, 0):rotated(self.direction)):unpack())
        if self.groundPlanet then
            local pp = (self.pos - self.groundPlanet.pos):normalized()
            self.body:applyLinearImpulse((pp * Player.LAUNCH_FORCE):unpack())
            self.groundPlanet =
            self.trail:emit(32)
        else
            self.trail:emit(1)
            self.body:applyForce(Player.THRUST_FORCE * math.cos(self.direction), Player.THRUST_FORCE * math.sin(self.direction))
        end
    end

    if self.joystick:getGamepadAxis('triggerright') > 0.2 then
        self.weapon:shoot()
    end

    if self.joystick:isGamepadDown('y') then
        if self.weapon.type == Const.weapons.pistol then
            self.weapon:setWeaponType(Const.weapons.machineGun)
        else
            self.weapon:setWeaponType(Const.weapons.pistol)
        end
    end

    Movable.update(self, dt)
    self.trail:update(dt)
end

function Player:draw()
    love.graphics.setColor(Const.colors[self.id]())
    love.graphics.setBlendMode('add')
    love.graphics.draw(self.trail)
    love.graphics.setBlendMode('alpha')
    love.graphics.print(self.points, self.pos.x - 4, self.pos.y - 4)
    love.graphics.draw(Player.SPRITE, self.pos.x, self.pos.y, self.direction, 1, 1, 12, 12)
    love.graphics.setColor(255, 255, 255)
end

return Player
