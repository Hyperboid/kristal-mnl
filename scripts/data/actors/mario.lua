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
    self.hitbox_thickness = 14
    self.color = {1, 0, 0}
    self.offsets = {
        ["hammer"] = {-25, -25}
    }
    self.animations = {
        ["hammer"] = {"hammer", 1/30, false, next="hammer_done"},
        ---@param spr Sprite
        ["hammer_done"] = {"hammer", function (spr, wait)
            spr:setFrame(#spr.frames)
        end}
    }
end

return actor