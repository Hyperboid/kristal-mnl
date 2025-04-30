---@class MNLBattler: Battler
local MNLBattler, super = Class(Battler)

function MNLBattler:init(x,y, width, height)
    super.init(self, x, y, width, height)
    self.boss = false
end

return MNLBattler