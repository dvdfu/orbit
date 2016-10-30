RNG = love.math.newRandomGenerator(love.timer.getTime())

local M = require 'noise'

local Signal = require 'modules.hump.signal'
Timer = require 'modules.hump.timer'
GameState = require "modules.hump.gamestate"
Const = require 'src.const'
Joysticks = require 'src.joysticks'
Keyboard = require 'src.keyboard'
Round = require 'src.round'

MAX_ROUNDS = 5
local roundNum
local round
local menu = {}
local game = {}
local pause = {}
local over = {}

function love.load()
    roundNum = 1
    Signal.register('new_round', function()
        roundNum = roundNum + 1
        if roundNum <= MAX_ROUNDS then
          round = Round(roundNum)
        else
          GameState.switch(over)
        end
    end)
    Joysticks.init()
    GameState.registerEvents()
    GameState.switch(menu)
    round = Round(roundNum)
end

function menu:enter(from)
    self.from = from;
end

function menu:update(dt)
end

function menu:keypressed(key,code)
    if key == 'return' then
      GameState.switch(game)
    end
end

function menu:draw()
    love.graphics.print("Press Enter to Start", love.graphics.getWidth()/2, love.graphics.getHeight()/2);
end

function game:enter(from)
    self.from = from;
end

function game:update(dt)
    round:update(dt)
end

function game:keypressed(key, code)
    if key == 'escape' then
      GameState.switch(pause)
    elseif key == 'r' then
      Signal.emit('new_round')
    end
end

function game:draw()
    round:draw()

    for i = 1, 100 do
        for j = 1, 100 do
            local a = M.Simplex2D(i, j)
            love.graphics.setColor(a * 255, a * 255, a * 255)
            love.graphics.points(i, j)
        end
    end
end

function pause:enter(from)
    self.from = from;
end

function pause:keypressed(key, code)
    if key == 'escape' then
      GameState.switch(game)
    elseif key == 'q' then
      love.event.quit()
    end
end

function pause:update(dt)
end

function pause:draw()
    love.graphics.print("PAUSE Press ESCAPE to RESUME", love.graphics.getWidth()/2, love.graphics.getHeight()/2);
    love.graphics.print("PAUSE Press Q to QUIT", love.graphics.getWidth()/2, love.graphics.getHeight()/2 + 50);
end

function over:enter(from)
    self.from = from;
end

function over:keypressed(key, code)
    if key == 'return' then
      roundNum = 1
      round = Round(roundNum)
      GameState.switch(game)
    end
end

function over:update(dt)
end

function over:draw()
    love.graphics.print("OVER Press Enter to Start", love.graphics.getWidth()/2, love.graphics.getHeight()/2);
end
