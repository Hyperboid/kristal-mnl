---@class PartyMember.luigi : PartyMember
local chara, super = Class(PartyMember, "luigi")

function chara:init()
    super.init(self)
    self.name = "Luigi"
    self.title = "Bepis\nThis should never\nshow up!"
    self:setActor("luigi_lw")
    self:setLightActor("luigi_lw")
    self.button = "cancel"
    self.jump_sound = "l_jump"
end

return chara