-- written by sruly rosenblat
-- based off cs50 game track by colton ogden
-- sounds are orignal
--requires LOVE game-engine to run



-- set ammuont of pixels in screen
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
-- set the simulated amount of pixels
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243
-- import classes
Push = require 'push'
Class = require 'class'
require 'Paddle'
require 'Ball'

-- all the sounds set up in a table
sounds ={
    ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
    ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static'),
    ['score'] = love.audio.newSource('sounds/score.wav','static'),
    ['win'] = love.audio.newSource('sounds/win.wav','static')
}


function love.load()

    love.window.setTitle('Pong')
    math.randomseed(os.time())
    love.graphics.setDefaultFilter('nearest','nearest')
    -- set fonts
    smallFont = love.graphics.newFont('font.TTF', 8)
    scorefont = love.graphics.newFont('font.TTF', 32)

    setup_paddles()
    ball_setup()

    gameState = 'start'

    serve = math.random(2)

    winner = ''

    max_score = 2
    

    Push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
      fullscreen = false,
      vsync = true,
      resizable = true
  })
end

-- alows windows to be resized dynamicly
function love.resize(w,h)
    Push:resize(w,h)
end


function setup_paddles()
    -- initiate the paddels
    p1 = Paddle(5,20,5,20)
    p2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 40,5,20)
    -- toggle ai
    p1.ai = false
    p2.ai = true
    paddle_speed = 200
end


function ball_setup()
    -- set up ball with possition
    ball = Ball(VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 - 2, 5, 5 )
    -- set valocity ball goes in
    ball.dy = math.random(-50,50)
    ball.dx = serve == 1 and 200  or -200
end


function love.update(dt)
    -- move paddles
    p1:update(dt)
    p2:update(dt)
    -- check if ball hit paddles or edges and act accordingly
    if ball:hit(p1)  then 
        ball:deflectX(p1)
        sounds['paddle_hit']:play()
    elseif ball:hit(p2) then
        ball:deflectX(p2)
        sounds['paddle_hit']:play()
    elseif ball.y < 0 or ball.y > VIRTUAL_HEIGHT then
        ball:deflectY()
        sounds['wall_hit']:play()
    end 
    -- check if player scored
    if ball.x >= VIRTUAL_WIDTH then
        sounds['score']:play()
        p1.score = p1.score + 1
        serve = 0
        gameState = 'serve'
        ball_setup()

    elseif ball.x <= 0 then
        sounds['score']:play()
        p2.score = p2.score + 1
        serve = 1
        gameState = 'serve'
        ball_setup()
    end
    -- movement controles if not AI
    if gameState == 'play' then
        if not p1.ai then
            if love.keyboard.isDown('w')  then
                p1.dy =  -p1.speed
            elseif love.keyboard.isDown('s') then
                p1.dy = p1.speed
            else
                p1.dy = 0
            end
        else 
            p1:ai_movement(ball,dt)
        end
        if not p2.ai then
            if love.keyboard.isDown('up') then
                p2.dy = -p2.speed
            elseif love.keyboard.isDown('down') then
                p2.dy = p2.speed
            else 
                p2.dy = 0
            end
        else 
            p2:ai_movement(ball,dt)
        end
        -- check if player won
        if p1.score == max_score then
            winner = 'player one '
            gameState = 'won'
            sounds['win']:play()
        elseif p2.score == max_score then 
            winner = 'player two '
            gameState = 'won'
            sounds['win']:play()
        end
        -- move ball based on valocity
        ball:movement(gameState,dt)
    end
end

-- show changes on screen
function love.draw()
    
    Push:apply('start')
    -- display 
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255 , 255 / 255)
    love.graphics.setFont(smallFont)
    game_manager()
    -- score
    display_scores()
    -- ball
    ball:render()
    -- paddles
    p1:render()
    p2:render()
    -- fps
    --display_fps()
    Push:apply('end')
end

-- set gamestates with enter
function love.keypressed(key)
    -- quit game
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then

        if gameState == 'start' then
            gameState = 'play'
        elseif gameState == 'play' then
            gameState = 'pause'
        elseif gameState == 'pause' then
            gameState = 'play'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'won' then
            p1.score = 0
            p2.score = 0
            gameState = 'start'
        end
    end
end

-- text  based on state
function game_manager()
    if gameState == 'start' then
        love.graphics.printf('welcome to pong',0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf('press enter to start',0,40,VIRTUAL_WIDTH,'center')
    elseif gameState == 'pause' then
        love.graphics.printf('game paused',0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf('press enter to start',0,40,VIRTUAL_WIDTH,'center')
    elseif gameState == 'serve' then
        if serve == 1 then
            love.graphics.printf("player one's serve",0,20,VIRTUAL_WIDTH,'center')
            love.graphics.printf('press enter to start',0,40,VIRTUAL_WIDTH,'center')
        else
            love.graphics.printf("player two's serve",0,20,VIRTUAL_WIDTH,'center')
            love.graphics.printf('press enter to start',0,40,VIRTUAL_WIDTH,'center')
        end
    elseif gameState == 'won' then
        love.graphics.printf(winner .. "won!!" ,0,20,VIRTUAL_WIDTH,'center')
        love.graphics.printf('press enter to start again!!',0,40,VIRTUAL_WIDTH,'center')
    end
end


function display_fps()
    love.graphics.setColor(0,1,0,1)
    love.graphics.setFont(smallFont)
    love.graphics.print('fps: ' .. tostring(love.timer.getFPS()), 40,20)
    love.graphics.setColor(1,1,1,1)
end


function display_scores()
    love.graphics.setFont(scorefont)
    love.graphics.print(tostring(p1.score),VIRTUAL_WIDTH / 2 - 50 , VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(p2.score),VIRTUAL_WIDTH / 2 + 30 , VIRTUAL_HEIGHT / 3)
    love.graphics.setFont(smallFont)
end