local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Player = Class {
    density = 1
}
Player:include(Movable)

function Player:init(world, planets, x, y)
    Movable.init(self, world, planets, x, y, 16)
    self.planets = planets
    self.body:setLinearDamping(0.5)
    self.body:setAngularDamping(0.5)
end

return Player
