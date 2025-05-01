---@class Actor.luigi : Actor
local actor, super = Class(Actor, "luigi")

function actor:init()
    super.init(self)
    self.name = "Luigi"
    self.path = "party/luigi/dark"
    self.default = "walk"
    self.width = 22
    self.height = 44
    self.hitbox = {3,39,16,5}
    self.hitbox_thickness = 21
    self.color = {1, 0, 0}
end

return actor