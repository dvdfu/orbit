local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'

local Block = Class {
  SPRITE = love.graphics.newImage('res/block.png')
}
Planet:include(Body)

function Block:init(world, x, y, n)

end

function Block:update(dt)

end

function Block:draw()

end

return Block
