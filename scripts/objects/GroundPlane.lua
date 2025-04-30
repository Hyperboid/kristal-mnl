---@class GroundPlane: Object
local GroundPlane, super = Class(Object)

function GroundPlane:init(x,y,w,h,z)
    super.init(self, x,y,w,h)
    self:setHitbox(0,0,w,h)
    self.collider.thickness = math.huge
    self.target_z = z
end

function GroundPlane:postLoad()
    self.z=0
end

function GroundPlane:draw()
    super.draw(self)
    if DEBUG_RENDER then
        self:drawSide()
        self:drawTop()
    end
end

function GroundPlane:drawTop()
    love.graphics.setLineWidth(4)
    local w,h = self:getSize()
    local x,y = 4,4
    Draw.setColor(COLORS.green)
    love.graphics.rectangle("fill", 0,0-(self.target_z*2), w,h)
    Draw.setColor(COLORS.white)
    love.graphics.rectangle("line", x,y-(self.target_z*2), w-x-x,h-y-y)
end

function GroundPlane:drawSide()
    love.graphics.setLineWidth(4)
    local w,h = self:getSize()
    local x,y = 4,4
    x = x + love.math.random(-2,2)
    y = y + love.math.random(-2,2)
    Draw.setColor(COLORS.yellow)
    local top = -(math.abs(self.target_z*2) + self.target_z*2) / 2
    love.graphics.rectangle("fill", 0,top,w,h-top)
    love.graphics.rectangle("line", x,y+top,w-x-x,h-y-y)
end

function GroundPlane:drawMask(object)
    local d = ((object.y) - (self.y))
    if d > 0 then return end
    local w,h = self:getSize()
    local top = -(math.abs(self.target_z*2) + self.target_z*2) / 2
    love.graphics.rectangle("fill", 0,top,w,h-top)
end

---@param object Object
function GroundPlane:getHeightFor(object)
    return self.target_z
end

return GroundPlane