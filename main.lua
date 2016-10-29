local M = require 'noise'

function love.load()
end

function love.update(dt)
end

function love.draw()
    for i = 1, 100 do
        for j = 1, 100 do
            local a = M.Simplex2D(i, j)
            love.graphics.setColor(a * 255, a * 255, a * 255)
            love.graphics.points(i, j)
        end
    end
end
