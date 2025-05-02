---@class MNLActionBlock: Object
---@overload fun(...) : MNLActionBlock
local MNLActionBlock, super = Class(Object)

function MNLActionBlock:init(type, battler, x,y)
    super.init(self, x, y, 20, 20)
    self.type = type
    self.battler = battler
    self.sprite = Sprite("ui/battle/blocks/"..type, 0, -10)
    self:setScale(2)
    self:addChild(self.sprite)
end

function MNLActionBlock:onAdd(parent)
    super.onAdd(self, parent)
    if parent:includes(MNLBattle) then
        ---@cast parent MNLBattle
        self.battle = parent
    end
end

function MNLActionBlock:select()
    if Game.battle.encounter:onActionSelect(self.battler, self) then return end
    if Kristal.callEvent(KRISTAL_EVENT.onMNLActionSelect, self.battler, self) then return end
    if self.type == "jump" then
        self.battle:setState("ENEMYSELECT", "JUMP")
    end
end

return MNLActionBlock