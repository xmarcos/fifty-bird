PauseState = Class{__includes = BaseState}

function PauseState:init()
    self.playState = {}
end

function PauseState:update(dt)
    if love.keyboard.wasPressed('p') or love.keyboard.wasPressed('space') then
        gStateMachine:change('play', self.playState)
    end
end

function PauseState:enter(playState)
    GAME_PAUSED = true
    self.playState = playState
    sounds['music']:pause()

end

function PauseState:exit()
    GAME_PAUSED = false
    self.playState = {}
    sounds['music']:play()
end

function PauseState:render()

    -- render the playState elements
    love.graphics.setColor(1, 1, 1, 0.8)
    for k, pair in pairs(self.playState.pipePairs) do
        pair:render()
    end
    love.graphics.setFont(flappyFont)
    love.graphics.print('Score: ' .. tostring(self.playState.score), 8, 8)
    self.playState.bird:render()
    -- draw a translucent modal on top of the playState elements
    love.graphics.setColor(0, 0, 0, 0.25)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT - GROUND_HEIGHT)

    -- restore color and opacity
    love.graphics.setColor(1, 1, 1, 1)

    -- Pause Menu
    love.graphics.setFont(flappyFont)
    love.graphics.printf('PAUSE', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press P or SPACE to resume', 0, 100, VIRTUAL_WIDTH, 'center')
end