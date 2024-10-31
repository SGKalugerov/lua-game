Projectile = {}
Projectile.__index = Projectile
local facingTable = require("utils.direction")
local playerStates = require("utils.state")
local checkCollision = require("utils.collision")

function Projectile:new(x, y, direction, state, facing, angle, damage, sprite, spriteRotation)
    local instance = setmetatable({}, Projectile)
    instance.x = x
    instance.y = y
    instance.direction = direction
    instance.speed = 600
    instance.ownerState = state
    instance.travelDistance = 1200
    instance.offsetY = 0
    instance.offsetX = 0
    instance.angle = angle
    instance.velocityX = 0
    instance.velocityY = 0
    instance.sprite = sprite
    instance.spriteRotation = spriteRotation or 0
    instance.damage = damage and damage or 1
    if state == playerStates["Crouching"] then
        if facing == facingTable["Left"] then
            if direction == facingTable["Left"] then
                instance.offsetY = 15
                instance.offsetX = 0
            elseif direction == facingTable["UpLeft"] then
                instance.offsetX = -20
                instance.offsetY = -5
            elseif direction == facingTable["DownLeft"] then
                instance.offsetX = -20
                instance.offsetY = 10
            end
        elseif facing == facingTable["Right"] then
            if direction == facingTable["Right"] then
                instance.offsetY = 15
                instance.offsetX = 25
            elseif direction == facingTable["UpRight"] then
                instance.offsetX = 20
                instance.offsetY = -5
            elseif direction == facingTable["DownRight"] then
                instance.offsetX = 20
                instance.offsetY = 10
            end
        end
    elseif direction == facingTable["Up"] then
        if facing == facingTable["UpLeft"] then
            instance.offsetX = 0
        elseif facing == facingTable["UpRight"] then
            instance.offsetX = 8
        end
    elseif direction == facingTable["UpLeft"] then
        instance.offsetX = facing == facingTable["UpLeft"] and 0 or -5
    elseif direction == facingTable["UpRight"] then
        instance.offsetX = facing == facingTable["UpRight"] and 20 or 10
    elseif direction == facingTable["Down"] then
        instance.offsetX = 5
    elseif direction == facingTable["DownLeft"] then
        instance.offsetX = facing == facingTable["DownLeft"] and 5 or -5
    elseif direction == facingTable["DownRight"] then
        instance.offsetX = facing == facingTable["DownRight"] and 5 or -5
    end

    local baseAngle
    if direction == facingTable["Right"] then
        baseAngle = 0
    elseif direction == facingTable["UpRight"] then
        baseAngle = -math.pi / 4
    elseif direction == facingTable["Up"] then
        baseAngle = -math.pi / 2
    elseif direction == facingTable["UpLeft"] then
        baseAngle = -3 * math.pi / 4
    elseif direction == facingTable["Left"] then
        baseAngle = math.pi
    elseif direction == facingTable["DownLeft"] then
        baseAngle = 3 * math.pi / 4
    elseif direction == facingTable["Down"] then
        baseAngle = math.pi / 2
    elseif direction == facingTable["DownRight"] then
        baseAngle = math.pi / 4
    end

    local finalAngle = baseAngle + instance.angle
    instance.velocityX = instance.speed * math.cos(finalAngle)
    instance.velocityY = instance.speed * math.sin(finalAngle)
    instance.x = instance.x + instance.offsetX
    instance.y = instance.y + instance.offsetY
    return instance
end

function Projectile:update(dt)
    self.x = self.x + self.velocityX * dt
    self.y = self.y + self.velocityY * dt
    self.travelDistance = self.travelDistance - self.speed * dt
end

function Projectile:checkCollisionWithEnemy(enemy)
    local enemyWidth = 20
    local enemyHeight = 20

    if checkCollision(self.x, self.y, 5, 5, enemy.x, enemy.y, enemyWidth, enemyHeight) then
        self.collided = true
    end
end

function Projectile:draw(cameraX)
    local projectile
    if self.sprite ~= nil then
        projectile = love.graphics.newImage(self.sprite)
    else
        projectile = love.graphics.newImage("assets/weapons/projectile.png")
    end
    love.graphics.draw(projectile, self.x - cameraX, self.y, self.spriteRotation)
end
