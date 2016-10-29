local Planet = require 'src.classes.planet'

local planets = {}
local delta

function love.load()
    for i = 1, 10 do
        table.insert(planets, Planet(i * 50, i * 50, 10))
    end
end

function love.update(dt)
    delta = dt
    for i = 1, 10 do
        planets[i]:update(dt)
    end
end

function love.draw()
    love.graphics.print(delta, 5, 5)
    for i = 1, 10 do
        planets[i]:draw()
    end
end
