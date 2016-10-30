RNG = love.math.newRandomGenerator(love.timer.getTime())

GameState = require "modules.hump.gamestate"
Const = require 'src.const'
Joysticks = require 'src.joysticks'
Keyboard = require 'src.keyboard'
Round = require 'src.round'
-- local World = require 'src.classes.world'
--
-- local world
local round
local menu = {}
local game = {}
local pause = {}
local over = {}

function love.load()
    Joysticks.init()
    GameState.registerEvents()
    GameState.switch(menu)
    -- world = World()
end

-- function love.update(dt)
    -- world:update(dt)
    -- Keyboard.update()
-- end

function love.draw()
    -- world:draw()
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'enter' then
      -- if(Gamestate.current())
    end
end

function menu:enter(from)
    self.from = from;
end

function menu:update(dt)
end

function menu:keypressed(key,code)
    if key == 'enter' then
      GameState.switch(game)
    end
end

function menu:draw()
    love.graphics.print(GameState.current(),love.graphics.getWidth()/2, love.graphics.getHeight()/2)
    -- love.graphics.print("Press Enter to Start", love.graphics.getWidth()/2, love.graphics.getHeight()/2);
end

function game:enter(from)
    self.from = from;
end

function game:update(dt)
    round:update(dt)
    if key == 'enter' then
      GameState.switch(game)
    end
end

function game:keypressed(key, code)
    if key == 'escape' then
      GameState.switch(pause)
    end
end

function game:draw()
    round:draw()
    --love.graphics.print("GAME Press Enter to Start", love.graphics.getWidth()/2, love.graphics.getHeight()/2);
end

function pause:enter(from)
    self.from = from;
end

function pause:keypressed(key, code)
    if key == 'escape' then
      GameState.switch(game)
    end
end

function pause:update(dt)
end

function pause:draw()
    love.graphics.print("PAUSE Press ESCAPE to Resume", love.graphics.getWidth()/2, love.graphics.getHeight()/2);
end

function over:enter(from)
    self.from = from;
end

function pause:keypressed(key, code)
    if key == 'enter' then
      round = Round()
      GameState.switch(game)
    end
end

function over:update(dt)
end

function over:draw()
    love.graphics.print("OVER Press Enter to Start", love.graphics.getWidth()/2, love.graphics.getHeight()/2);
end
