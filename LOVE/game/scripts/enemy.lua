require("scripts/enemyProjectile")
Enemy = {}
Enemy.__index = Enemy
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
function Enemy:new(x, y)
    local instance = setmetatable({}, Enemy)
    instance.x = x
    instance.y = y
    instance.speed = 100
    instance.gravity = 400
    instance.verticalVelocity = 0
    instance.onGround = false
    instance.projectiles = {}
    instance.shootingCooldown = 1
    instance.shootTimer = 0
    instance.health = 3
    return instance
end

function Enemy:update(dt, playerX, playerY, player)
    if not self.onGround then
        self.verticalVelocity = self.verticalVelocity + self.gravity * dt
        self.y = self.y + self.verticalVelocity * dt
        if self.y >= screenHeight - 20 then
            self.y = screenHeight - 20
            self.verticalVelocity = 0
            self.onGround = true
        end
    end

    if self.onGround then
        if playerX > self.x then
            self.x = self.x + self.speed * dt
        elseif playerX < self.x then
            self.x = self.x - self.speed * dt
        end
    end

    self.shootTimer = self.shootTimer + dt
    if self.shootTimer >= self.shootingCooldown then
        self:shootAt(playerX, playerY)
        self.shootTimer = 0
    end

    for i = #player.projectiles, 1, -1 do
        local projectile = player.projectiles[i]
        projectile:checkCollisionWithEnemy(self)

        if projectile.collided then
            self.health = self.health - 1
            table.remove(player.projectiles, i)
        end
    end

    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        projectile:update(dt)

        projectile:checkCollisionWithPlayer(player)

        if projectile.collided then
            player.health = player.health - 1
            table.remove(self.projectiles, i)
        end
        if projectile.x < 0 or projectile.x > screenWidth or projectile.y < 0 or projectile.y > screenHeight then
            table.remove(self.projectiles, i)
        end
    end
end

function Enemy:shootAt(targetX, targetY)
    local projectile = EnemyProjectile:new(self.x, self.y, targetX, targetY)
    table.insert(self.projectiles, projectile)
end

function Enemy:draw()
    love.graphics.rectangle("fill", self.x, self.y, 20, 20)

    for _, projectile in ipairs(self.projectiles) do
        projectile:draw()
    end
end
