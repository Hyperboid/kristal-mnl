---@class PartyMember.mario : PartyMember
local chara, super = Class(PartyMember, "mario")

function chara:init()
    super.init(self)
    self.name = "Mario"
    self.title = "Bepis\nThis should never\nshow up!"
    self:setActor("mario")
    self:setLightActor("mario_lw")
    self.button = "confirm"
end

return chara