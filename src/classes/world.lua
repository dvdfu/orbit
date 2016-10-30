local Class    = require 'modules.hump.class'
local Signal   = require 'modules.hump.signal'
local Vector   = require 'modules.hump.vector'
local Camera   = require 'src.camera'
local Bit      = require 'src.classes.bit'
local Planet   = require 'src.classes.planet'
local Player   = require 'src.classes.player'
local Sun      = require 'src.classes.sun'
local Body     = require 'src.mixins.body'
local Asteroid = require 'src.classes.asteroid'

local World = Class {
    NUM_PLANETS = 4,

    -- Generation Parameters
    PLANET_STARTING_POSITION = { low = -10, high = 10 },
    PLANET_RADIUS = { low = 150, high = 250 },
    PLANET_RADIUS_SHRINK_FACTOR = 3.5,
    SPACE_SHADER = love.graphics.newShader(Const.spaceShader)
}

local function getInRange(range)
    return RNG:random(range.low, range.high)
end

local function beginContact(a, b, coll)
    local aData = a:getUserData()
    local bData = b:getUserData()

    if aData and bData then
        aData.collide(bData)
        bData.collide(aData)
    end
end

local function endContact(a, b, coll)
    local aData = a:getUserData()
    local bData = b:getUserData()

    if aData and bData then
        aData.endCollide(bData)
        bData.endCollide(aData)
    end
end

local function preSolve(a, b, coll) end

local function postSolve(a, b, coll, normal, tangent) end

local function contactFilter(a, b)
    local aData = a:getUserData()
    local bData = b:getUserData()

    if aData.tag == 'Bit' and bData.tag == 'Player' then
        if aData.object.owner == bData.object.id then return false end
    end

    if bData.tag == 'Bit' and aData.tag == 'Player' then
        if bData.object.owner == aData.object.id then return false end
    end

    return true
end

function World:init(isMenu)
    Signal.register('cam_shake', function(shake)
        self.camera:shake(shake)
    end)

    self.physicsWorld = love.physics.newWorld(0, 0, true)
    self.physicsWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)
    self.physicsWorld:setContactFilter(contactFilter)

    self.camera = Camera(8)
    self.planets = {}
    self.players = {}
    self.objects = {}
    self.asteroids = {}

    self:generate(isMenu)
end

function World:generate(isMenu)
    local joysticks
    if isMenu then
        joysticks = 0
    else
        joysticks = love.joystick.getJoystickCount()
    end

    local fakePlanets = {}
    local genWorld = love.physics.newWorld(0, 0, true)
    genWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

    for i = 1, joysticks + World.NUM_PLANETS do
        local x = getInRange(World.PLANET_STARTING_POSITION);
        local y = getInRange(World.PLANET_STARTING_POSITION)
        local radius = getInRange(World.PLANET_RADIUS)
        local planet = Body(genWorld, x, y, radius, true)
        table.insert(fakePlanets, planet)
    end

    while true do
        genWorld:update(1)

        local allAsleep = true
        for _, v in pairs(fakePlanets) do
            if v.body:isAwake() then
                allAsleep = false
            end
        end

        if allAsleep then break end
    end

    self.radius = 0

    for i = 1, joysticks + World.NUM_PLANETS do
        local v = Vector(fakePlanets[i].body:getX(), fakePlanets[i].body:getY())
        local planet
        if i == joysticks + 1 then
            planet = Sun(self.physicsWorld, v.x, v.y, fakePlanets[i].radius / (World.PLANET_RADIUS_SHRINK_FACTOR / 1.5), false)
        else
            planet = Planet(self.physicsWorld, v.x, v.y, fakePlanets[i].radius / World.PLANET_RADIUS_SHRINK_FACTOR,  (i <= joysticks))
        end

        table.insert(self.planets, planet)
        table.insert(self.objects, planet)

        if v:len() + fakePlanets[i].radius > self.radius then
            self.radius = v:len() + fakePlanets[i].radius
        end

        if i <= joysticks then
            local player = Player(i, self.physicsWorld, self, planet, self.planets, RNG:random(2 * math.pi))
            table.insert(self.objects, player)
            table.insert(self.players, player)
        end
    end

    for i = joysticks + 1, joysticks + World.NUM_PLANETS do
    end

    genWorld:destroy()

    for i = 1, 10 do
        local asteroid = Asteroid(self.physicsWorld, self.planets,
            RNG:random(1, 2) * self.radius * 2 * math.cos(RNG:random(0, math.pi * 2)),
            RNG:random(1, 2) * self.radius * 2 * math.sin(RNG:random(0, math.pi * 2)),
            RNG:random(15, 30))
        table.insert(self.objects, asteroid)
        table.insert(self.asteroids, asteroid)
    end
end

function World:addObject(object)
    table.insert(self.objects, object)
end

function World:update(dt)
    self.physicsWorld:update(dt)

    for key, object in pairs(self.objects) do
        if object:isDead() then
            if object.fixture:getUserData().tag == 'Asteroid' then
                for i = 1, 3 do
                    local bit = Bit(self.physicsWorld, self.planets, nil, object.body:getX(), object.body:getY())
                    bit.body:applyLinearImpulse(RNG:random(-100, 100), RNG:random(-100, 100))
                    table.insert(self.objects, bit)
                end
            elseif object.fixture:getUserData().tag == 'Player' then
                for i = 1, object.points do
                    local bit = Bit(self.physicsWorld, self.planets, nil, object.body:getX(), object.body:getY())
                    table.insert(self.objects, bit)
                end
                table.remove(self.players, object.id)
                if #self.players <= 1 then
                    Timer.after(1, function()
                        Signal.emit('new_round')
                    end)
                end
            end
            object.body:destroy()
            table.remove(self.objects, key)
        else
            object:update(dt)
        end
    end

    self:handleCamera(dt)
end

function World:handleCamera(dt)
    self.cameraPre = self.camera.pos

    local cameraVec = Vector()
    local playerDist = 0
    for _, player in pairs(self.players) do
        cameraVec = cameraVec + player.pos
        if player.pos:len() > playerDist then
            -- gets the farthest player distance
            playerDist = player.pos:len()
        end
    end

    if #self.players > 0 then
        cameraVec = cameraVec / #self.players
    else
        cameraVec = Vector()
    end

    self.camera:follow(cameraVec)

    local zoom = math.min(1, 300 / (50 + playerDist))
    self.camera:zoomTo(zoom)
    self.camera:update(dt)
end

function World:draw()
    World.SPACE_SHADER:send('iResolution', {
        love.graphics.getWidth(),
        love.graphics.getHeight()
    })
    World.SPACE_SHADER:send('iMouse', {
        -self.camera.pos.x / 100,
        -self.camera.pos.y / 100
    })
    World.SPACE_SHADER:send('iGlobalTime', 0)
    World.SPACE_SHADER:send('zoom', 1 / self.camera.zoom)
    love.graphics.setShader(World.SPACE_SHADER)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getDimensions())
    love.graphics.setShader()

    self.camera:draw(function()
        -- love.graphics.circle('line', 0, 0, self.radius)

        for _, object in pairs(self.objects) do
            object:draw()
        end
    end)
end

return World
