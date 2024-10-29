Player = {}
Player.__index = Player
require('scripts.projectile')
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local facingTable = require("utils.direction")
local playerStates = require("utils.state")
local checkCollision = require("utils.collision")
local MapManager = require("managers.mapManager")
local powerups = require("scripts.powerups.powerupTypes")
local buffs = require("scripts.enums.buffs")
local originalSpeed = 200
local originalDamage = 1
function Player.new(x, y, animationManager)
    local instance = setmetatable({}, Player)
    instance.speed = 200
    instance.jumpHeight = -380
    instance.gravity = 800
    instance.verticalVelocity = 0
    instance.isOnGround = true
    instance.animationManager = animationManager
    instance.state = playerStates["Idle"]
    instance.facing = facingTable["Right"]
    instance.shootingDirection = facingTable["Right"]
    instance.frameIndex = 1
    instance.frameTimer = 0
    instance.frameDuration = 0.2
    instance.offsetY = 0
    instance.projectiles = {}
    instance.shootCooldown = 1 / 5
    instance.shootTimer = 0
    instance.health = 10
    instance.damage = 1
    instance.powerups = {}
    instance.currentFrames = instance.animationManager:getFrames(instance.state, instance.facing) or {}
    instance.buffs = {}

    instance.weapon = 0
    if #instance.currentFrames > 0 then
        instance.width = instance.currentFrames[1]:getWidth()
        instance.height = instance.currentFrames[1]:getHeight()
    else
        instance.width = 0
        instance.height = 0
    end

    instance.x = x or 0
    instance.y = screenHeight - instance.height

    return instance
end

function Player:tryMove(dx, dy)
    if dx ~= 0 then
        local newX = self.x + dx
        if newX >= 0 and newX + self.width <= screenWidth and not self:checkTileCollision(newX, self.y) then
            self.x = newX
        end
    end

    -- if dy ~= 0 then
    --     local newY = self.y + dy
    --     if newY >= 0 and newY + self.height <= screenHeight then
    --         if not self:checkTileCollision(self.x, newY) then
    --             self.y = newY
    --             self.isOnGround = false
    --         else
    --             if dy > 0 then
    --                 self.isOnGround = true
    --                 self.verticalVelocity = 0
    --             end
    --         end
    --     else
    --         if newY + self.height > screenHeight then
    --             self.y = screenHeight - self.height
    --             self.verticalVelocity = 0

    --             self.isOnGround = true
    --         end
    --     end
    -- end
    if dy ~= 0 then
        local newY = self.y + dy
        if newY >= 0 and newY + self.height <= screenHeight then
            if not self:checkTileCollision(self.x, newY) then
                self.y = newY
                self.isOnGround = false
            else
                if dy > 0 then
                    self.isOnGround = true
                    self.verticalVelocity = 0
                elseif dy < 0 then
                    self.verticalVelocity = 0
                end
            end
        else
            if newY + self.height > screenHeight then
                self.y = screenHeight - self.height
                self.verticalVelocity = 0
                self.isOnGround = true
            end
        end
    end
end

function Player:checkTileCollision(x, y)
    local playerBox = { x = x, y = y, width = self.width, height = self.height }
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
                    if checkCollision(playerBox.x, playerBox.y, playerBox.width, playerBox.height,
                            tileBox.x, tileBox.y, tileBox.width, tileBox.height) then
                        return true
                    end
                end
            end
        end
    end
    return false
end

function Player:shoot()
    if self.weapon == powerups.effects['Multishot'] then
        local spreadAngles = { -0.2, -0.10, 0, 0.10, 0.2 }
        for _, angle in ipairs(spreadAngles) do
            local projectile = Projectile:new(self.x, self.y, self.shootingDirection, self.state, self.facing, angle,
                self.damage)
            table.insert(self.projectiles, projectile)
        end
    else
        local projectile = Projectile:new(self.x, self.y, self.shootingDirection, self.state, self.facing, 0, self
            .damage)
        table.insert(self.projectiles, projectile)
    end


    self.shootTimer = self.shootCooldown
end

