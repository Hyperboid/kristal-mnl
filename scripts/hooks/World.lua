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
    for _, plane in ipairs(self.stage:getObjects(GroundPlane)) do
        ---@cast plane GroundPlane
        if plane:collidesWith(collider) and plane.target_z > (collider.parent.z) then
            Object.endCache()
            return true
        end
    end
    Object.endCache()
    return false
end

return World