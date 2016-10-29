local Planet = require 'src.classes.planet'
local Player = require 'src.classes.player'

local world
local planets = {}
local player

function love.load()
    world = love.physics.newWorld(0, 0, true)
    table.insert(planets, Planet(200, 200, 50))

    player = Player(world, planets, 100, 100)
end

function love.update(dt)
    player:update(dt)
    world:update(dt)
end

function love.draw()
    player:draw()
    for _, planet in pairs(planets) do
        planet:draw()
    end
end
