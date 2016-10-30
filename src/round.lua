local Class = require 'modules.hump.class'
local World = require 'src.classes.world'
local Keyboard = require 'src.keyboard'

local Round = Class {
    NUM_ROUNDS = 3
}

local world

function Round:init()
    self.currRound = 1;
    world = World()
end

function Round:update(dt)
    Keyboard.update()
    world:update(dt)
    --need some time of callback to know world has finished a round
    --incrememnt round and start new world if < NUM_ROUNDS
    --else end game, switch to over
end

function Round:draw()
    world:draw()
end
