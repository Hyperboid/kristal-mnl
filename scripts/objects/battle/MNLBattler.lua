---@class MNLBattler: Battler
local MNLBattler, super = Class(Battler)

function MNLBattler:init(x,y, width, height)
    super.init(self, x, y, width, height)
    self.boss = false
end

function MNLBattler:onAdd(parent)
    super.onAdd(self, parent)
    if parent:includes(MNLBattle) then
        ---@cast parent MNLBattle
        self.battle = parent
    end
end

function MNLBattler:walkToSpeed(x,y,speed,after)
    return self:slideToSpeed(x,y,speed,after)
end

function MNLBattler:getSpeed()
    Kristal.Console:warn(debug.traceback"Expected getSpeed method to be overwritten! Returning 0...")
    return 0
end

function MNLBattler:setActor(actor, use_overlay)
    super.setActor(self, actor, use_overlay)
    self:setHitbox(self.actor:getHitbox())
    self.collider.thickness = self.actor.hitbox_thickness or self.collider.thickness
end

function MNLBattler:draw()
    super.draw(self)
    if DEBUG_RENDER and self.collider then
        self.collider:drawFor(self, COLORS.lime)
    end
end

return MNLBattler