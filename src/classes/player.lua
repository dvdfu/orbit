local Class   = require 'modules.hump.class'
local Signal  = require 'modules.hump.signal'
local Vector  = require 'modules.hump.vector'
local Circle  = require 'src.mixins.circle'
local Movable = require 'src.mixins.movable'
local Weapon  = require 'src.classes.weapon'
local Timer = require 'modules.hump.timer'

local Player = Class {
    RADIUS = 12,
    MOVE_FORCE = 4,
    LAUNCH_FORCE = 300,
    THRUST_FORCE = 200,
    BOOST_FORCE = 250,
    BOOST_COOLDOWN = 3,
    SPRITE = love.graphics.newImage('res/rocket.png'),
    SPR_TRAIL = love.graphics.newImage('res/circle.png'),
    SPR_CROWN = love.graphics.newImage('res/crown.png'),
    DEATH_SOUND = love.audio.newSource("sfx/player_explode.wav", "static"),
    PICKUP_BIT_SOUND = love.audio.newSource("sfx/pickup_bit.wav", "static")
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
    self.boost = 5;
    self.invincible = false;

    self.body:setLinearDamping(4)

    self.fixture:setUserData({
        object = self,
        tag = 'Player',
        collide = function(data)
            if data.tag == 'Bit' then
                data.object.dead = true
                if data.object.owner > 0 and data.object.owner ~= self.id then
                    Player.DEATH_SOUND:play()
                    Signal.emit('cam_shake')
                    self.dead = true
                else
                    Player.PICKUP_BIT_SOUND:play()
                    self.points = self.points + 1
                end
            elseif data.tag == 'Planet' then
                self.groundPlanet = data.object
            elseif data.tag == 'Player' and invincible then
                data.object.dead = true
            elseif data.tag == 'Sun' then
                Player.DEATH_SOUND:play()
                Signal.emit('cam_shake')
                self.dead = true
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
    self.trail:setSizes(1, 0)
    self.trail:setSpeed(0, 30)

    self.joystick = love.joystick.getJoysticks()[id]
end

function Player:update(dt)
    if self.groundPlanet then
        local pp = (self.pos - self.groundPlanet.pos):normalized()
        self.direction = pp:angleTo()
    end

    if self.boost < Player.BOOST_COOLDOWN then
        self.boost = self.boost + dt
    else
        self.boost = Player.BOOST_COOLDOWN
    end

    local velX, velY = self.body:getLinearVelocity();

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
            self.groundPlanet = nil
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

    if self.joystick:isGamepadDown('rightshoulder') and self.boost == Player.BOOST_COOLDOWN then
        self.invincible = true;
        self.boost = 0;
        self.trail:setPosition((self.pos - Vector(12, 0):rotated(self.direction)):unpack())
        self.trail:emit(1)
        self.body:applyLinearImpulse(Player.BOOST_FORCE * math.cos(self.direction), Player.BOOST_FORCE * math.sin(self.direction))
        Timer.after(.4, function()
            self.invincible = false;
        end)
    end

    Movable.update(self, dt)
    self.trail:update(dt)
end

function Player:draw()
    if self.boost == Player.BOOST_COOLDOWN then
        love.graphics.print("*", self.pos.x, self.pos.y + 15)
    end

    if self.invincible then
        love.graphics.setColor(Const.colors[self.id]())
        love.graphics.circle('line', self.pos.x, self.pos.y, Player.RADIUS + 6)
    end

    love.graphics.setColor(Const.colors[self.id]())
    love.graphics.setBlendMode('add')
    love.graphics.draw(self.trail)
    love.graphics.setBlendMode('alpha')
    -- love.graphics.print(self.points, self.pos.x - 4, self.pos.y - 4)
    love.graphics.draw(Player.SPRITE, self.pos.x, self.pos.y, self.direction, 1, 1, 12, 12)
    love.graphics.setColor(255, 255, 255)

    -- love.graphics.draw(Player.SPR_CROWN, self.pos.x + 10 * math.cos(self.direction), self.pos.y + 10 * math.sin(self.direction), self.direction, 1, 1, 0, 12)
end

return Player
