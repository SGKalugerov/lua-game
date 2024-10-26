Projectile = {}
Projectile.__index = Projectile
local facingTable = require("utils.direction")
local playerStates = require("utils.state")
function Projectile:new(x, y, direction, state)
    local instance = setmetatable({}, Projectile)
    instance.x = x
    instance.y = y
    instance.direction = direction
    instance.speed = 600
    instance.ownerState = state

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
    elseif self.direction == facingTable["Down"] and self.ownerState ~= playerStates["Crouching"] then
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