function Player:update(dt, cameraX)
    local newFrames = nil
    local movedHorizontally = false

    if love.keyboard.isDown("a") then
        if love.keyboard.isDown("w") then
            self.facing = facingTable["UpLeft"]
            self.shootingDirection = facingTable["UpLeft"]
        elseif love.keyboard.isDown("s") then
            self.facing = facingTable["DownLeft"]
            self.shootingDirection = facingTable["DownLeft"]
        else
            self.facing = facingTable["Left"]
            self.shootingDirection = facingTable["Left"]
        end

        self.state = playerStates["Running"]
        self:tryMove(-self.speed * dt, 0)
        movedHorizontally = true
    elseif love.keyboard.isDown("d") then
        if love.keyboard.isDown("w") then
            self.shootingDirection = facingTable["UpRight"]
            self.facing = facingTable["UpRight"]
        elseif love.keyboard.isDown("s") then
            self.facing = facingTable["DownRight"]
            self.shootingDirection = facingTable["DownRight"]
        else
            self.facing = facingTable["Right"]
            self.shootingDirection = facingTable["Right"]
        end

        self.state = playerStates["Running"]

        self:tryMove(self.speed * dt, 0)
        movedHorizontally = true
    elseif love.keyboard.isDown("w") then
        self.shootingDirection = facingTable["Up"]
        if self.isOnGround then
            self.state = playerStates["Idle"]
        end
        if self.facing == facingTable["Left"] then
            self.facing = facingTable["UpLeft"]
        elseif self.facing == facingTable["Right"] then
            self.facing = facingTable["UpRight"]
        end
    elseif love.keyboard.isDown('s') then
        if self.state == playerStates["Running"] then
            self.state = playerStates["Crouching"]
        end
        if self.state ~= playerStates["Jumping"] then
            self.state = playerStates["Crouching"]
        end
        if self.facing == facingTable["DownLeft"] and self.state == playerStates["Crouching"] then
            self.facing = facingTable["Left"]
        elseif self.facing == facingTable["DownRight"] and self.state == playerStates["Crouching"] then
            self.facing = facingTable["Right"]
        end

        if self.state == playerStates["Crouching"] then
            self.shootingDirection = self.facing
        else
            self.shootingDirection = facingTable["Down"]
        end
    else
        if self.isOnGround then
            self.state = playerStates["Idle"]
        end
        self.shootingDirection = self.facing
        if self.facing == facingTable["UpRight"] or self.facing == facingTable["DownRight"] then
            self.facing = facingTable["Right"]
        elseif self.facing == facingTable["UpLeft"] or self.facing == facingTable["DownLeft"] then
            self.facing = facingTable["Left"]
        end
    end

    if self.shootTimer > 0 then
        self.shootTimer = self.shootTimer - dt
    end

    if love.keyboard.isDown('p') and self.shootTimer <= 0 then
        self:shoot()
    end

    if love.keyboard.isDown("o") and self.isOnGround then
        self:jump()
    end


    if movedHorizontally then
        if not self:checkTileCollision(self.x, self.y + 1) then
            self.isOnGround = false
        end
    end
    if self.state == playerStates["Idle"] and (self.facing == facingTable["UpLeft"] or self.facing == facingTable["UpRight"]) then
        self.offsetY = -10
    elseif self.state == playerStates["Crouching"] then
        self.offsetY = 15
    else
        self.offsetY = 0
    end
    if not self.isOnGround then
        self.verticalVelocity = self.verticalVelocity + self.gravity * dt
        self:tryMove(0, self.verticalVelocity * dt)

        if self.y > screenHeight - self.height then
            self.y = screenHeight - self.height
            self.verticalVelocity = 0
            self.isOnGround = true
            if self.state == playerStates["Jumping"] then
                self.state = playerStates["Idle"]
            end
        elseif self.isOnGround then
            if self.state == playerStates["Jumping"] then
                self.state = playerStates["Idle"]
            end
        else
            self.state = playerStates["Jumping"]
        end
    end
    newFrames = self.animationManager:getFrames(self.state, self.facing) or {}
    if newFrames ~= self.currentFrames then
        self.currentFrames = newFrames
        self.frameIndex = 1
        self.frameTimer = 0
    end

    if #self.currentFrames > 0 then
        self.frameTimer = self.frameTimer + dt
        if self.frameTimer >= self.frameDuration then
            self.frameTimer = 0
            self.frameIndex = (self.frameIndex % #self.currentFrames) + 1
        end
    end

    if #self.powerups > 0 then
        for k = #self.powerups, 1, -1 do
            local v = self.powerups[k]

            v.duration = v.duration - dt
            if v.duration <= 0 then
                if v.effect == powerups.effects['Speed'] then
                    if self.buffs[buffs['Speed']] then
                        self.speed = originalSpeed
                        self.buffs[buffs['Speed']] = nil
                    end
                elseif v.effect == powerups.effects['Damage'] then
                    if self.buffs[buffs['Damage']] then
                        self.damage = originalDamage
                        self.buffs[buffs['Damage']] = nil
                    end
                end

                table.remove(self.powerups, k)
            else
                if v.effect == powerups.effects['Multishot'] then
                    self.weapon = powerups.effects['Multishot']
                end
                if v.effect == powerups.effects['Speed'] then
                    if not self.buffs[buffs['Speed']] then
                        self.speed = self.speed * v.value
                        self.buffs[buffs['Speed']] = true
                    end
                end
                if v.effect == powerups.effects['Damage'] then
                    if not self.buffs[buffs['Damage']] then
                        self.damage = self.damage * v.value
                        self.buffs[buffs['Damage']] = true
                    end
                end
            end
        end
    end
end

function Player:jump()
    if self.isOnGround then
        self.verticalVelocity = self.jumpHeight
        self.isOnGround = false
        self.state = playerStates["Jumping"]
    end
end

function Player:draw(cameraX)
    local frame = self.currentFrames[self.frameIndex]
    if frame then
        love.graphics.draw(frame, self.x - cameraX, self.y + self.offsetY)
    end
end

return Player
