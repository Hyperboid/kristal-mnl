---@class PartyMember : PartyMember
local PartyMember, super = Class("PartyMember")

function PartyMember:init()
    super.init(self)
    self.button = "cancel"
    self.jump_sound = "jump"
end

return PartyMember