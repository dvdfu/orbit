local Keyboard = {}

local keyboard = setmetatable({}, {
    __index = function(table, key)
        return {
            pressed = false,
            released = false,
            isDown = false
        }
    end
})

function love.keypressed(key)
    if(key == 'escape') then
      love.event.quit()
    end
    keyboard[key] = keyboard[key]
    keyboard[key].pressed = true
end

function love.keyreleased(key)
    keyboard[key] = keyboard[key]
    keyboard[key].released = true
end

function Keyboard.update()
    for k, v in pairs(keyboard) do
        v.pressed = false
        v.released = false
        v.isDown = love.keyboard.isDown(k)
    end
end

function Keyboard.pressed(key)
    return keyboard[key].pressed
end

function Keyboard.released(key)
    return keyboard[key].released
end

function Keyboard.isDown(key)
    return keyboard[key].isDown
end

function Keyboard.allDown(keys)
    for _, key in pairs(keys) do
        if not keyboard[key].isDown then return false end
    end
    return true
end

function Keyboard.anyDown(keys)
    for _, key in pairs(keys) do
        if keyboard[key].isDown then return true end
    end
    return false
end

return Keyboard
