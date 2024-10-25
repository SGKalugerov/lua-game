Player = {}
Player.__index = Player

local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

-- Constructor
function Player.new(x, y, imagePath)
    local instance = setmetatable({}, Player)
    instance.x = x
    instance.y = y
    instance.image = love.graphics.newImage(imagePath)
    instance.width = instance.image:getWidth()   -- Get the width of the player's image
    instance.height = instance.image:getHeight() -- Get the height of the player's image
    instance.speed = 350                         -- Movement speed
    return instance
end

-- Update player position
function Player:update(dt)
    if love.keyboard.isDown("left") then
        local destinationX = self.x - self.speed * dt
        if destinationX >= 0 then
            self.x = destinationX
        end
    end
    if love.keyboard.isDown("right") then
        local destinationX = self.x + self.speed * dt
        if destinationX + self.width <= screenWidth then
            self.x = destinationX
        end
    end
    if love.keyboard.isDown("up") then
        local destinationY = self.y - self.speed * dt
        if destinationY >= 0 then
            self.y = destinationY
        end
    end
    if love.keyboard.isDown("down") then
        local destinationY = self.y + self.speed * dt
        if destinationY + self.height <= screenHeight then
            self.y = destinationY
        end
    end
end

-- Draw the player
function Player:draw()
    love.graphics.draw(self.image, self.x, self.y)
end
