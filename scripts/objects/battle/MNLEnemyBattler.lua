---@class MNLEnemyBattler: MNLBattler
local MNLEnemyBattler, super = Class("MNLBattler")
---@cast super MNLBattler

function MNLEnemyBattler:init(actor, use_overlay)
    super.init(self)
    self.name = "Test Enemy"

    if actor then
        self:setActor(actor, use_overlay)
    end

end

return MNLEnemyBattler