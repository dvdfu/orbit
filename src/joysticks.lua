local Joysticks = {}
local self = {}

function Joysticks.init()
    self.sticks = love.joystick.getJoysticks()
end

function Joysticks.update()
    for i = 1, love.joystick.getJoystickCount() do
        sticks[i] = love.joystick.getJoysticks()[i]
    end
end

function Joysticks.get(i)
    return self.sticks[i]
end

return Joysticks
