Paddle = Class{}

function Paddle:init(x,y,width,height)
    self.speed = 200
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
    self.score = 0
    self.ai = false
end

function Paddle:update(dt)
    if self.dy > 0 then
        self.y = math.min(self.y + self.dy * dt, VIRTUAL_HEIGHT - self.height )
    elseif self.dy < 0 then
        self.y = math.max(self.y + self.dy * dt, 0)
    end
end

function Paddle:render()
    love.graphics.rectangle('fill',self.x,self.y,self.width,self.height)
end

function Paddle:ai_movement(ball)
    if abs(self.x - ball.x) < VIRTUAL_WIDTH / 2  then
        if self.y < ball.y   then
            self.dy = self.speed
        elseif self.y  > ball.y then
            self.dy = -self.speed
        else 
            self.dy = 0
        end
    else
        self.dy = 0
    end
end

function abs(num)
    if num >= 0 then
        return num
    else
        return -num
    end
end