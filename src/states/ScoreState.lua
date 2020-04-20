--[[
    ScoreState Class
    Author: Colton Ogden
    cogden@cs50.harvard.edu

    A simple state used to display the player's score before they
    transition back into the play state. Transitioned to from the
    PlayState when they collide with a Pipe.
]]

ScoreState = Class{__includes = BaseState}
--[[
    When we enter the score state, we expect to receive the score
    from the play state so we know what to render to the State.
]]
function ScoreState:enter(params)
    self.score = params.score
    self.displayScore = 0
    self.displayScoreQuadName = 'zzz'
    self.elapsedTime = 0
    self.dtCount = 0
    self.playAgain = false
    self.originalMusicVolume = sounds['music']:getVolume()

    sounds['music']:setVolume(self.originalMusicVolume * 0.1)
    sounds['score-random']:play()
end

function ScoreState:exit()
    sounds['score-random']:stop()
end

function ScoreState:update(dt)
    self.elapsedTime = self.elapsedTime + dt
    self.dtCount = self.dtCount + 1
    -- Score Mapping
    -- 0   => zzz
    -- 1-3 => meh
    -- 4-6 => ok
    -- 7+  => dealwithit
    local realScoreQuadName = 'zzz'
    if self.score >= 1 and self.score <= 3 then
        realScoreQuadName = 'meh'
    elseif self.score >= 4 and self.score <= 6 then
        realScoreQuadName = 'ok'
    elseif self.score >= 7 then
        realScoreQuadName = 'dealwithit'
    end

    local quadOptions = {'zzz', 'meh', 'ok', 'dealwithit'}
    -- display a random "medal" and score for 2 seconds,
    -- then render the real score and enable playAgain
    if self.elapsedTime <= 1.5 then
        -- slow down the cycling
        if (self.dtCount % 4 == 0) then
            self.displayScoreQuadName = quadOptions[math.random(#quadOptions)]
            self.displayScore = math.random(100)
        end
    else
        --  stop random music, restore origina music and play socre sound just once
        if not self.playAgain then
            sounds['score-random']:stop()
            sounds['score']:play()
            sounds['music']:setVolume(self.originalMusicVolume)
        end
        self.playAgain = true
        self.displayScore = self.score
        self.displayScoreQuadName = realScoreQuadName
        -- go back to play if enter is pressed
        if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            gStateMachine:change('countdown')
        end
    end
end

function ScoreState:render()
    -- draw a translucent modal on top of the playState elements
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT - GROUND_HEIGHT)

    -- restore color and opacity
    love.graphics.setColor(1, 1, 1, 1)

    local verticalSpace = 8
    local scoreIconScale = 3
    local scoreIconSize = 16 * scoreIconScale
    local gameOverY = 64 + verticalSpace
    local scoreTextY = gameOverY + flappyFont:getHeight() + verticalSpace
    local scoreIconY = scoreTextY + mediumFont:getHeight() + verticalSpace
    local playAgainY = scoreIconY + scoreIconSize + verticalSpace

    -- Score Icon
    love.graphics.draw(
        getIconTexture(),
        getIconQuads(self.displayScoreQuadName),
        (VIRTUAL_WIDTH-scoreIconSize)/2,
        scoreIconY,
        0,
        scoreIconScale,
        scoreIconScale
    )

    -- simply render the score to the middle of the screen
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Game Over', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Score: ' .. tostring(self.displayScore), 0, scoreTextY, VIRTUAL_WIDTH, 'center')

    -- wait for self.playAgain to show the text becasue the key binding is not registered until then
    if self.playAgain then
        love.graphics.printf('Press Enter to Play Again!', 0, playAgainY, VIRTUAL_WIDTH, 'center')
    end
end