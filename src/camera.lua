local Class  = require 'modules.hump.class'
local Timer  = require 'modules.hump.timer'
local Vector = require 'modules.hump.vector'

local Camera = Class {}

function Camera:init(damping)
    self.damping = damping or 1 -- camera movement damping
    self.target = nil
    self.pos = Vector()
    self.shakeTimer = Timer.new()
    self.shakeVec = Vector()
end

function Camera:update(dt)
    self.shakeTimer:update(dt)

    -- damp camera movement if non-trivial
    local delta = self.target.pos - self.pos
    if delta:len2() > 0.1 then
        delta = delta / self.damping
    end

    self.pos = self.pos + delta
end

function Camera:follow(target)
    self.target = target
end

function Camera:lookAt(target)
    self:follow(target)
    self.pos = target
end

function Camera:shake(shake, direction)
    shake = shake or 4
    direction = direction or math.random(math.pi * 2)
    self.shakeVec = Vector(shake, 0)
    self.shakeVec:rotateInplace(-direction)

    self.shakeTimer:clear()
    self.shakeTimer:tween(shake * 4, self.shakeVec, {
        x = 0,
        y = 0
    }, 'out-elastic')
end

function Camera:getPosition()
    return (self.pos - self.shakeVec):unpack()
end

function Camera:draw(callback)
    local halfScreen = Vector(love.graphics.getDimensions()) / 2
    local translation = halfScreen - self.pos
    translation = translation + self.shakeVec

    love.graphics.push()
    love.graphics.translate(translation:unpack())
    callback()
    love.graphics.pop()
end

return Camera
