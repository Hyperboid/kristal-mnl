---@class PartyMember.mario : PartyMember
local chara, super = Class(PartyMember, "mario")

function chara:init()
    super.init(self)
    self.name = "Mario"
    self.title = "Bepis\nThis should never\nshow up!"
    self:setActor("mario")
    self:setLightActor("mario_lw")
    self.button = "confirm"
    self.jump_sound = "m_jump"
    self.color = {1,0,0}
    self.hammer_hits = {4, 2} --Full/Early hammer hits, for breakables & walls
end

return chara
