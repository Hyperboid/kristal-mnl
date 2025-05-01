---@class MNLPartyBattler: MNLBattler
local MNLPartyBattler, super = Class("MNLBattler")

---@param chara     PartyMember
---@param x?        number
---@param y?        number
function MNLPartyBattler:init(chara, x, y)
    self.chara = chara
    self.actor = chara:getActor()

    super.init(self, x, y, self.actor:getSize())
    self:setActor(self.actor, true)
    self:setAnimation("battle/idle")
end

function MNLPartyBattler:onButtonPressed()
    print("Pushed button "..self.chara.id..".")
end

function MNLPartyBattler:getSpeed()
    return self.chara:getStat("speed")
end

return MNLPartyBattler