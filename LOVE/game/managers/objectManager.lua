require("scripts/enemy")
ObjectManager = {}
ObjectManager.__index = ObjectManager
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
function ObjectManager:new(player)
    local instance = setmetatable({}, ObjectManager)
    instance.player = player
    instance.enemies = {}
    instance.spawnTimer = 0
    instance.spawnInterval = math.random(5, 10)
    return instance
end

function ObjectManager:spawnEnemy(cameraX)
    cameraX = cameraX and cameraX or 0
    print('spawning at: ' .. cameraX)
    local x = math.random(cameraX, cameraX + love.graphics.getWidth())
    local y = math.random(0, 150)
    table.insert(self.enemies, Enemy:new(x, y, self.player.x))
end

function ObjectManager:update(dt, playerX, playerY, cameraX)
    self.spawnTimer = self.spawnTimer + dt
    if self.spawnTimer >= self.spawnInterval then
        self:spawnEnemy(cameraX)
        self.spawnTimer = 0
        self.spawnInterval = math.random(3, 6)
    end

    for _, enemy in ipairs(self.enemies) do
        enemy:update(dt, playerX, playerY, self.player)
        if enemy.health <= 0 then
            table.remove(self.enemies, _)
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
end
