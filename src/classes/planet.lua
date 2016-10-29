local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Circle = require 'src.classes.circle'

local Planet = Class {
    density = 1
}
Planet:include(Circle)

function Planet:init(x, y, radius)
    Circle.init(self, x, y, radius)
end

return Planet
