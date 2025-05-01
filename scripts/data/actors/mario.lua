---@class Actor.mario : Actor
local actor, super = Class(Actor, "mario")

function actor:init()
    super.init(self)
    self.name = "Mario"
    self.path = "party/mario/dark"
    self.default = "walk"
    self.width = 22
    self.height = 42
    self.hitbox = {3,37,16,5}
    self.hitbox_thickness = 21
    self.color = {1, 0, 0}
end

return actor