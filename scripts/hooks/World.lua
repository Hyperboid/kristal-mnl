---@class World : World
local World, super = Class("World")
---@cast super World

function World:checkCollision(collider, ...)
    Object.startCache()
    if super.checkCollision(self, collider, ...) then
        Object.endCache()
        return true
    end
    if not self.stage then
        Object.endCache()
        return false
    end
    local floor_found = false
    if self.map.data and self.map.data.properties and self.map.data.properties.floor then
        floor_found = true
    end
    for _, plane in ipairs(self.stage:getObjects(GroundPlane)) do
        ---@cast plane GroundPlane
        if plane:collidesWith(collider) then
            floor_found = true
            if plane.target_z > (collider.parent.z) then
                Object.endCache()
                return true
            end
        end
    end
    Object.endCache()
    return not floor_found
end

function World:sortChildren()
    Utils.pushPerformance("mnl/World#sortChildren")
    Object.startCache()
    local positions = {}
    for _,child in ipairs(self.children) do
        local x, y = child:getSortPosition()
        positions[child] = {x = x, y = y}
    end
    table.stable_sort(self.children, function(a, b)
        local a_pos, b_pos = positions[a], positions[b]
        local ax, ay = a_pos.x, a_pos.y
        local bx, by = b_pos.x, b_pos.y
        if a.layer == b.layer then
            if a:includes(GroundPlane) and b:includes(GroundPlane) then
                return ((b.y-b.target_z)) > ((a.y-a.target_z))
            end
        end
        -- Sort children by Y position, or by follower index if it's a follower/player (so the player is always on top)
        return a.layer < b.layer or
              (a.layer == b.layer and (math.floor(ay) < math.floor(by) or
              (math.floor(ay) == math.floor(by) and (b == self.player or
              (a:includes(Follower) and b:includes(Follower) and b.index < a.index)
            ))))
    end)
    Object.endCache()
    Utils.popPerformance()
end

function World:openMenu(menu, layer)
    if self.player and self.player.state_manager.state ~= "WALK" then return end
    return super.openMenu(self,menu,layer)
end

function World:spawnFollower(chara, options)
    local f = super.spawnFollower(self, chara, options)
    local dx, dy = Utils.getFacingVector(f.facing)
    local dist = (((self.player.walk_speed * 15) * FOLLOW_DELAY))
    f.x = f.x - (dx*dist)
    f.y = f.y - (dy*dist)
    f:interpolateHistory()
    return f
end

return World