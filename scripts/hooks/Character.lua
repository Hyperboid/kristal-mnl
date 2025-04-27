---@class Character : Character
local Character, super = Utils.hookScript(Character)

function Character:init(...)
    super.init(self, ...)
    self.draw_shadow = true
end

function Character:draw()
    if self.draw_shadow then
        Draw.setColor(COLORS.black(.2))
        love.graphics.ellipse("fill", (self.width/2),self.z + (self.height) - self:getGroundLevel(), 8,4)
    end
    super.draw(self)
end

return Character