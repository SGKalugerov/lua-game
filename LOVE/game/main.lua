-- Load the player script
require("scripts.player")

-- Game State Variables
local player
local background

-- Load assets and initialize variables
function love.load()
    background = love.graphics.newImage("assets/background.jpg")
    player = Player.new(50, 50, "assets/player.png") -- Initialize player at the center of the screen
end

-- Update the game logic (runs every frame)
function love.update(dt)
    player:update(dt)
end

-- Draw everything to the screen (runs every frame)
function love.draw()
    love.graphics.draw(background, 0, 0)
    player:draw()
end

-- Key press event
function love.keypressed(key)
    if key == "escape" then
        love.event.quit() -- Quit the game on pressing escape
    end
end
