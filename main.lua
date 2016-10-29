Keyboard = require 'src.keyboard'

local Planet = require 'src.classes.planet'
local Player = require 'src.classes.player'

local world
local planets = {}
local player

local function beginContact(a, b, coll)
    local aData = a:getUserData()
    local bData = b:getUserData()

    if aData and bData then
        aData.collide(bData)
        bData.collide(aData)
    end
end
local function endContact(a, b, coll) end
local function preSolve(a, b, coll) end
local function postSolve(a, b, coll, normal, tangent) end

function love.load()
    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    table.insert(planets, Planet(world, 200, 200, 50))
    table.insert(planets, Planet(world, 200, 400, 50))
    table.insert(planets, Planet(world, 400, 200, 50))
    table.insert(planets, Planet(world, 400, 400, 50))

    player = Player(world, planets, 100, 0)
end

function love.update(dt)
    player:update(dt)
    world:update(dt)

    Keyboard.update()
end

function love.draw()
    player:draw()
    for _, planet in pairs(planets) do
        planet:draw()
    end
end
