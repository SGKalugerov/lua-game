require("scripts/enemy")
require("scripts/powerups/powerup")
ObjectManager = {}
ObjectManager.__index = ObjectManager
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local powerups = require("scripts.powerups.powerupTypes")
function ObjectManager:new(player, animationManager)
    local instance = setmetatable({}, ObjectManager)
    instance.player = player
    instance.enemies = {}
    instance.powerups = {}
    instance.spawnTimer = 0
    instance.animationManager = animationManager
    instance.powerupSpawnTimer = 0
    instance.spawnInterval = math.random(5, 10)
    instance.powerupSpawnInterval = math.random(1, 3)
    return instance
end

function ObjectManager:spawnPowerup(cameraX, type)
    cameraX = cameraX and cameraX or 0
    local x = math.random(cameraX, cameraX + love.graphics.getWidth())
    local y = math.random(0, 150)
    table.insert(self.powerups, Powerup:new(x, y, type))
end

function ObjectManager:spawnEnemy(cameraX)
    cameraX = cameraX and cameraX or 0
    local x = math.random(cameraX, cameraX + love.graphics.getWidth())
    local y = math.random(0, 150)
    table.insert(self.enemies, Enemy:new(x, y, self.player.x, self.animationManager))
end

function ObjectManager:update(dt, playerX, playerY, cameraX, player)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= self.spawnInterval then
        self:spawnEnemy(cameraX)
        self.spawnTimer = 0
        self.spawnInterval = math.random(3, 6)
    end

    self.powerupSpawnTimer = self.powerupSpawnTimer + dt
    if self.powerupSpawnTimer >= self.powerupSpawnInterval then
        local powerupIndex = math.random(1, 5)
        self:spawnPowerup(cameraX, powerups.powerups[powerupIndex])
        self.powerupSpawnTimer = 0
        self.powerupSpawnInterval = math.random(1, 3)
    end

    for _, powerup in ipairs(self.powerups) do
        powerup:update(dt, player)
        powerup.aliveTimer = powerup.aliveTimer + dt
        if powerup.aliveTimer >= powerup.aliveDuration then
            table.remove(self.powerups, _)
        end
        powerup:checkCollisionWithPlayer(player)
        if powerup.collided then
            table.remove(self.powerups, _)
        end
        if powerup.x < cameraX or powerup.x > screenWidth + cameraX or powerup.y < 0 or powerup.y > screenHeight then
            table.remove(self.powerups, _)
        end
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, playerX, playerY, self.player)
        if enemy.health <= 0 then
            table.remove(self.enemies, _)
            player.score = player.score + enemy.pointsAward
        end
        for i = #enemy.projectiles, 1, -1 do
            local projectile = enemy.projectiles[i]
            projectile:update(dt)
            if projectile.travelDistance <= 0 then
                table.remove(enemy.projectiles, i)
            end
            -- if projectile.x < 0 or projectile.x > screenWidth or projectile.y < 0 or projectile.y > screenHeight then
            --     table.remove(enemy.projectiles, i)
            -- end
        end

        if enemy.x < cameraX or enemy.x > screenWidth + cameraX or enemy.y < 0 or enemy.y > screenHeight then
            table.remove(self.enemies, _)
        end
    end
end

function ObjectManager:draw(cameraX)
    for _, enemy in ipairs(self.enemies) do
        enemy:draw(cameraX)
    end
    for _, powerup in ipairs(self.powerups) do
        powerup:draw(cameraX)
    end
end
