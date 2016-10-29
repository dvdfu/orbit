local Class  = require 'modules.hump.class'
local Signal = require 'modules.hump.signal'
local Vector = require 'modules.hump.vector'
local Camera = require 'src.camera'
local Bit    = require 'src.classes.bit'
local Planet = require 'src.classes.planet'
local Player = require 'src.classes.player'
local Body   = require 'src.mixins.body'
local Asteroid = require 'src.classes.asteroid'

local World = Class {
    NUM_PLANETS = 4,

    -- Generation Parameters
    PLANET_STARTING_POSITION = { low = -10, high = 10 },
    PLANET_RADIUS = { low = 100, high = 200 },
    PLANET_RADIUS_SHRINK_FACTOR = 3
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

function World:init()
    Signal.register('cam_shake', function(shake)
        self.camera:shake(shake)
    end)

    self.physicsWorld = love.physics.newWorld(0, 0, true)
    self.physicsWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self.camera = Camera(8)
    self.planets = {}
    self.players = {}
    self.objects = {}
    self.asteroids = {}

    self:generate()
end

function World:generate()
    self:generatePlanets()

    for i = 1, 100 do
        local bit = Bit(self.physicsWorld, self.planets, 0, 0)
        bit.body:applyLinearImpulse(RNG:random(8), RNG:random(8))
        table.insert(self.objects, bit)
    end

    for i = 1, 5 do
        local asteroid = Asteroid(self.physicsWorld, self.planets, RNG:random(-self.radius, self.radius), RNG:random(-self.radius, self.radius), RNG:random(15, 30))
        table.insert(self.objects, asteroid)
        table.insert(self.asteroids, asteroid)
    end
end

function World:generatePlanets()
    local fakePlanets = {}
    local genWorld = love.physics.newWorld(0, 0, true)
    genWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

    for i = 1, World.NUM_PLANETS do
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
    for i = 1, World.NUM_PLANETS do
        local v = Vector(fakePlanets[i].body:getX(), fakePlanets[i].body:getY())
        local planet = Planet(self.physicsWorld, v.x, v.y, fakePlanets[i].radius / World.PLANET_RADIUS_SHRINK_FACTOR, false)

        table.insert(self.planets, planet)
        table.insert(self.objects, planet)

        if v:len() + fakePlanets[i].radius > self.radius then
            self.radius = v:len() + fakePlanets[i].radius
        end

        local player = Player(self.physicsWorld, planet, RNG:random(2 * math.pi))
        table.insert(self.objects, player)
        table.insert(self.players, player)
    end

    genWorld:destroy()
end

function World:update(dt)
    self.physicsWorld:update(dt)

    for key, object in pairs(self.objects) do
        if object:isDead() then
            if(object.fixture:getUserData().tag == 'Asteroid') then
              for i = 1, 5 do
                  local bit = Bit(self.physicsWorld, self.planets, object.body:getX(), object.body:getY())
                  bit.body:applyLinearImpulse(RNG:random(8), RNG:random(8))
                  table.insert(self.objects, bit)
              end
            end
            object.body:destroy()
            table.remove(self.objects, key)
        else
            object:update(dt)
        end
    end

    self:handleCamera()
end

function World:handleCamera()
    local cameraVec = Vector()
    local playerDist = 0
    for _, player in pairs(self.players) do
        cameraVec = cameraVec + player.pos
        if player.pos:len() > playerDist then
            -- gets the farthest player distance
            playerDist = player.pos:len()
        end
    end

    cameraVec = cameraVec / #self.players
    self.camera:follow(cameraVec)

    local zoom = math.min(1, 400 / (50 + playerDist))
    self.camera:zoomTo(zoom)
    self.camera:update(dt)
end

function World:draw()
    self.camera:draw(function()
        love.graphics.circle('line', 0, 0, self.radius)

        for _, object in pairs(self.objects) do
            object:draw()
        end
    end)
end

return World
