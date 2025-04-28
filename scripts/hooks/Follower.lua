if not CLASS_NAME_GETTER("Player").updateAir then
    error{included = "Player"}
end
---@class Follower : Player
local Follower, super = Class("Player")

function Follower:init(...)
    super.init(self,...)
    self.z_vel = 0
    self.index = 0
    self.persistent = false
    self.is_player = false
    self.is_follower = true
    -- self.active = false
    -- self.timescale = 0.5
end

function Follower:updateIndex() end
function Follower:updateHistory() end

function Follower:getDesiredMovement(speed)
    ---@type Player
    local target = self.world.player
    local x, y = target:getRelativePosFor(self)
    x = x - self.width/2
    y = y - self.height
    -- TODO: Delete this (see Player:checkSolidCollision)
    do
        if target then
            if Utils.dist(self.x,0,target.x,0) < 40 and Utils.dist(0,self.y,0,target.y) < 40 then
                x = 0
                y = 0
            end
            -- if Utils.dist(0,self.y,0,target.y) < 40 then
            --     y = 0
            -- end
        end
    end
    return Utils.clamp(x/speed, -1,1), Utils.clamp(y/speed, -1, 1)
end

function Follower:update()
    self.noclip = false
    super.update(self)
    if self.state_manager.state == "WALK" then

        local ground_level = self:getGroundLevel()
        if self.z > ground_level then
            self.state_manager:setState("AIR")
        elseif self.z < ground_level then
            self.z = ground_level
        elseif self.world.player:isMovementEnabled() then
            if Input.pressed("cancel") then
                self:jump()
            end
        end
    end
end


function Follower:jump()
    self.z_vel = 3
    Assets.playSound("jump", .5, 1.8)
    self.state_manager:setState("AIR")
end

function Follower:beginAir()
    -- self.physics.speed_x = (self.x - self.last_x)/DTMULT
    -- self.physics.speed_y = (self.y - self.last_y)/DTMULT
    self:setSprite("walk/"..self.facing.."_2")
end

function Follower:endAir()
    self:resetSprite()
    self.physics.speed_x = 0
    self.physics.speed_y = 0
    self.z_vel = 0
end

return Follower