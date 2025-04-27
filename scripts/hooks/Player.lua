---@class Player : Player
local Player, super = Class(Player)

function Player:init(...)
    super.init(self,...)
    self.z_vel = 0
    self.jump_buffer = -math.huge
    self.state_manager:addState("AIR", {update = self.updateAir, enter = self.beginAir, leave = self.endAir})
    self.walk_speed = self.walk_speed + 2
    self:addFX(GroundMaskFX())
end

function Player:interact()
    if super.interact(self) then
        return true
    else
        self.jump_buffer = 3
    end
end

function Player:update()
    super.update(self)
    self.jump_buffer = self.jump_buffer - DTMULT
end

function Player:updateWalk()
    super.updateWalk(self)
    local ground_level = self:getGroundLevel()
    if self.z > ground_level then
        self.state_manager:setState("AIR")
    elseif self.z < ground_level then
        self.z = ground_level
    elseif self.jump_buffer > 0 then
        self.jump_buffer = 0
        self:jump()
    end
end

function Player:jump()
    self.z_vel = 3
    Assets.playSound("jump", .5, 2)
    self.state_manager:setState("AIR")
end

function Player:beginAir()
    -- self.physics.speed_x = (self.x - self.last_x)/DTMULT
    -- self.physics.speed_y = (self.y - self.last_y)/DTMULT
    self:setSprite("walk/"..self.facing.."_2")
end

function Player:endAir()
    self:resetSprite()
    self.physics.speed_x = 0
    self.physics.speed_y = 0
    self.z_vel = 0
end

function Player:updateAir()
    if self.z < -100 then
        self.world:hurtParty(1)
    end
    self.z = self.z + (self.z_vel * (DTMULT*4))
    self.z_vel = math.max(-10, self.z_vel - (DTMULT/3.5))
    if self:isMovementEnabled() then
        if Input.down("left") and self.physics.speed_x >= 0 then
            self:move(-self.walk_speed, 0, DTMULT)
        elseif Input.down("right") and self.physics.speed_x <= 0 then
            self:move(self.walk_speed, 0, DTMULT)
        end
        if Input.down("up") and self.physics.speed_y >= 0 then
            self:move(0, -self.walk_speed, DTMULT)
        elseif Input.down("down") and self.physics.speed_y <= 0 then
            self:move(0, self.walk_speed, DTMULT)
        end
    end
    local ground_level = self:getGroundLevel()
    if self.z < ground_level then
        self:setState("WALK")
        self.z = ground_level
    end
end

return Player