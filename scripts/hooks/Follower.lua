---@class Follower : Follower
local Follower, super = Class("Follower")

function Follower:update()
    super.update(self)
    self.z = Utils.approach(self.z, self:getGroundLevel(), DTMULT*5)
end

return Follower