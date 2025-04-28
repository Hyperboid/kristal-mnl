---@class Actor.mario_lw : Actor
local actor, super = Class("mario", "mario_lw")

function actor:init()
    super.init(self)
    self.path = "party/mario/light"
end

return actor