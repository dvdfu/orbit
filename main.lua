RNG = love.math.newRandomGenerator(love.timer.getTime())

-- love.graphics.setLineStyle('rough')
-- love.graphics.setDefaultFilter('nearest', 'nearest')
-- love.graphics.setBackgroundColor(0, 0, 0)

Const = require 'src.const'
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

function love.keypressed(key, scancode, isrepeat)
    if key == 'r' then
        world = World()
    end
end
