local Class = require 'modules.hump.class'
local Planet = require 'src.classes.planet'

local World = Class {}

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
    table.insert(self.planets, Planet(self.physicsWorld, 200, 200, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 200, 400, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 400, 200, 50))
    table.insert(self.planets, Planet(self.physicsWorld, 400, 400, 50))
end

function World:update(dt)
    self.physicsWorld:update(dt)
end

return World
