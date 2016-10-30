
local Class   = require 'modules.hump.class'
local Signal  = require 'modules.hump.signal'
local Timer   = require 'modules.hump.timer'
local Vector  = require 'modules.hump.vector'
local Movable = require 'src.mixins.movable'

local Debris = Class {
    SPRITE = love.graphics.newImage('res/debris.png')
}
Debris:include(Movable)

function Debris:init(world, planets, owner, x, y)
    Movable.init(self, world, planets, x, y, 4)
    self.body:setBullet(true)
    self.fixture:setRestitution(1)

    self.fixture:setUserData({
        object = self,
        tag = 'Debris',
        collide = function(data) end,
        endCollide = function(data) end
    })

    self.owner = owner or 0
    self.deadTimer = Timer.new()
    self.deadTimer:after(3, function()
        self.dead = true
    end)
end

function Debris:update(dt)
    Movable.update(self, dt)
    self.deadTimer:update(dt)
end

function Debris:draw()
    love.graphics.setColor(Const.colors[self.owner]())
    love.graphics.draw(Debris.SPRITE, self.pos.x, self.pos.y, self.body:getAngle(), 0.5, 0.5, 8, 8)
    love.graphics.setColor(255, 255, 255, 255)
end

return Debris
