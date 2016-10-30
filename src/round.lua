local Class = require 'modules.hump.class'
local World = require 'src.classes.world'
local Keyboard = require 'src.keyboard'
local Timer = require 'modules.hump.timer'

local Round = Class {
    ROUND_BEGIN_TIME = 2
}

local world

function drawCenteredTextAtHeight(msg, y, dontSetColor)
    love.graphics.push()

    if dontSetColor == nil then
        love.graphics.setColor(255, 255, 255)
    end

    love.graphics.printf(msg, 0, y, love.graphics.getWidth(), 'center')
    love.graphics.pop()
end

function Round:init(roundNum, winningPlayer)
    world = World()
    self.roundNum = roundNum

    self.startTime = 0
    self.winningPlayer = winningPlayer
    self.num = math.random(1, #Const.quotes)
end

function Round:update(dt)
    if self.startTime < Round.ROUND_BEGIN_TIME then
        self.startTime = self.startTime + dt
    else
        Keyboard.update()
        world:update(dt)
        Timer.update(dt)
    end
end

function Round:draw()
    if self.startTime < Round.ROUND_BEGIN_TIME then
        love.graphics.setFont(Const.fonts.titleFont)
        drawCenteredTextAtHeight("Beginning round #".. self.roundNum, love.graphics.getHeight() / 2 - 50);

        if self.winningPlayer then
            local r, g, b, a = Const.colors[self.winningPlayer]()
            love.graphics.setColor(r, g, b, a)
            drawCenteredTextAtHeight("Player ".. self.winningPlayer .. ' is winning', love.graphics.getHeight() / 2 + 50, false);
        else
            drawCenteredTextAtHeight("It's all tied up", love.graphics.getHeight() / 2);
        end

        drawCenteredTextAtHeight(Const.quotes[self.num], love.graphics.getHeight() - love.graphics.getHeight() / 5);
    else
        world:draw()

        love.graphics.setFont(Const.fonts.titleFont)
        love.graphics.print("Round: ".. self.roundNum, 10, 10);
    end
end

return Round
