if not CLASS_NAME_GETTER("Player").updateAir then
    error{included = "Player"}
end
---@class Follower : Player
local Follower, super = Class({CLASS_NAME_GETTER"Player", Follower})

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
    self.follow_delay = FOLLOW_DELAY
end

function Follower:getFollowDelay()
    local total_delay = 0

    for i,v in ipairs(self.world.followers) do
        total_delay = total_delay + v.follow_delay

        if v == self then break end
    end

    return total_delay
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
        while (self.history_time - self.history[#self.history].time) > (Game.max_followers * self:getFollowDelay()) do
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
        speed = self.walk_speed * 1
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
    local follow_delay = self:getFollowDelay()/2
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
    if self.world.map.side then
        ty = self.y
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

        if not self:isOnFloor() then
            self.state_manager:setState("AIR")
        elseif self.world.player:isMovementEnabled() then
        end
    end
end

return Follower