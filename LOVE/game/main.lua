require("scripts.player")
require("animationManager.animationManager")
local player
local background
local animationManager
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local backgroundMusic
function love.load()
    background = love.graphics.newImage("assets/background.jpg")
    animationManager = AnimationManager.new()
    player = Player.new(0, 0, animationManager)
    backgroundMusic = love.audio.newSource("assets/music/jungle.mp3", "stream")

    backgroundMusic:setLooping(true)

    backgroundMusic:play()
end

function love.update(dt)
    player:update(dt)

    for i = #player.projectiles, 1, -1 do
        local projectile = player.projectiles[i]
        projectile:update(dt)

        if projectile.x < 0 or projectile.x > screenWidth or projectile.y < 0 or projectile.y > screenHeight then
            table.remove(player.projectiles, i)
        end
    end
end

function love.draw()
    love.graphics.draw(background, 0, 0)
    player:draw()
    for _, projectile in ipairs(player.projectiles) do
        projectile:draw()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
