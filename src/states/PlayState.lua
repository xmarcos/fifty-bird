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
    self.pipePairsCount = 0
    self.timer = 0
    self.score = 0
    -- start with one, don't make the user wait too long
    self.randomInterval = 1
    -- initialize our last recorded Y value to a valid but random value
    self.lastY = -Pipe:HEIGHT() + math.random(Pipe:MIN_HEIGHT(), Pipe:MIN_HEIGHT()*3)
end

function PlayState:getRandomInterval()
    return math.random(1, 4)
end

function PlayState:update(dt)

    if love.keyboard.wasPressed('p') then
        -- pass current playState to the pauseState
        gStateMachine:change('pause', {
            ['bird']           = self.bird,
            ['pipePairs']      = self.pipePairs,
            ['pipePairsCount'] = self.pipePairsCount,
            ['timer']          = self.timer,
            ['score']          = self.score,
            ['randomInterval'] = self.randomInterval,
            ['lastY']          = self.lastY
        })
    end

    -- count it once per dt
    self.pipePairsCount = #self.pipePairs
    -- update timer for pipe spawning
    self.timer = self.timer + dt

    if self.timer > self.randomInterval then
        -- default to the edge of the screen
        local previousPairX = VIRTUAL_WIDTH
        -- if we are past the first pipe
        if (self.pipePairsCount > 0) then
            -- get the previous pipe position
            previousPairX = self.pipePairs[self.pipePairsCount]:getCurrentX()
        end
        -- generate the new pair relative to the previous one or the edge of the screen
        self:generateNextPair(previousPairX)
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


function PlayState:generateNextPair(previousPairX)
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
    -- position the next pipe relative to the end of the previousPairX to avoid overlaping
    local newX =
        math.max(
            -- ensure pipes are always drawn off-screen to avoid visual glitches
            VIRTUAL_WIDTH + Pipe:WIDTH()/4,
            -- using self.timer, ensure there is at least 1/4 of a pipe of distance if the value is close to zero
            previousPairX + Pipe:WIDTH() + Pipe:WIDTH()/4,
            -- position relative to the previous pair using a self.timer-adjusted position
            -- but don't go over 3 pipes of distance
            previousPairX + Pipe:WIDTH() + math.min(
                math.random(Pipe:WIDTH() * self.timer),
                Pipe:WIDTH() * 3
            )
        )
    -- create the the new pair and append the new pair
    local newPipePair = PipePair(newX, newY, newGapHeight)
    table.insert(self.pipePairs, newPipePair)
end

function PlayState:render()
    for k, pair in pairs(self.pipePairs) do
        pair:render()
    end

    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

    self.bird:render()
end

function PlayState:enter(previousPlayState)
    if previousPlayState ~= nil then
        -- restore previousPlayState
        self.bird           = previousPlayState.bird
        self.pipePairs      = previousPlayState.pipePairs
        self.pipePairsCount = previousPlayState.pipePairsCount
        self.timer          = previousPlayState.timer
        self.score          = previousPlayState.score
        self.randomInterval = previousPlayState.randomInterval
        self.lastY          = previousPlayState.lastY
    end
end