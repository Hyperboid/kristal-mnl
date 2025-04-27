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

return World