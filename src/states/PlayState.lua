--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

-- Sets the maximum distance between the beginning of the pipe gap of two different pipe pairs,
-- so that they aren't too far apart. Increase the number to make it harder to play.
PIPE_MAX_GAP_DISTANCE = 20

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0

    -- initialize our last recorded Y value to a valid but random value
    self.lastY = -PIPE_HEIGHT + math.random(Pipe:getMinHeight(), Pipe:getMinHeight()*3)

end

function PlayState:update(dt)
    -- update timer for pipe spawning
    self.timer = self.timer + dt

    if self.timer > 2 then
        -- get the random gap height of the new Pipe Pair to calculate its vertical position
        local newGapHeight = PipePair:getRandomGapHeight()
        -- calculate the vertical position of the PipePair
        local newY = math.min(
                -- don't go over the combined (negative) height of the gap, the ground and the
                -- height of the lower pipe's opening to ensure that both pipes are visible
                (newGapHeight + GROUND_HEIGHT + Pipe:getMinHeight()) * -1,
                -- position the next pipe so that the begining of its gap is close (PIPE_MAX_GAP_DISTANCE)
                -- to the previous one and ensure we don't go over the top of the screen.
                math.max(
                    self.lastY + math.random(-PIPE_MAX_GAP_DISTANCE, PIPE_MAX_GAP_DISTANCE),
                    -PIPE_HEIGHT + Pipe:getMinHeight()
                )
        )
        self.lastY = newY
        local newPipePair = PipePair(newY, newGapHeight)

        -- add a new pipe pair at the end of the screen at our new Y
        table.insert(self.pipePairs, newPipePair)

        -- reset timer
        self.timer = 0
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + PIPE_WIDTH < self.bird.x then
                self.score = self.score + 1
                pair.scored = true
                sounds['score']:play()
            end
        end

        -- update position of pair
        pair:update(dt)
    end

    -- we need this second loop, rather than deleting in the previous loop, because
    -- modifying the table in-place without explicit keys will result in skipping the
    -- next pipe, since all implicit keys (numerical indices) are automatically shifted
    -- down after a table removal
    for k, pair in pairs(self.pipePairs) do
        if pair.remove then
            table.remove(self.pipePairs, k)
        end
    end

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
        for l, pipe in pairs(pair.pipes) do
            if self.bird:collides(pipe) then
                sounds['explosion']:play()
                sounds['hurt']:play()

                -- gStateMachine:change('score', {
                --     score = self.score
                -- })
            end
        end
    end

    -- update bird based on gravity and input
    self.bird:update(dt)

    -- reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        sounds['explosion']:play()
        sounds['hurt']:play()

        -- gStateMachine:change('score', {
        --     score = self.score
        -- })
    end
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end

--[[
    Called when this state is transitioned to from another state.
]]
function PlayState:enter()
    -- if we're coming from death, restart scrolling
    scrolling = true
end

--[[
    Called when this state changes to another state.
]]
function PlayState:exit()
    -- stop scrolling for the death/score screen
    scrolling = false
end