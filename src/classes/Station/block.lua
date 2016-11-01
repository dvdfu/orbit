local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'

local Block = Class {
    SPRITE = love.graphics.newImage('res/block.png'),
    SHADER = love.graphics.newShader(Const.gradientShader),
    LENGTH = 16
}
Block:include(Body)

function Block:init(world, x, y)
    Body.init(self, world, x, y, Block.LENGTH/2)
    self.on = false

    self.particles = love.graphics.newParticleSystem(Block.SPRITE)
    self.particles:setParticleLifetime(1, 2)
    self.particles:setSpread(math.pi * 2)
    self.particles:setSizes(Block.LENGTH/128)
    self.particles:setSpeed(0, 20)
    self.particles:setColors(255, 255, 255, 255, 255, 255, 255, 0)
end

function Block:update(dt)
    self.fixture:setUserData({
        object = self,
        tag = 'Block',
        collide = function(data)
            if data.tag == 'Player' then
                self.on = true
            end
        end,
        endCollide = function(data)
            if data.tag == 'Player' then
                self.on = false
            end
        end
    })
    if self.on then
        self.particles:setPosition(self.pos:unpack())
        self.particles:emit(5)
        self.particles:update(dt)
    end
end

function Block:draw()
    local x = self.pos.x
    local y = self.pos.y
    love.graphics.setShader(Block.SHADER)
    love.graphics.draw(Block.SPRITE, x, y)
    love.graphics.setShader()
    if self.on then
        love.graphics.setColor(255, 200, 128)
        love.graphics.setBlendMode('add')
        love.graphics.draw(self.particles)
        love.graphics.setBlendMode('alpha')
        love.graphics.setColor(255, 255, 255)
    end
end

return Block
