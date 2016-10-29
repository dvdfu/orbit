local Class = require 'modules.hump.class'
local Bit = require 'src.classes.bit'

local Weapon = Class {}

function Weapon:init(level, player, type)
    self.level = level
    self.player = player

    self:setWeaponType(type)

    self.fireTimer = self.fireRate
end

function Weapon:update(dt)
    self.fireTimer = self.fireTimer - dt
end

function Weapon:setWeaponType(type)
    self.fireRate = type.fireRate
    self.bulletSpeed = type.bulletSpeed
end

function Weapon:shoot()
    if self.fireTimer <= 0 then
        local bit = Bit(self.level.physicsWorld, self.level.planets, self.player, self.player.pos.x, self.player.pos.y)
        local ix, iy = self.bulletSpeed * math.cos(self.player.direction), self.bulletSpeed * math.sin(self.player.direction)
        bit.body:applyLinearImpulse(ix, iy)
        self.level:addObject(bit)

        self.fireTimer = self.fireRate
    end
end

return Weapon
