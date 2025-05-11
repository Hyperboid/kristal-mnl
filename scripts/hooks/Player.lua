---@class Player : Player
---@field world World
local Player, super = Class(Player)

function Player:init(...)
    super.init(self,...)
    self.z_vel = 0
    self.jump_buffer = -math.huge
    self.state_manager:addState("AIR", {update = self.updateAir, enter = self.beginAir, leave = self.endAir})
    self.walk_speed = 8
    self.force_walk = true
    self:addFX(GroundMaskFX())
    self.coyote_time = 0
    self.gravity, self.jump_velocity = MNL:getJumpPhysics((3.2)*20, .35)
end


function Player:update()
    if self.world.map.side then
        self.z = 0
        self.draw_shadow = false
    end
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
    self.desired_action = self:getDesiredAction()
    if self.world.player:isMovementEnabled() then
        local button = self:getPartyMember().button or "confirm"
        if Input.pressed(button) then
            if self:doAction(self.desired_action) then
                Input.clear(button, true)
            end
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
    if self.world.map.side then
        self.z = 0
    end
end


function Player:updateHistory()
    if #self.history == 0 then
        table.insert(self.history, { x = self.x, y = self.y, time = 0 })
    end

    local moved = self.x ~= self.last_move_x or (not self.world.map.side and self.y ~= self.last_move_y)

    local auto = self.auto_moving

    if moved then
        self.history_time = self.history_time + DT

        table.insert(self.history, 1,
            { x = self.x, y = self.y, facing = self.facing, time = self.history_time, state = self.state_manager.state,
                state_args = self.state_manager.args, auto = auto })
        while (self.history_time - self.history[#self.history].time) > (Game.max_followers * FOLLOW_DELAY) do
            table.remove(self.history, #self.history)
        end
    end

    for _, follower in ipairs(self.world.followers) do
        follower:updateHistory(moved, auto)
    end

    self.last_move_x = self.x
    self.last_move_y = self.y
end

function Player:isOnFloor()
    if self.world.map.side then
        self.y = self.y + 4
        local collided, collided_object = self:checkSolidCollision()
        self.y = self.y - 4
        return collided, collided_object
    else
        self.z = self.z - 4
        local collided, collided_object = self:checkSolidCollision()
        self.z = self.z + 4
        return collided, collided_object
    end
end

function Player:updateWalk()
    super.updateWalk(self)
    if not self:isOnFloor() then
        self.coyote_time = (3/30)
        self.state_manager:setState("AIR")
    end
    if self.jump_buffer > 0 then
        self.jump_buffer = 0
        self.coyote_time = 0
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
    if not self.world.map.side then
        if Input.down("up") then
            y = -1
        elseif Input.down("down") then
            y = 1
        end
    end
    return x, y
end

function Player:isOutOfRange()
    -- do return false end
    ---@type Follower
    local follower = self.is_player and self.world.followers[1]
    if follower then
        local dist = ((self.walk_speed * 15) * FOLLOW_DELAY) + self.walk_speed
        if (not self.world.map.side) and (Utils.dist(0,self.y,0,follower.y) > dist) then
            return true
        end
        if Utils.dist(self.x,0,follower.x,0) > dist then
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

---@return PartyMember
function Player:getPartyMember()
    return Game:getPartyMember(self.party)
end

function Player:jump()
    self.z_vel = self.jump_velocity
    Assets.playSound(self:getPartyMember().jump_sound, 1, 1)
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
    self.coyote_time = 0
end

function Player:moveZ(z, speed)
    if self.world.map.side then
        z = (z or 0) * -(speed or 1)
        local dir = Utils.sign(z)
        for i=1,math.ceil(math.abs(z)) do
            local moved = dir
            if (i > math.abs(z)) then
                moved = (math.abs(z) % 1) * dir
            end
            local prev_z = self.y
            self.y = self.y + (moved*2)
            local collided, collided_object = self:checkSolidCollision()
            if collided then
                if collided_object and collided_object.onHit then
                    collided_object:onHit(self, "jump")
                end
                if moved < 0 then
                    self:setState("WALK")
                else
                    self.y = prev_z
                    self.z_vel = math.abs(self.z_vel) * -moved
                end
                return collided, collided_object
            end
        end
    else
        return self:fullMoveZ(z,speed)
    end
end

function Player:fullMoveZ(z, speed)
    z = (z or 0) * (speed or 1)
    local dir = Utils.sign(z)
    for i=1,math.ceil(math.abs(z)) do
        local moved = dir
        if (i > math.abs(z)) then
            moved = (math.abs(z) % 1) * dir
        end
        local prev_z = self.z
        self.z = self.z + moved
        local collided, collided_object = self:checkSolidCollision()
        if collided then
            if collided_object and collided_object.onHit then
                collided_object:onHit(self, "jump")
            end
            if moved < 0 then
                self:setState("WALK")
            else
                self.z = prev_z
                self.z_vel = math.abs(self.z_vel) * -moved
            end
            return collided, collided_object
        end
    end
end

function Player:updateAir()
    local collided = false
    if self:isMovementEnabled() then
        collided = self:moveZ(self.z_vel * DT)
        if not NOCLIP then
        self.z_vel = math.max(-300, self.z_vel - (self.gravity*DT))
        end
        local x, y = self:getDesiredMovement(self.walk_speed)
        self:move(x,y, DTMULT * self.walk_speed)
    end
    local ground_level, ground_obj = self:getGroundLevel()
    local is_on_floor, floor_obj = self:isOnFloor()
    if is_on_floor and self.z_vel <= 0 then
        self:setState("WALK")
        self.z_vel = 1
        if self.world.map.side then
            self.y = self.y - 8
            for i = 1, 16 do
                self.y = math.floor(self.y+1)
                if self:checkSolidCollision() then
                    self.y = self.y - 1
                    break
                end
            end
        else
            self.z = floor_obj and (floor_obj.target_z or (floor_obj.collider and floor_obj.collider:getZ() or floor_obj.z)) or 0
        end
        if ground_obj and ground_obj.onHit then
            ground_obj:onHit(self, "jump")
        end
    elseif self.coyote_time > 0 then
        self.coyote_time = self.coyote_time - DT
        local button = self:getPartyMember().button or "confirm"
        if Input.pressed(button) then
            self:jump()
        end
    end
end

function Player:draw()
    super.draw(self)
    if DEBUG_RENDER and self.is_player then
        love.graphics.scale(0.5)
        love.graphics.setFont(Assets.getFont("main_mono", 16))
        love.graphics.print(self.state_manager.state.."\n"..self.z.."\n"..self.z_vel.."\n"..self.jump_buffer)
    end
end

function Player:findInteractable()
    if not self.is_player then return end
    Object.startCache()
    local interactables = {}
    local col = self.interact_collider[self.facing]
    for _, obj in ipairs(self.world.children) do
        if obj.onInteract and obj:collidesWith(col) then
            Object.endCache()
            return obj
        end
    end
    Object.endCache()
end

function Player:getDesiredAction()
    if self.world.action_index == 1 then
        local interactable = self:findInteractable()
        if interactable then
            if interactable:includes(Character) then
                return "talk"
            else
                return "interact"
            end
        end
        return "jump"
        
    end
end

function Player:interact()
    -- Do nothing to override default behavior
end

function Player:doInteract()
    super.interact(self)
end

function Player:doAction(action)
    if (action or "none") == "none" then return end
    if action == "jump" then
        self.jump_buffer = 3
    elseif self.is_player and (action == "interact" or action == "talk") then
        self:doInteract()
        return true
    end
end

return Player