---@class Object : Object
---@field stage Stage
local Object, super = Utils.hookScript(Object)

Object.z = 0
function Object:init(...)
    super.init(self,...)
end

function Object:preDraw(dont_transform, ...)
    if self.drawShadow then
        love.graphics.push()
        super.preDraw(self, dont_transform, ...)
        self:drawShadow()
        Draw.setColor(self:getDrawColor())
        love.graphics.pop()
    end
    if not dont_transform then
        love.graphics.translate(0, -self.z*2)
    end
    super.preDraw(self, dont_transform, ...)
    -- super.applyTransformTo(self, transform, ...)
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
    local ground_obj
    for index, plane in ipairs(self.stage:getObjects()) do
        ---@cast plane GroundPlane
        if plane ~= self and plane.getHeightFor and self:collidesWith(plane.ground_collider or plane) then
            local plane_height = plane:getHeightFor(self)
            if plane_height >= max_z then
                max_z = plane_height
                ground_obj = plane
            end
        end
    end
    _G.Object.endCache()
    if max_z == -math.huge then
        if self.world and self.world.map.data and self.world.map.data.properties and self.world.map.data.properties.floor then
            max_z = self.world.map.data.properties.floor
        else
            max_z = self.z
        end
    end
    return max_z, ground_obj
end

function Object:getScreenPos()
    local x,y = super.getScreenPos(self)
    y = y - (self.z * self.scale_y)
    return x,y
end

function Object:setScreenPos(x,y)
    super.setScreenPos(self, x, y + (self.z * self.scale_y))
end

function Object:moveZ(z, speed)
    self.z = self.z + (z or 0) * (speed or 1)
end

function Object:explode(x, y, dont_remove, options)
    local explosion = super.explode(self, x, y, dont_remove, options)
    explosion.z = self.z
    return explosion
end

return Object
