require("scripts.enemyProjectile")
Powerup = {}
Powerup.__index = Powerup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local Linq = require("utils.Linq")
local powerups = require("scripts.powerups.powerupTypes")
local MapManager = require("managers.mapManager")
local checkCollision = require("utils.collision")
function Powerup:new(x, y, type)
    local instance = setmetatable({}, Powerup)
    instance.x = x
    instance.y = y
    instance.height = 20
    instance.width = 20
    instance.gravity = 400
    instance.verticalVelocity = 0
    instance.effect = type.effect
    instance.duration = type.duration
    instance.category = type.category
    instance.value = type.value
    instance.sprite = nil
    instance.onGround = false
    instance.initialX = x
    instance.collided = false
    instance.aliveTimer = 0
    instance.aliveDuration = 10
    instance.onGround = false
    instance.verticalVelocity = 0
    if type.spritePath ~= nil then
        instance.sprite = love.graphics.newImage(type.spritePath)
        instance.height = instance.sprite:getHeight()
        instance.width = instance.sprite:getWidth()
    end


    return instance
end

function Powerup:checkCollisionWithPlayer(player)
    if checkCollision(self.x, self.y, 5, 5, player.x, player.y, player.width, player.height) then
        self.collided = true
        Powerup:applyWeapon(player, self)
        Powerup:applyBuff(player, self)
    end
end

function Powerup:applyWeapon(player, powerup)
    if powerup.category == powerups.category["Weapon"] then
        local existingWeaponIndex = FindIndex(player.powerups, function(powerup)
            return powerup.category == powerups.category["Weapon"]
        end)

        if existingWeaponIndex then
            table.remove(player.powerups, existingWeaponIndex)
        end

        table.insert(player.powerups, powerup)
    else
        table.insert(player.powerups, powerup)
    end
end

function Powerup:applyBuff(player, powerup)
    if powerup.category == powerups.category["Buff"] then
        local existingBuffIndex = FindIndex(player.powerups, function(powerup)
            return powerup.effect == powerup.effect
        end)

        if existingBuffIndex then
            table.remove(player.powerups, existingBuffIndex)
        end

        table.insert(player.powerups, powerup)
    end
end

function Powerup:checkTileCollision(x, y)
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

function Powerup:tryMove(dx, dy)
    -- if dx ~= 0 then
    --     local newX = self.x + dx
    --     if newX >= 0 and newX + self.width <= screenWidth then
    --         if not self:checkTileCollision(newX, self.y) then
    --             self.x = newX
    --         else
    --             self:reverseDirection()
    --         end
    --     else
    --         self:reverseDirection()
    --     end
    -- end

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

function Powerup:update(dt, player)
    if not self.onGround then
        self.verticalVelocity = self.verticalVelocity + self.gravity * dt
        -- self.y = self.y + self.verticalVelocity * dt
        self:tryMove(0, self.verticalVelocity * dt)

        if self.y >= screenHeight - 20 then
            self.y = screenHeight - 20
            self.verticalVelocity = 0
            self.onGround = true
        end
    end



    --  self:checkCollisionWithPlayer(player)
    -- if self.onGround then
    --     if self.initialX > self.targetInitialX then
    --         self.x = self.x - self.speed * dt
    --     else
    --         self.x = self.x + self.speed * dt
    --     end
    --     -- if playerX > self.x then
    --     --     self.x = self.x + self.speed * dt
    --     -- elseif playerX < self.x then
    --     --     self.x = self.x - self.speed * dt
    --     -- end
    -- end
end

function Powerup:draw(cameraX)
    if self.sprite ~= nil then
        love.graphics.draw(self.sprite, self.x - cameraX, self.y)
    else
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", self.x - cameraX, self.y, 20, 20)
        love.graphics.setColor(1, 1, 1, 1)
    end
end
