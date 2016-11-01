local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'
local Block = require 'src.classes.Station.block'

local Station = Class {
    density = 1
}
Station:include(Body)

function Station:init(world, planet, x, y, radius)
    Body.init(self, world, x, y, Block.LENGTH*n)
    self.planet = planet
    self.blocks = {}
    self.radius = radius;
    self.angle = RNG:random(0, math.pi * 2)
    self.speed = RNG:random(0.5, 1.5)
    self.rotation = RNG:random(0, math.pi * 2)
    self.fixture:setFriction(1)
    self.fixture:setUserData({
        object = self,
        tag = 'Station',
        collide = function(data) end,
        endCollide = function(data) end
    })


    local x = 0
    local y = 0
    for i=1, (radius)^2/Block.LENGTH do
        blocks[i] = Block(world)
        x = x + 1;
        if i%radius == 0 then
            y = y + 1;
            x = 0;
        end
    end
end

function Station:update(dt)
  Body.update(self, dt)
  rotate(dt)
  for _, v in pairs(self.blocks) do
      v:update(dt)
  end
end

function Station:draw()
    for _, v in pairs(self.blocks) do
        v:draw()
    end
end

function rotate(dt)
    self.angle = self.angle + dt/2 * self.speed;
    if self.angle >= 2*math.pi then
      self.angle = self.angle - 0;
    end
    self.body:setPosition(
        (self.radius+self.planet.radius + 50)*math.cos(self.angle) + self.planet.pos.x
      , (self.radius+self.planet.radius + 30)*math.sin(self.angle) + self.planet.pos.y)
end
return Station
