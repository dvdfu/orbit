local Const = {}

Const.colors = {
    [0] = function() return 255, 255, 255, 255 end,
    [1] = function() return 255, 128, 32, 255 end,
    [2] = function() return 128, 255, 32, 255 end,
    [3] = function() return 32, 128, 255, 255 end,
    [4] = function() return 255, 255, 128, 255 end,
}

Const.weapons = {
    pistol = {
        fireRate = 0.25,
        bulletSpeed = 100
    },
    machineGun = {
        fireRate = 0.05,
        bulletSpeed = 200
    }
}

return Const
