---@class MNLBattler: Battler
local MNLBattler, super = Class(Battler)

function MNLBattler:init(x,y, width, height)
    super.init(self, x, y, width, height)
    self.boss = false
end

function MNLBattler:walkToSpeed(x,y,speed,after)
    return self:slideToSpeed(x,y,speed,after)
end

function MNLBattler:getSpeed()
    Kristal.Console:warn(debug.traceback"Expected getSpeed method to be overwritten! Returning 0...")
    return 0
end

return MNLBattler