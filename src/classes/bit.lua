local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Bit = Class {
    density = 1
}
Bit:include(Movable)

function Bit:init(world, planets, x, y)
    Movable.init(self, world, planets, x, y, 3)

    self.body:setFixedRotation(true)
    self.fixture:setRestitution(0.6)

    self.fixture:setUserData({
        object = self,
        tag = 'Bit',
        collide = function(data) end,
        endCollide = function(data) end
    })
end

return Bit