local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'

local Planet = Class {
    density = 1
}
Planet:include(Body)

function Planet:init(world, x, y, radius)
    Body.init(self, world, x, y, radius)
    self.fixture:setFriction(1)
end

return Planet
