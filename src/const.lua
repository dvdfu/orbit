local Const = {}

Const.colors = {
    [1] = function() return 255, 0, 0 end,
    [2] = function() return 0, 255, 0 end,
    [3] = function() return 0, 0, 255 end,
}

Const.weapons = {
    pistol = {
        fireRate = 0.25,
        bulletSpeed = 8
    },
    machineGun = {
        fireRate = 0.05,
        bulletSpeed = 10
    }
}

return Const
