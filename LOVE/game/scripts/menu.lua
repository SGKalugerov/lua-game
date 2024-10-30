Menu = {}
Menu.__index = Menu
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
function Menu.new(gameState)
    local instance = setmetatable({}, Menu)
    instance.gameState = gameState
    instance.pressToStartTimeout = 0.6
    instance.pressToStartTimer = 0
    instance.showText = true
    return instance
end

function Menu:update(dt)
    self.pressToStartTimer = self.pressToStartTimer + dt
    if self.pressToStartTimer > self.pressToStartTimeout then
        self.pressToStartTimer = 0
        self.showText = not self.showText
    end
    if love.keyboard.isDown("space") then
        self.gameState = "Game"
    end
end

function Menu:draw()
    local menu = love.graphics.newImage("assets/menu/menu.jpg")
    love.graphics.draw(menu, 100, 0)
    love.graphics.setFont(font)

    if self.showText then
        love.graphics.print("Press space to start", screenWidth / 2 - 230, screenHeight / 2 + 100)
    end
end
