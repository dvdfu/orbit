local Class = require 'modules.hump.class'
local Bit = require 'src.classes.bit'
local Planet = require 'src.classes.planet'
local Body = require 'src.mixins.body'

local World = Class {
    CENTER_X = 400,
    CENTER_Y = 300,
    RADIUS = 275
}

local physicsWorld
local planets

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

    self:generate()
end

function World:update(dt)
    self.physicsWorld:update(dt)


    for _, bit in pairs(self.bits) do
        bit:update(dt)
    end
end

function World:draw()
    love.graphics.circle('line', World.CENTER_X, World.CENTER_Y, World.RADIUS)

    for _, planet in pairs(self.planets) do
        planet:draw()
    end

    for _, bit in pairs(self.bits) do
        bit:draw()
    end
end

function World:generate()
    table.insert(self.planets, Planet(self.physicsWorld, 200, 200, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 200, 400, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 400, 200, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 400, 400, 50))

    for i = 1, 100 do
        local bit = Bit(self.physicsWorld, self.planets, math.random(800), math.random(800))
        bit.body:applyLinearImpulse(math.random(8), math.random(8))
        table.insert(self.bits, bit)
    end
end

return World
