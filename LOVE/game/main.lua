require("scripts.player")
require("managers.animationManager")
require("managers.objectManager")
require("scripts.menu")
local player
local animationManager
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
scrollStart = screenWidth - screenWidth / 2
local MapManager = require('managers.mapManager')
local tilesetData = require('utils.tilesetData')
local cameraX, backgroundX = 0, 0
local tileImages = {}
local menu
local buffs = require("scripts.enums.buffs")
local weapons = require("scripts.enums.weapons")
local hasMenuSongPlayed, hasBackgroundMusicPlayed = false, false

local menuSong = love.audio.newSource("assets/effects/menu.mp3", "stream")
local backgroundMusic = love.audio.newSource("assets/music/jungle.mp3", "stream")
backgroundMusic:setLooping(true)

local powerups = require("scripts.powerups.powerupTypes")

function love.load()
    math.randomseed(os.time())
    math.random(); math.random(); math.random()
    animationManager = AnimationManager.new()
    player = Player.new(0, 0, animationManager)
    objectManager = ObjectManager:new(player)
    objectManager:spawnEnemy()

    _G.font = love.graphics.newFont("assets/fonts/exocet.ttf", 36)
    menu = Menu.new("Menu")
    MapManager:loadMap("assets/tiles/kur.json", tilesetData)

    tileImages[1] = love.graphics.newImage("assets/tiles/tile_dirt_grass.png")
    tileImages[18] = love.graphics.newImage("assets/tiles/tile_dirt.png")
end

local function getKeyByValue(tbl, value)
    for key, val in pairs(tbl) do
        if val == value then
            return key
        end
    end
    return nil
end

local function playBackgroundMusic()
    menuSong:stop()
    if not hasBackgroundMusicPlayed then
        backgroundMusic:play()
        hasBackgroundMusicPlayed = true
    end
end

function love.update(dt)
    if menu.gameState == "Menu" then
        if not hasMenuSongPlayed then
            menuSong:play()
            hasMenuSongPlayed = true
        end
        menu:update(dt)
        return
    else
        playBackgroundMusic()
    end

    player:update(dt, cameraX)

    for i = #player.projectiles, 1, -1 do
        local projectile = player.projectiles[i]
        projectile:update(dt)
        if projectile.travelDistance <= 0 then
            table.remove(player.projectiles, i)
        end
    end
    objectManager:update(dt, player.x, player.y, cameraX, player)
end

function love.draw()
    if menu.gameState == "Menu" then
        menu:draw()
    else
        MapManager:drawMap(tileImages)
        player:draw(cameraX)
        objectManager:draw(cameraX)

        local playerBuffs, firstBuff = "", true
        for _, buff in pairs(player.buffs) do
            if buff ~= nil then
                local buffName = getKeyByValue(buffs, _) or getKeyByValue(powerups.effects, _)
                if buffName then
                    if not firstBuff then playerBuffs = playerBuffs .. ", " end
                    playerBuffs = playerBuffs .. buffName
                    firstBuff = false
                end
            end
        end

        love.graphics.print("Score: " .. player.score, 0, 0)
        love.graphics.print("Weapon: " .. getKeyByValue(weapons, player.weapon), 0, 30)
        if playerBuffs ~= '' then
            love.graphics.print("Buffs: " .. playerBuffs, 0, 60)
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end
