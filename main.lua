RNG = love.math.newRandomGenerator(love.timer.getTime())

local Signal = require 'modules.hump.signal'
Timer = require 'modules.hump.timer'
Const = require 'src.const'
Joysticks = require 'src.joysticks'
Keyboard = require 'src.keyboard'

local World = require 'src.classes.world'

local world

function love.load()
    Signal.register('restart_level', function()
        world = World()
    end)
    Joysticks.init()
    world = World()
end

function love.update(dt)
    world:update(dt)
    Timer.update(dt)
    Keyboard.update()
end

function love.draw()
    world:draw()
end
