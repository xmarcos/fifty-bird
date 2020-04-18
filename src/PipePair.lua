--[[
    PipePair Class

    Author: Colton Ogden
    cogden@cs50.harvard.edu

    Used to represent a pair of pipes that stick together as they scroll, providing an opening
    for the player to jump through in order to score a point.
]]

PipePair = Class{}

-- size of the gap between pipes
local MIN_GAP_HEIGHT = 90 -- VIRTUAL_HEIGHT - GROUND_HEIGHT / 3
local MAX_GAP_HEIGHT = 135 -- MIN_GAP_HEIGHT * 1.5

function PipePair:init(y, gap_height)
    -- flag to hold whether this pair has been scored (jumped through)
    self.scored = false

    --the vertical space between the two pipes
    self.gap_height = (gap_height <= MAX_GAP_HEIGHT and gap_height >= MIN_GAP_HEIGHT) and gap_height or MIN_GAP_HEIGHT

    -- initialize pipes past the end of the screen
    self.x = VIRTUAL_WIDTH + 32

    -- y value is for the topmost pipe; gap is a vertical shift of the second lower pipe
    self.y = y

    -- instantiate two pipes that belong to this pair
    self.pipes = {
        ['upper'] = Pipe('top', self.y),
        ['lower'] = Pipe('bottom', self.y + PIPE_HEIGHT + self.gap_height)
    }

    -- whether this pipe pair is ready to be removed from the scene
    self.remove = false
end

function PipePair:getRandomGapHeight()
    return math.random(MIN_GAP_HEIGHT, MAX_GAP_HEIGHT)
end

function PipePair:update(dt)
    -- remove the pipe from the scene if it's beyond the left edge of the screen,
    -- else move it from right to left
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        self.pipes['lower'].x = self.x
        self.pipes['upper'].x = self.x
    else
        self.remove = true
    end
end

function PipePair:render()
    for l, pipe in pairs(self.pipes) do
        pipe:render()
    end
end