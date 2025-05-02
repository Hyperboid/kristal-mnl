---@class MNLBattleEnemySelect: StateClass
local MNLBattleEnemySelect, super = Class(StateClass)

---@param battle MNLBattle
function MNLBattleEnemySelect:init(battle)
    self.battle = battle
end

function MNLBattleEnemySelect:registerEvents()
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("leave", self.onLeave)
    self:registerEvent("keypressed", self.onKeyPressed)
    self:registerEvent("update", self.update)
    self:registerEvent("draw", self.draw)
end

function MNLBattleEnemySelect:onEnter()
    self.battle:onConfirmEnemy(self.battle.enemies[1])
end

return MNLBattleEnemySelect