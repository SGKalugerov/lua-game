AnimationManager = {}
AnimationManager.__index = AnimationManager
local facingTable = require("utils.direction")
local playerStates = require("utils.state")
function AnimationManager.new()
    local instance = setmetatable({}, AnimationManager)
    
    instance.animations = {
        [facingTable["Left"]] = {
            [playerStates["Idle"]] = {"assets/idle_left1.png", "assets/idle_left2.png"},
            [playerStates["Running"]] = {"assets/run_left1.png", "assets/run_left2.png", "assets/run_left3.png", "assets/run_left4.png", "assets/run_left5.png"},
            [playerStates["Jumping"]] = {"assets/jump_1.png", "assets/jump_2.png", "assets/jump_3.png", "assets/jump_4.png"},
            [playerStates["Crouching"]] = {"assets/crouch_left1.png"},
        },
        [facingTable["Right"]] = {
            [playerStates["Idle"]] = {"assets/idle_right1.png", "assets/idle_right2.png"},
            [playerStates["Running"]] = {"assets/run_right1.png", "assets/run_right2.png", "assets/run_right3.png", "assets/run_right4.png", "assets/run_right5.png"},
            [playerStates["Jumping"]] = {"assets/jump_1.png", "assets/jump_2.png", "assets/jump_3.png", "assets/jump_4.png"},
            [playerStates["Crouching"]] = {"assets/crouch_right1.png"},
        },
        [facingTable["DownLeft"]] = {
            [playerStates["Idle"]] = {"assets/idle_left1.png", "assets/idle_left2.png"},
            [playerStates["Running"]] = {"assets/run_left1.png", "assets/run_left2.png", "assets/run_left3.png", "assets/run_left4.png", "assets/run_left5.png"},
            [playerStates["Jumping"]] = {"assets/jump_1.png", "assets/jump_2.png", "assets/jump_3.png", "assets/jump_4.png"},
            [playerStates["Crouching"]] = {"assets/crouch_left1.png"},
        },
        [facingTable["DownRight"]] = {
            [playerStates["Idle"]] = {"assets/idle_right1.png", "assets/idle_right2.png"},
            [playerStates["Running"]] = {"assets/run_right1.png", "assets/run_right2.png", "assets/run_right3.png", "assets/run_right4.png", "assets/run_right5.png"},
            [playerStates["Jumping"]] = {"assets/jump_1.png", "assets/jump_2.png", "assets/jump_3.png", "assets/jump_4.png"},
            [playerStates["Crouching"]] = {"assets/crouch_right1.png"},
        },
        [facingTable["UpLeft"]] = {
            [playerStates["Idle"]] = {"assets/idle_upleft1.png", "assets/idle_upleft2.png"},
            [playerStates["Running"]] = {"assets/run_upleft1.png", "assets/run_upleft2.png", "assets/run_upleft3.png"},
            [playerStates["Jumping"]] = {"assets/jump_1.png", "assets/jump_2.png", "assets/jump_3.png", "assets/jump_4.png"},
        },
        [facingTable["UpRight"]] = {
            [playerStates["Idle"]] = {"assets/idle_upright1.png", "assets/idle_upright2.png"},
            [playerStates["Running"]] = {"assets/run_upright1.png", "assets/run_upright2.png", "assets/run_upright3.png"},
            [playerStates["Jumping"]] = {"assets/jump_1.png", "assets/jump_2.png", "assets/jump_3.png", "assets/jump_4.png"},
        },
      
    }

    for _, directionTable in pairs(instance.animations) do
        for _, frames in pairs(directionTable) do
            for i, framePath in ipairs(frames) do
                frames[i] = love.graphics.newImage(framePath)
            end
        end
    end

    return instance
end

function AnimationManager:getFrames(state, facing)
    local directionTable = self.animations[facing]
    if directionTable then
        return directionTable[state]
    end
    return nil 
end
