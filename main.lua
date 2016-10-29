RNG = love.math.newRandomGenerator(love.timer.getTime())

Joysticks = require 'src.joysticks'
Keyboard = require 'src.keyboard'

local World = require 'src.classes.world'

local world

function love.load()
    Joysticks.init()
    world = World()
end

function love.update(dt)
    world:update(dt)
    Keyboard.update()
end

function love.draw()
    world:draw()
end
