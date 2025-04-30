---@class MNLBattler: Battler
local MNLBattler, super = Class(Battler)

function MNLBattler:init(x,y, width, height)
    super.init(self, x, y, width, height)
end

return MNLBattler