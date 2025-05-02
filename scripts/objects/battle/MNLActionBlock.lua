---@class MNLActionBlock: Object
---@overload fun(...) : MNLActionBlock
local MNLActionBlock, super = Class(Object)

function MNLActionBlock:init(type, battler, x,y)
    super.init(self, x, y, 20, 20)
    self.sprite = Sprite("ui/battle/blocks/"..type, 0, -10)
    self:setScale(2)
    self:addChild(self.sprite)
end

return MNLActionBlock