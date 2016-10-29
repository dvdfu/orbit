local Class = require 'modules.hump.class'
local Camera = require 'src.camera'
local Bit = require 'src.classes.bit'
local Planet = require 'src.classes.planet'
local Player = require 'src.classes.player'
local Body = require 'src.mixins.body'

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
    self.physicsWorld = love.physics.newWorld(0, 0, true)
    self.physicsWorld:setCallbacks(beginContact, endContact, preSolve, postSolve)

    self.planets = {}
    self.bits = {}
    self.player = Player(self.physicsWorld, self.planets, 400, 400)

    self.camera = Camera(20)
    self.camera:follow(self.player)

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
    self.player:update(dt)

    for _, bit in pairs(self.bits) do
        bit:update(dt)
    end

    self.camera:update(dt)
end

function World:draw()
    self.camera:draw(function()
        love.graphics.circle('line', 0, 0, World.RADIUS)
        self.player:draw()

        for _, planet in pairs(self.planets) do
            planet:draw()
        end

        for _, bit in pairs(self.bits) do
            bit:draw()
        end
    end)
end

return World
