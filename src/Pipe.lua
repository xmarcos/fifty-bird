--[[
    Pipe Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The Pipe class represents the pipes that randomly spawn in our game, which act as our primary obstacles.
    The pipes can stick out a random distance from the top or bottom of the screen. When the player collides
    with one of them, it's game over. Rather than our bird actually moving through the screen horizontally,
    the pipes themselves scroll through the game to give the illusion of player movement.
]]

Pipe = Class{}

local PIPE_SPEED = 60
local PIPE_WIDTH = 70
local PIPE_HEIGHT = 288
-- minimum height to allow showing the pipe opening (32) and 2 pixels of the pipe
local PIPE_MIN_HEIGHT = 34

-- since we only want the image loaded once, not per instantation, define it externally
local PIPE_IMAGE = love.graphics.newImage('images/pipe.png')
PIPE_IMAGE:setFilter('nearest','nearest')

function Pipe:init(orientation, x, y)
    self.x = x
    self.y = y
    self.orientation = orientation
end

function Pipe:WIDTH()
    return PIPE_WIDTH
end

function Pipe:HEIGHT()
    return PIPE_HEIGHT
end

function Pipe:MIN_HEIGHT()
    return PIPE_MIN_HEIGHT
end

function Pipe:SPEED()
    return PIPE_SPEED
end

function Pipe:update(dt)

end

function Pipe:render()
    love.graphics.draw(PIPE_IMAGE, self.x,

        -- shift pipe rendering down by its height if flipped vertically
        (self.orientation == 'top' and self.y + self:HEIGHT() or self.y),

        -- scaling by -1 on a given axis flips (mirrors) the image on that axis
        0, 1, self.orientation == 'top' and -1 or 1)
end