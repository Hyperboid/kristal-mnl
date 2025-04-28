---@class PartyMember : PartyMember
local PartyMember, super = Class("PartyMember")

function PartyMember:init()
    super.init(self)
    self.button = "cancel"
end

return PartyMember