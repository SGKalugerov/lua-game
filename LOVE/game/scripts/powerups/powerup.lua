require("scripts/enemyProjectile")
Powerup = {}
Powerup.__index = Powerup
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local checkCollision = require("utils.collision")
local Linq = require("utils.Linq")
local powerups = require("scripts.powerups.powerupTypes")
function Powerup:new(x, y, type)
    local instance = setmetatable({}, Powerup)
    instance.x = x
    instance.y = y
    instance.gravity = 400
    instance.verticalVelocity = 0
    instance.effect = type.effect
    instance.duration = type.duration
    instance.category = type.category
    instance.value = type.value
    instance.onGround = false
    instance.initialX = x
    instance.collided = false
    instance.aliveTimer = 0
    instance.aliveDuration = 10
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

function Powerup:update(dt, player)
    if not self.onGround then
        self.verticalVelocity = self.verticalVelocity + self.gravity * dt
        self.y = self.y + self.verticalVelocity * dt
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
    love.graphics.rectangle("fill", self.x - cameraX, self.y, 20, 20)
end
