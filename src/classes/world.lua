local Class  = require 'modules.hump.class'
local Signal = require 'modules.hump.signal'
local Camera = require 'src.camera'
local Bit    = require 'src.classes.bit'
local Planet = require 'src.classes.planet'
local Player = require 'src.classes.player'
local Body   = require 'src.mixins.body'

local World = Class {
    RADIUS = 320
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

    self.planets = {}
    self.bits = {}
    self.players = {}
    local player = Player(self.physicsWorld, self.planets, 200, 20)
    table.insert(self.players, player)

    player = Player(self.physicsWorld, self.planets, -200, 20)
    table.insert(self.players, player)

    self.camera = Camera(20)
    self.camera:follow(player)

    self:generate()
end

function World:generate()
    table.insert(self.planets, Planet(self.physicsWorld, -100, -100, 50))
    table.insert(self.planets, Planet(self.physicsWorld, -100, 100, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 100, -100, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 100, 100, 50))

    for i = 1, 100 do
        local bit = Bit(self.physicsWorld, self.planets, math.random(800), math.random(800))
        bit.body:applyLinearImpulse(math.random(8), math.random(8))
        table.insert(self.bits, bit)
    end
end

function World:update(dt)
    self.physicsWorld:update(dt)

    for _, bit in pairs(self.bits) do
        bit:update(dt)
    end

    for _, player in pairs(self.players) do
        player:update(dt)
    end

    self.camera:update(dt)
end

function World:draw()
    self.camera:draw(function()
        love.graphics.circle('line', 0, 0, World.RADIUS)

        for _, player in pairs(self.players) do
            player:draw()
        end

        for _, planet in pairs(self.planets) do
            planet:draw()
        end

        for _, bit in pairs(self.bits) do
            bit:draw()
        end
    end)
end

return World
