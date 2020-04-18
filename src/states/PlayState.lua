--[[
    PlayState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    The PlayState class is the bulk of the game, where the player actually controls the bird and
    avoids pipes. When the player collides with a pipe, we should go to the GameOver state, where
    we then go back to the main menu.
]]

PlayState = Class{__includes = BaseState}

-- Sets the maximum distance between the beginning of the pipe gap of two different pipe pairs,
-- so that they aren't too far apart. Increase the number to make it harder to play.
local PIPE_MAX_GAP_DISTANCE = 20

function PlayState:init()
    self.bird = Bird()
    self.pipePairs = {}
    self.timer = 0
    self.score = 0
    -- start with two, don't make the user wait too long
    self.randomInterval = 2

    -- initialize our last recorded Y value to a valid but random value
    self.lastY = -Pipe:HEIGHT() + math.random(Pipe:MIN_HEIGHT(), Pipe:MIN_HEIGHT()*3)

end

function PlayState:getRandomInterval()
    return math.ceil(math.random(3))
end
function PlayState:update(dt)
    -- update timer for pipe spawning
    self.timer = self.timer + dt

    if self.timer > self.randomInterval then
        -- get the random gap height of the new Pipe Pair to calculate its vertical position
        local newGapHeight = PipePair:getRandomGapHeight()
        -- calculate the vertical position of the PipePair
        local newY = math.min(
                -- don't go over the combined (negative) height of the gap, the ground and the
                -- height of the lower pipe's opening to ensure that both pipes are visible
                (newGapHeight + GROUND_HEIGHT + Pipe:MIN_HEIGHT()) * -1,
                -- position the next pipe so that the begining of its gap is close (PIPE_MAX_GAP_DISTANCE)
                -- to the previous one and ensure we don't go over the top of the screen.
                math.max(
                    self.lastY + math.random(-PIPE_MAX_GAP_DISTANCE, PIPE_MAX_GAP_DISTANCE),
                    -Pipe:HEIGHT() + Pipe:MIN_HEIGHT()
                )
        )
        self.lastY = newY
        local newX = VIRTUAL_WIDTH + 10;

        -- if we are past the first pipe
        if (#self.pipePairs > 0) then
            -- get the previous pipe position
            local previousPairX = self.pipePairs[#self.pipePairs]:getCurrentX()
            -- position the next pipe relative to the end of the previous one to avoid overlaping
            -- and space it using a random space that can be at most randomInterval times a half-pipe
            newX = previousPairX + Pipe:WIDTH() + math.random(Pipe:WIDTH() * self.timer)
        end

        -- create the the new pair
        local newPipePair = PipePair(newX, newY, newGapHeight)
        table.insert(self.pipePairs, newPipePair)

        -- reset timer
        self.timer = 0
        -- reset interval
        self.randomInterval = self.getRandomInterval()
    end

    -- for every pair of pipes..
    for k, pair in pairs(self.pipePairs) do
        -- score a point if the pipe has gone past the bird to the left all the way
        -- be sure to ignore it if it's already been scored
        if not pair.scored then
            if pair.x + Pipe:WIDTH() < self.bird.x then
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