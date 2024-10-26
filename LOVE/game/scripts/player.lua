Player = {}
Player.__index = Player
require('scripts.projectile')
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()
local facingTable = require("utils.direction")
local playerStates = require("utils.state")
function Player.new(x, y, animationManager)
    local instance = setmetatable({}, Player)
    instance.speed = 300
    instance.jumpHeight = -500 
    instance.gravity = 1000 
    instance.verticalVelocity = 0
    instance.isOnGround = true 
    instance.animationManager = animationManager
    instance.speed = 350
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

    instance.currentFrames = instance.animationManager:getFrames(instance.state, instance.facing) or {}

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

function Player:jump()
    if self.isOnGround then
        self.verticalVelocity = self.jumpHeight
        self.isOnGround = false
        self.state = playerStates["Jumping"]
    end
end

function Player:update(dt)
    local moving = false
    local newFrames = nil
    if love.keyboard.isDown("left") then
        if love.keyboard.isDown("up") then
            self.facing = facingTable["UpLeft"]
            self.shootingDirection = facingTable["UpLeft"]
        elseif love.keyboard.isDown("down") then
            self.facing = facingTable["DownLeft"]
            self.shootingDirection = facingTable["DownLeft"]
        else
            self.facing = facingTable["Left"]
            self.shootingDirection = facingTable["Left"]
        end
        self.state = playerStates["Running"]
        moving = true
        self.x = math.max(0, self.x - self.speed * dt)
    elseif love.keyboard.isDown("right") then
        if love.keyboard.isDown("up") then
            self.shootingDirection = facingTable["UpRight"]
            self.facing = facingTable["UpRight"]
        elseif love.keyboard.isDown("down") then
            self.facing = facingTable["DownRight"]
            self.shootingDirection = facingTable["DownRight"]
        else
            self.facing = facingTable["Right"]
            self.shootingDirection = facingTable["Right"]
        end
        self.state = playerStates["Running"]
        moving = true
        self.x = math.min(screenWidth - self.width, self.x + self.speed * dt)
    elseif love.keyboard.isDown("up") then
        self.shootingDirection = facingTable["Up"]
        if self.facing == facingTable["Left"] then
            self.facing = facingTable["UpLeft"]
        elseif self.facing == facingTable["Right"] then
            self.facing = facingTable["UpRight"]
        end
    elseif love.keyboard.isDown('down') then
        self.shootingDirection = facingTable["Down"]
        -- if self.state ~= playerStates["Running"] and self.state ~= playerStates["Jumping"] then
        --     self.state = playerStates["Crouching"]
        -- end
        if self.facing == facingTable["Left"] then
            self.facing = facingTable["DownLeft"]
        elseif self.facing == facingTable["Right"] then
            self.facing = facingTable["DownRight"]
        end
        if self.state ~= playerStates["Running"] and self.state ~= playerStates["Jumping"] then
            self.state = playerStates["Crouching"]
        end
    else
        moving = false
        self.shootingDirection = self.facing
        self.state = playerStates["Idle"]
        if self.facing == facingTable["UpRight"] or self.facing == facingTable["DownRight"] then
            self.facing = facingTable["Right"]
        elseif self.facing == facingTable["UpLeft"] or self.facing == facingTable["DownLeft"] then
            self.facing = facingTable["Left"]
        end
    end

    if self.shootTimer > 0 then
        self.shootTimer = self.shootTimer - dt
    end

    if love.keyboard.isDown('ralt') and self.shootTimer <= 0 then
        -- if self.facing == facingTable["Down"] and not playerStates["Jumping"] then
        --     return
        -- end
        local projectile = Projectile:new(self.x, self.y, self.shootingDirection, self.state)
        table.insert(self.projectiles, projectile)
        self.shootTimer = self.shootCooldown 
    end

    if self.state == playerStates["Idle"] and (self.facing == facingTable["UpLeft"] or self.facing == facingTable["UpRight"]) then
        self.offsetY = -10 
    elseif self.state == playerStates["Crouching"] then
        self.offsetY = 15
    else
        self.offsetY = 0 
    end

    if love.keyboard.isDown("space") and self.isOnGround then
        self:jump()
    end
    
    if not self.isOnGround then
        self.verticalVelocity = self.verticalVelocity + self.gravity * dt
        self.y = self.y + self.verticalVelocity * dt
        self.state = playerStates["Jumping"]
        if self.y >= screenHeight - self.height then
            self.y = screenHeight - self.height
            self.verticalVelocity = 0
            self.isOnGround = true
            self.state = playerStates["Idle"]
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

    -- if not moving and not playerStates["Jumping"] then
    --     self.state = playerStates["Idle"]
    -- end
end

function Player:draw()
    local frame = self.currentFrames[self.frameIndex]
    if frame then
        love.graphics.draw(frame, self.x, self.y + self.offsetY)
    end
end