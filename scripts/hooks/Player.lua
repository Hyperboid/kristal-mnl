---@class Player : Player
local Player, super = Class(Player)

function Player:init(...)
    super.init(self,...)
    self.z_vel = 0
    self.jump_buffer = -math.huge
    self.state_manager:addState("AIR", {update = self.updateAir, enter = self.beginAir, leave = self.endAir})
    self.walk_speed = 6
    self.force_walk = true
    self:addFX(GroundMaskFX())
end


function Player:update()
    if self.oor_pos then
        local oor_pos = self.oor_pos
        self.oor_pos = nil
        local ox, oy = self.x, self.y
        self.x = oor_pos[1]
        if not self:isOutOfRange() then goto done end
        self.x = ox
        self.y = oor_pos[2]
        if not self:isOutOfRange() then print("a")goto done end
        self.x = oor_pos[1]
        ::done::
        -- self.last_x, self.last_y = ox, oy
    end
    if self.is_player and self:isMovementEnabled() then
        local button = Game:getPartyMember(self.party).button or "confirm"
        if Input.pressed(button) then
            Input.clear(button)
            self.jump_buffer = 3
        end
    end
    super.update(self)
    self.jump_buffer = self.jump_buffer - DTMULT
    -- BUG: This odd solution is intended to allow holding away from a hole
    -- while the follower jumps out of it. However, this has the side effect
    -- of preventing you from sliding on this invisible wall.
    if self:isOutOfRange() then
        self.oor_pos = {self.last_x, self.last_y}
        self:setPosition(unpack(self.oor_pos))
        local o_dt, o_dtmult = DT, DTMULT
        DT, DTMULT = 0, 0
        self:updateHistory()
        DT, DTMULT = o_dt, o_dtmult
    end
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

function Player:getDesiredMovement(speed)
    local x, y = 0, 0
    if Input.down("left") then
        x = - 1
    elseif Input.down("right") then
        x = 1
    end
    if Input.down("up") then
        y = -1
    elseif Input.down("down") then
        y = 1
    end
    return x, y
end

function Player:isOutOfRange()
    -- do return false end
    ---@type Follower
    local follower = self.is_player and self.world.followers[1]
    if follower then
        if Utils.dist(0,self.y,0,follower.y) > (self.walk_speed*6) + 4 then
            return true
        end
        if Utils.dist(self.x,0,follower.x,0) > (self.walk_speed*6) + 4 then
            return true
        end
        if Utils.dist(self.x,self.y,follower.x,follower.y) > (self.walk_speed*self.walk_speed*6) then
            return true
        end
    end
    return false
end

function Player:handleMovement()
    local walk_x, walk_y = self:getDesiredMovement(self.walk_speed)

    self.moving_x = walk_x
    self.moving_y = walk_y

    local running = (Input.down("cancel") or self.force_run) and not self.force_walk
    if Kristal.Config["autoRun"] and not self.force_run and not self.force_walk then
        running = not running
    end

    if self.force_run and not self.force_walk then
        self.run_timer = 200
    end

    local speed = self.walk_speed
    if running then
        if self.run_timer > 60 then
            speed = speed + (Game:isLight() and 6 or 5)
        elseif self.run_timer > 10 then
            speed = speed + 4
        else
            speed = speed + 2
        end
    end

    self:move(walk_x, walk_y, speed * DTMULT)

    if not running or self.last_collided_x or self.last_collided_y then
        self.run_timer = 0
    elseif running then
        if walk_x ~= 0 or walk_y ~= 0 then
            self.run_timer = self.run_timer + DTMULT
            self.run_timer_grace = 0
        else
            -- Dont reset running until 2 frames after you release the movement keys
            if self.run_timer_grace >= 2 then
                self.run_timer = 0
            end
            self.run_timer_grace = self.run_timer_grace + DTMULT
        end
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
    self:setSprite("jump")
    if not self.sprite.texture then
        self:setSprite("walk/"..self.facing.."_2")
    end
end

function Player:endAir()
    self:resetSprite()
    self.physics.speed_x = 0
    self.physics.speed_y = 0
    self.z_vel = 0
end

function Player:moveZ(z, speed)
    z = (z or 0) * (speed or 1)
    local dir = Utils.sign(z)
    for i=1,z,dir do
        
        local prev_z = self.z
        self.z = self.z + dir
        if self:checkSolidCollision() then
            if self:getGroundLevel() >= self.z then
                self:setState("WALK")
            else
                self.z = prev_z
                self.z_vel = math.abs(self.z_vel) * -dir
            end
            return
        end
    end
end

function Player:updateAir()
    self:moveZ(self.z_vel * (DTMULT*4))
    self.z_vel = math.max(-10, self.z_vel - (DTMULT/3.5))
    if self:isMovementEnabled() then
        local x, y = self:getDesiredMovement(self.walk_speed)
        self:move(x,y, DTMULT * self.walk_speed)
    end
    local ground_level = self:getGroundLevel()
    if self.z < ground_level then
        self:setState("WALK")
        self.z = ground_level
    end
end

return Player