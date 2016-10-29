Keyboard = require 'src.keyboard'

local World = require 'src.classes.world'
local Player = require 'src.classes.player'

local world
local player

function love.load()
    world = World()
    player = Player(world.physicsWorld, world.planets, 100, 0)
end

function love.update(dt)
    player:update(dt)
    world:update(dt)

    Keyboard.update()
end

function love.draw()
    player:draw()
    world:draw()
end
