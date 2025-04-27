---@class Follower : Follower
local Follower, super = Class("Follower")

function Follower:init(...)
    super.init(self,...)
    self:addFX(GroundMaskFX())
end

function Follower:update()
    super.update(self)
    self.z = Utils.approach(self.z, self:getGroundLevel(), DTMULT*5)
end

return Follower