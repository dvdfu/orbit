local Class = require 'modules.hump.class'
local Movable = require 'src.mixins.movable'
local Vector  = require 'modules.hump.vector'

local Asteroid = Class {
  SPRITE = love.graphics.newImage('res/asteroid.png'),
  EXPLODE_SOUND = love.audio.newSource('sfx/asteroid_explode.wav', "static"),
}
Asteroid:include(Movable);

function Asteroid:init(world, planets, x, y, radius)
  Movable.init(self, world, planets, x, y, radius)
  Asteroid.EXPLODE_SOUND:setVolume(.7)

  self.body:setLinearDamping(1)
  self.fixture:setUserData({
      object = self,
      tag = 'Asteroid',
      collide = function(data)
          Asteroid.EXPLODE_SOUND:play()
          self.dead = true;
          -- if data.tag == 'Planet' then
          --   self.dead = true;
          -- elseif data.tag == 'Player' then
          --   self.dead = true;
          -- elseif data.tag == 'Asteroid' then
          --   self.dead = true;
          -- elseif data.tag == 'Sun' then
          --   self.dead = true;
          -- end
      end,
      endCollide = function(data) end
  })
end

function Asteroid:update(dt)
  Movable.update(self, dt)
end

function Asteroid:draw()
  love.graphics.draw(Asteroid.SPRITE, self.pos.x, self.pos.y, self.body:getAngle(), self.radius / 16, self.radius / 16, 16, 16)
end

return Asteroid
