require("scripts.enemyProjectile")
Enemy = {}
Enemy.__index = Enemy

local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local MapManager = require("managers.mapManager")
local checkCollision = require("utils.collision")
local facingTable = require("utils.direction")
function Enemy:new(x, y, targetX, animationManager)
    local instance = setmetatable({}, Enemy)
    instance.x = x
    instance.y = y
    instance.speed = 100
    instance.gravity = 400
    instance.jumpHeight = -280
    instance.jumpTimer = 0
    instance.verticalVelocity = 0
    instance.onGround = false
    instance.projectiles = {}
    instance.shootingCooldown = 3
    instance.shootTimer = 0
    instance.health = 3
    instance.maxHealth = 3
    instance.initialX = x
    instance.jumpCooldown = 10
    instance.targetInitialX = targetX
    instance.direction = 1
    instance.pointsAward = 1
    instance.width = 20
    instance.height = 30
    instance.animationManager = animationManager
    instance.state = "running"
    instance.facing = facingTable["Right"]
    instance.frameIndex = 1
    instance.frameTimer = 0
    instance.frameDuration = 0.2
    instance.stopDuration = 0.25
    instance.stopTimer = 0

    return instance
end

function Enemy:jump()
    if self.onGround then
        self.verticalVelocity = self.jumpHeight
        self.onGround = false
        self.jumpTimer = self.jumpCooldown
    end
end

function Enemy:tryMove(dx, dy)
    if dx ~= 0 then
        local newX = self.x + dx
        if newX >= 0 and newX + self.width <= screenWidth then
            if not self:checkTileCollision(newX, self.y) then
                self.x = newX
            else
                self:reverseDirection()
            end
        else
            self:reverseDirection()
        end
    end

    if dy ~= 0 then
        local newY = self.y + dy
        if newY >= 0 and newY + self.height <= screenHeight then
            if not self:checkTileCollision(self.x, newY) then
                self.y = newY
                self.onGround = false
            else
                if dy > 0 then
                    self.onGround = true
                    self.verticalVelocity = 0
                elseif dy < 0 then
                    self.verticalVelocity = 0
                end
            end
        else
            if newY + self.height > screenHeight then
                self.y = screenHeight - self.height
                self.verticalVelocity = 0
                self.onGround = true
            end
        end
    end
end

function Enemy:reverseDirection()
    self.direction = -self.direction
    self.facing = (self.facing == facingTable["Right"]) and facingTable["Left"] or facingTable["Right"]
end

function Enemy:checkTileCollision(x, y)
    local enemyBox = { x = x, y = y, width = self.width, height = self.height }
    local startX = math.floor(x / MapManager.tileWidth)
    local endX = math.floor((x + self.width) / MapManager.tileWidth)
    local startY = math.floor(y / MapManager.tileHeight)
    local endY = math.floor((y + self.height) / MapManager.tileHeight)

    for tileY = startY, endY do
        for tileX = startX, endX do
            if tileX >= 0 and tileY >= 0 and tileX < MapManager.mapWidth and tileY < MapManager.mapHeight then
                local tileID = MapManager.layers[1].data[tileY * MapManager.mapWidth + tileX]
                if MapManager:isCollidable(tileID) then
                    local tileBox = {
                        x = tileX * MapManager.tileWidth,
                        y = tileY * MapManager.tileHeight,
                        width = MapManager.tileWidth,
                        height = MapManager.tileHeight
                    }
                    if checkCollision(enemyBox.x, enemyBox.y, enemyBox.width, enemyBox.height,
                            tileBox.x, tileBox.y, tileBox.width, tileBox.height) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function Enemy:setState(newState)
    if self.state ~= newState then
        self.state = newState
        self.frameIndex = 1
    end
end

function Enemy:update(dt, playerX, playerY, player)
    self.jumpCooldown = math.random(6, 10)
    self.shootingCooldown = math.random(2, 6)
    if self.stopTimer > 0 then
        self.stopTimer = self.stopTimer - dt
        self:setState("shooting")
    else
        self:setState("running")

        if self.onGround or (self.onGround or self.jumpTimer > 0) then
            self:tryMove(self.direction * self.speed * dt, 0)
            if not self:checkTileCollision(self.x, self.y + 1) then
                self.onGround = false
            end
        end
    end



    self.shootTimer = self.shootTimer + dt
    if self.shootTimer >= self.shootingCooldown then
        if playerX < self.x then
            self.facing =
                facingTable["Left"]
            self.direction = -1
        else
            self.facing = facingTable["Right"]
            self.direction = 1
        end
        self:shootAt(playerX, playerY, player)

        self.shootTimer = 0
        self.stopTimer = self.stopDuration
    end

    if self.stopTimer <= 0 then
        self.frameTimer = self.frameTimer + dt
        if self.frameTimer >= self.frameDuration then
            self.frameTimer = 0
            self.frameIndex = (self.frameIndex % #self.animationManager:getFrames("basicEnemy", self.state, self.facing)) +
                1
        end
    end
    if self.jumpTimer > 0 then
        self.jumpTimer = self.jumpTimer - dt
    end
    for i = #player.projectiles, 1, -1 do
        local projectile = player.projectiles[i]

        local distance = math.sqrt((self.x - projectile.x) ^ 2 + (self.y - projectile.y) ^ 2)
        if distance <= 75 and self.jumpTimer <= 0 then
            self:jump()
        end
        projectile:checkCollisionWithEnemy(self)
        if projectile.collided then
            self.health = self.health - projectile.damage
            table.remove(player.projectiles, i)
        end
    end
    if not self.onGround then
        self.verticalVelocity = self.verticalVelocity + self.gravity * dt
        self:tryMove(0, self.verticalVelocity * dt)
    end
    for i = #self.projectiles, 1, -1 do
        local projectile = self.projectiles[i]
        projectile:update(dt)
        projectile:checkCollisionWithPlayer(player)
        if projectile.collided then
            player.health = player.health - 1
            if player.health <= 0 then
                player.lives = player.lives - 1
                player.health = 10
            end
            table.remove(self.projectiles, i)
        end
        if projectile.x < 0 or projectile.x > screenWidth or projectile.y < 0 or projectile.y > screenHeight then
            table.remove(self.projectiles, i)
        end
    end
end

function Enemy:shootAt(targetX, targetY, player)
    local projectile = EnemyProjectile:new(self.x, self.y, targetX, targetY, player)
    table.insert(self.projectiles, projectile)
end

function Enemy:draw(cameraX)
    local frames = self.animationManager:getFrames("basicEnemy", self.state, self.facing)
    local frame = frames and frames[self.frameIndex] or nil

    if frame then
        local scaleX = (self.facing == facingTable["Left"]) and -1 or 1
        love.graphics.draw(frame, self.x - cameraX, self.y, 0, scaleX, 1, self.width / 2, 0)
    end

    local barWidth = self.width
    local barHeight = 5
    local healthRatio = self.health / self.maxHealth
    local barX = self.x - 10 - cameraX
    local barY = self.y - 10

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", barX, barY, barWidth, barHeight)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", barX, barY, barWidth * healthRatio, barHeight)
    love.graphics.setColor(1, 1, 1, 1)

    for _, projectile in ipairs(self.projectiles) do
        projectile:draw(cameraX)
    end
end
