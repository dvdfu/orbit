local Class = require 'modules.hump.class'
local World = require 'src.classes.world'
local Keyboard = require 'src.keyboard'
local Timer = require 'modules.hump.timer'

local Round = Class {

}

local world

function Round:init(roundNum)
    world = World()
    self.roundNum = roundNum
end

function Round:update(dt)
    Keyboard.update()
    world:update(dt)
    Timer.update(dt)
end

function Round:draw()
    world:draw()
    love.graphics.print("Round: ".. self.roundNum, 10, 10);
end

return Round
