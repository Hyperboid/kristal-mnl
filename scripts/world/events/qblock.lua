---@class Event.qblock : Event
local event, super = Class(Event, "qblock")

---@param data table
function event:init(data)
    super.init(self,data)
    local properties = data.properties or {}
    self.sprite = Sprite("world/events/qblock/default")
    self:addChild(self.sprite)
    self.sprite:setScale(2)
    self.solid = true
    self:move(0,10)
    self.sprite:move(0,10)
    local h = self.height/2
    self.ground_collider = Hitbox(self, 0,h,self.width,h)
    self.ground_collider.thickness = 30
    self:setHitbox(0,h,self.width,h)
    self.collider.thickness = 1
    self.collider.z = -2
    self:setOrigin(0,1)
end

function event:getDebugRectangle()
    return {0, self.height/4, self.width, self.height*1.5}
end

function event:drawShadow()
    Draw.setColor(COLORS.black(.2))
    love.graphics.ellipse("fill", (self.width/2), self.height + self:getGroundLevel() * -2, 16,8)
end

function event:getHeightFor(object)
    if object.z < (self.z-20) then
        return -math.huge
    end
    return (self.z + 10)
end

return event