---@class Event.savepoint : Event.qblock
local event, super = Class("qblock", "savepoint")

function event:init(data)
    super.init(self, data)
    self.sprite.path = "world/events/saveblock"
    self.reusable = true
end

function event:doItem()
    Game.world:openMenu(SaveMenu())
end

return event