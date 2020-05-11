Ball = Class{}

function Ball:init(x,y,width,height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dx = 0
    self.dy = -50
end


function Ball:movement(gameState,dt)
    if gameState == 'play' then
        self.x = self.x + self.dx * dt
        self.y = self.y + self.dy * dt
    end
end


function Ball:render()
    love.graphics.rectangle('fill',self.x ,self.y, self.width, self.height)
end


function Ball:hit(box) 
    if self.x > box.x + box.width or self.x + self.width < box.x then
        return false
    end
    if self.y > box.y + box.height or self.y + self.height < box.y then
        return false
    end
    return true
end


function Ball:deflectX()
    self.dx = self.dx * -1.03
    if self.dx > 0 then
        self.x = 10
    else
        self.x =  VIRTUAL_WIDTH - 15
    end
end


function Ball:deflectY()
    self.dy =  self.dy * -1.06
    if self.dy > 0 then
        self.y = self.y + 5
    else
        self.y = self.y - 5
    end
end