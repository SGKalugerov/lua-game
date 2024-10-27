EnemyProjectile = {}
EnemyProjectile.__index = EnemyProjectile
local checkCollision = require("utils/collision")

function EnemyProjectile:new(x, y, targetX, targetY)
    local instance = setmetatable({}, EnemyProjectile)
    instance.x = x
    instance.y = y
    instance.speed = 250
    instance.targetX = targetX
    instance.targetY = targetY

    local dx = targetX - x
    local dy = targetY - y
    local distance = math.sqrt(dx * dx + dy * dy)
    instance.velocityX = (dx / distance) * instance.speed
    instance.velocityY = (dy / distance) * instance.speed

    return instance
end

function EnemyProjectile:checkCollisionWithPlayer(player)
    local playerWidth = player.width
    local playerHeight = player.height

    if checkCollision(self.x, self.y, 5, 5, player.x, player.y, playerWidth, playerHeight) then
        self.collided = true
    end
end

function EnemyProjectile:update(dt)
    self.x = self.x + self.velocityX * dt
    self.y = self.y + self.velocityY * dt
end

function EnemyProjectile:draw()
    love.graphics.circle("fill", self.x, self.y, 5)
end