Projectile = {}
Projectile.__index = Projectile
local facingTable = require("utils.direction")
local playerStates = require("utils.state")
function Projectile:new(x, y, direction, state, facing)
    local instance = setmetatable({}, Projectile)
    instance.x = x
    instance.y = y
    instance.direction = direction
    instance.speed = 600
    instance.ownerState = state
    instance.offsetY = 0
    instance.offsetX = 0
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
    instance.x = instance.x + instance.offsetX
    instance.y = instance.y + instance.offsetY
    return instance
end

function Projectile:update(dt)
    if self.direction == facingTable["Up"] then
        self.y = self.y - self.speed * dt
    elseif self.direction == facingTable["Left"] then
        self.x = self.x - self.speed * dt
    elseif self.direction == facingTable["UpLeft"] then
        self.x = self.x - self.speed * dt
        self.y = self.y - self.speed * dt
    elseif self.direction == facingTable["DownLeft"] then
        self.x = self.x - self.speed * dt
        self.y = self.y + self.speed * dt
    elseif self.direction == facingTable["Right"] then
        self.x = self.x + self.speed * dt
    elseif self.direction == facingTable["UpRight"] then
        self.x = self.x + self.speed * dt
        self.y = self.y - self.speed * dt
    elseif self.direction == facingTable["DownRight"] then
        self.x = self.x + self.speed * dt
        self.y = self.y + self.speed * dt
    elseif self.direction == facingTable["Down"] and self.ownerState == playerStates["Jumping"] then
        self.y = self.y + self.speed * dt
    elseif self.ownerState == playerStates["Crouching"] and (self.direction == facingTable["DownRight"] or self.direction == facingTable["UpRight"] or self.direction == facingTable["Right"]) then
        self.x = self.x + self.speed * dt
    elseif self.ownerState == playerStates["Crouching"] and (self.direction == facingTable["DownLeft"] or self.direction == facingTable["UpLeft"] or self.direction == facingTable["Left"]) then
        self.x = self.x - self.speed * dt
    end
end

function Projectile:draw()
    local projectile = love.graphics.newImage("assets/projectile1.png")
    love.graphics.draw(projectile, self.x, self.y)
end
