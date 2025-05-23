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
    self.color = {0,1,0}
    self.hammer_hits = {4, 2} --Full/Early hammer hits, for breakables & walls
end

return chara
