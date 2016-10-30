local Class = require 'modules.hump.class'
local Vector = require 'modules.hump.vector'
local Body = require 'src.mixins.body'
local Moon = require 'src.classes.moon'

local Planet = Class {
    SPRITES = {
        [1] = love.graphics.newImage('res/water_planet.png'),
        [2] = love.graphics.newImage('res/brown_planet.png'),
        [3] = love.graphics.newImage('res/pink_planet.png'),
    },
    SHADER = love.graphics.newShader(Const.gradientShader)
}
Planet:include(Body)

function Planet:init(world, x, y, radius)
    Body.init(self, world, x, y, radius)
    self.moon = Moon(world, self, x - radius*2, y, RNG:random(20, 40))
    self.fixture:setFriction(1)

    self.fixture:setUserData({
        object = self,
        tag = 'Planet',
        collide = function(data) end,
        endCollide = function(data) end
    })

    self.sprite = RNG:random(1, 3)
    self.rotation = RNG:random(0, math.pi * 2)
end

function Planet:update(dt)
    self.moon:update(dt)
end

function Planet:draw(dt)
    -- Planet.SHADER:send('point', {
    --     1,
    --     0
    -- })
    love.graphics.setShader(Planet.SHADER)
    love.graphics.draw(Planet.SPRITES[self.sprite], self.pos.x, self.pos.y, 0, self.radius / 32, self.radius / 32, 32, 32)
    love.graphics.setShader()
    self.moon:draw()
end

return Planet
