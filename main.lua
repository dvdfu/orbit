RNG = love.math.newRandomGenerator(love.timer.getTime())

local Signal = require 'modules.hump.signal'
Timer = require 'modules.hump.timer'
GameState = require "modules.hump.gamestate"
Const = require 'src.const'
Joysticks = require 'src.joysticks'
Keyboard = require 'src.keyboard'
Round = require 'src.round'
World = require 'src.classes.world'

MAX_ROUNDS = 5

local roundNum
local round
local menuWorld
local menu = {}
local game = {}
local pause = {}
local over = {}

function drawCenteredTextAtHeight(msg, y)
    love.graphics.push()
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf(msg, 0, y, love.graphics.getWidth(), 'center')
    love.graphics.pop()
end

function fadeScreen()
    love.graphics.push()
    love.graphics.setColor(0, 0, 0, 200)
    love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.pop()
end

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

    Const.fonts.titleFont:setFilter('nearest', 'nearest')
end

function menu:enter(from)
    self.from = from;
    menuWorld = World(true)
end

function menu:update(dt)
    menuWorld:update(dt)
end

function menu:keypressed(key,code)
    if key == 'return' then
      GameState.switch(game)
    end
end

function menu:draw()
    menuWorld:draw()

    fadeScreen()
    love.graphics.setFont(Const.fonts.titleFont)
    drawCenteredTextAtHeight("Press Enter to Start", love.graphics.getHeight() / 2)
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
    round:draw()

    fadeScreen()

    love.graphics.setFont(Const.fonts.titleFont)
    drawCenteredTextAtHeight("Paused", 10);
    drawCenteredTextAtHeight("Press ESCAPE to RESUME", love.graphics.getHeight() / 2 - 25);
    drawCenteredTextAtHeight("Press Q to QUIT", love.graphics.getHeight()/2 + 25);
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
