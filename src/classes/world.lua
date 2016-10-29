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
    RADIUS = 300
}

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

    self.fakePlanets = {}
    self.planets = {}
    self.players = {}
    self.objects = {}
    self.asteroids = {}

    self:generate()

    local player = Player(self.physicsWorld, self.planets, 200, 20)
    table.insert(self.objects, player)
    table.insert(self.players, player)

    -- player = Player(self.physicsWorld, self.planets, -200, 20)
    -- table.insert(self.objects, player)
    -- table.insert(self.players, player)
    self.camera = Camera(20)
end

function World:generate()
    self:generatePlanets()

    for i = 1, 100 do
        local bit = Bit(self.physicsWorld, self.planets, 0, 0)
        bit.body:applyLinearImpulse(math.random(8), math.random(8))
        table.insert(self.objects, bit)
    end

    for i = 1, 5 do
        local asteroid = Asteroid(self.physicsWorld, self.planets, math.random(-World.RADIUS, World.RADIUS), math.random(-World.RADIUS, World.RADIUS), math.random(15, 30))
        table.insert(self.objects, asteroid)
        table.insert(self.asteroids, asteroid)
    end
end

function World:generatePlanets()
    local genWorld = love.physics.newWorld(0, 0, true)
    genWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

    local numberOfPlanets = 59

    for i = 1, numberOfPlanets do
        local planet = Body(genWorld, math.random(-10, 10), math.random(-10, 10), math.random(100, 200), true)
        table.insert(self.fakePlanets, planet)
    end

    local stillResolving = true
    while stillResolving do
        genWorld:update(1)

        for _, v in pairs(self.fakePlanets) do
            stillResolving = false
            if v.body:isAwake() then
                stillResolving = true
            end
        end
    end

    for i = 1, numberOfPlanets do
        local planet = Planet(self.physicsWorld, self.fakePlanets[i].body:getX(), self.fakePlanets[i].body:getY(), self.fakePlanets[i].radius / 2, false)
        table.insert(self.planets, planet)
        table.insert(self.objects, planet)
    end
end

function World:update(dt)
    self.physicsWorld:update(dt)

    for key, object in pairs(self.objects) do
        if object:isDead() then
            if(object.fixture:getUserData().tag == 'Asteroid') then
              for i = 1, 5 do
                  local bit = Bit(self.physicsWorld, self.planets, object.body:getX(), object.body:getY())
                  bit.body:applyLinearImpulse(math.random(8), math.random(8))
                  table.insert(self.objects, bit)
              end
            end
            object.body:destroy()
            table.remove(self.objects, key)
        else
            object:update(dt)
        end
    end

    local cameraVec = Vector()
    for _, player in pairs(self.players) do
        cameraVec = cameraVec + player.pos
    end
    cameraVec = cameraVec / #self.players

    self.camera:follow(cameraVec)
    self.camera:update(dt)
end

function World:draw()
    self.camera:draw(function()
        love.graphics.circle('line', 0, 0, World.RADIUS)

        for _, object in pairs(self.objects) do
            object:draw()
        end
    end)
end

return World
