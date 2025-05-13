---@class MNLBattleVictory: StateClass
local MNLBattleVictory, super = Class(StateClass)

---@param battle MNLBattle
function MNLBattleVictory:init(battle)
    self.battle = battle
end

function MNLBattleVictory:registerEvents()
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("leave", self.onLeave)
    self:registerEvent("keypressed", self.onKeyPressed)
    self:registerEvent("update", self.update)
    self:registerEvent("draw", self.draw)
end

function MNLBattleVictory:onEnter()
    self.timer = 0
    self.battle.music:stop()
end

function MNLBattleVictory:update()
    self.timer = self.timer + DTMULT
    if self.timer >= 20 then
        self.timer = -math.huge
        self.battle:returnToWorld()
    end
end

return MNLBattleVictory