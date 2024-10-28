require("scripts.player")
require("managers.animationManager")
require("managers.objectManager")

local player
local animationManager
local screenWidth = love.graphics.getWidth()
scrollStart = screenWidth - screenWidth / 2
local MapManager = require('managers.mapManager')
local tilesetData = require('utils.tilesetData')
local screenHeight = love.graphics.getHeight()
local backgroundMusic
local cameraX = 0
local backgroundX = 0
local tileImages = {}
function love.load()
    -- _G.background = love.graphics.newImage("assets/level1.png")
    animationManager = AnimationManager.new()
    player = Player.new(0, 0, animationManager)
    objectManager = ObjectManager:new(player)
    objectManager:spawnEnemy()
    backgroundMusic = love.audio.newSource("assets/music/jungle.mp3", "stream")

    backgroundMusic:setLooping(true)

    backgroundMusic:play()

    MapManager:loadMap("C:\\GIT\\lua-game\\LOVE\\game\\assets\\tiles\\putka.json", tilesetData)


    tileImages[1] = love.graphics.newImage("assets/tiles/tile_dirt_grass.png")
    tileImages[18] = love.graphics.newImage("assets/tiles/tile_dirt.png")
end

function love.update(dt)
    player:update(dt, cameraX)

    for i = #player.projectiles, 1, -1 do
        local projectile = player.projectiles[i]
        projectile:update(dt)
        if projectile.travelDistance <= 0 then
            table.remove(player.projectiles, i)
        end
        -- if projectile.x < 0 or projectile.x > screenWidth or projectile.y < 0 or projectile.y > screenHeight then
        --     table.remove(player.projectiles, i)
        -- end
    end
    objectManager:update(dt, player.x, player.y, cameraX)

    -- if player.x > scrollStart then
    --     -- Calculate how much the camera should offset based on player's position
    --     cameraX = player.x - scrollStart
    --     -- backgroundX = math.max(-(background:getWidth() - screenWidth), -cameraX)
    -- else
    --     -- Reset camera offset when the player is within screen width
    --     cameraX = 0
    --     backgroundX = 0
    -- end
end

function love.draw()
    -- love.graphics.draw(background, backgroundX, 0)
    print(cameraX)

    MapManager:drawMap(tileImages)
    for _, projectile in ipairs(player.projectiles) do
        projectile:draw(cameraX)
    end
    objectManager:draw(cameraX)
    player:draw(cameraX)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
