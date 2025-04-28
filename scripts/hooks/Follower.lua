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
    self.following = true
    -- self.active = false
    -- self.timescale = 0.5
end

function Follower:updateIndex() end
function Follower:updateHistory(moved, auto)
    if moved == nil then return end
    if moved then
        self.blush_timer = 0
    end
    local target = self:getTarget()
    
    local auto_move = auto
    
    if moved or auto_move then
        self.history_time = self.history_time + DT

        table.insert(self.history, 1, {x = target.x, y = target.y, facing = target.facing, time = self.history_time, state = target.state, state_args = target.state_manager.args, auto = auto})
        while (self.history_time - self.history[#self.history].time) > (Game.max_followers * FOLLOW_DELAY) do
            table.remove(self.history, #self.history)
        end

        if self.following and not self.physics.move_target then
            self:moveToTarget()
        end
    end
end

function Follower:getTarget()
    return self.target or self.world.player
end


function Follower:moveToTarget(speed)
    if speed == nil then
        speed = 8
    end
    if self:getTarget() then
        local tx, ty, facing, state, args = self:getTargetPosition()
        local dx, dy = tx - self.x, ty - self.y

        if speed then
            dx = Utils.approach(self.x, tx, speed * DTMULT) - self.x
            dy = Utils.approach(self.y, ty, speed * DTMULT) - self.y
        end

        self:move(dx, dy)

        if facing and (not speed or (dx == 0 and dy == 0)) then
            self:setFacing(facing)
        end

        return dx, dy
    else
        print("targn't "..RUNTIME)
        return 0, 0
    end
end

function Follower:getTargetPosition()
    local follow_delay = FOLLOW_DELAY/2
    local tx, ty, facing, state, args = self.x, self.y, self.facing, nil, {}
    for i,v in ipairs(self.history) do
        tx, ty, facing, state, args = v.x, v.y, v.facing, v.state, v.state_args
        local upper = self.history_time - v.time
        if upper > follow_delay then
            if i > 1 then
                local prev = self.history[i - 1]
                local lower = self.history_time - prev.time

                local t = (follow_delay - lower) / (upper - lower)

                tx = Utils.lerp(prev.x, v.x, t)
                ty = Utils.lerp(prev.y, v.y, t)
            end
            break
        end
    end
    return tx, ty, facing, state, args
end


function Follower:getDesiredMovement(speed)
    return 0,0
end

function Follower:onRemove(parent)
    Utils.removeFromTable(self.world.followers, self)

    Character.onRemove(self, parent)
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
            local button = Game:getPartyMember(self.party).button or "confirm"
            if Input.pressed(button) then
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