---@class Actor.luigi_lw : Actor.luigi
local actor, super = Class("luigi", "luigi_lw")

function actor:init()
    super.init(self)
    self.path = "party/luigi/light"
end

return actor