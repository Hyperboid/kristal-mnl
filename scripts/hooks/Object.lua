---@class Object : Object
---@field stage Stage
local Object, super = Utils.hookScript(Object)

Object.z = 0
function Object:init(...)
    super.init(self,...)
end

function Object:preDraw(...)
    super.preDraw(self, ...)
    -- super.applyTransformTo(self, transform, ...)
    love.graphics.translate(0, -self.z)
end

-- ---@param transform love.Transform
-- function Object:applyTransformTo(transform, floor_x, floor_y, ...)
--     if not self.no_3d then
--         if floor_y then
--             transform:translate(0, Utils.floor(-self.z, floor_y))
--         else
--             transform:translate(0, -self.z)
--         end
--     end
--     super.applyTransformTo(self, transform, floor_x, floor_y, ...)
--     -- super.applyTransformTo(self, transform, ...)
-- end


function Object:getCameraOriginExact()
    local x,y = super.getCameraOriginExact(self)
    y = y - (self.z)
    return x,y
end

function Object:getGroundLevel()
    if not self.stage then return 0 end
    _G.Object.startCache()
    local max_z = -math.huge
    for index, plane in ipairs(self.stage:getObjects(GroundPlane)) do
        ---@cast plane GroundPlane
        if self:collidesWith(plane) then
            max_z = math.max(max_z, plane.target_z)
        end
    end
    _G.Object.endCache()
    if max_z == -math.huge and self.world then
        if self.world.map.data and self.world.map.data.properties and self.world.map.data.properties.floor then
            max_z = self.world.map.data.properties.floor
        end
    end
    return max_z
end

return Object
