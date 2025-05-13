---@class Event.savepoint : Event.qblock
local event, super = Class("qblock", "savepoint")

function event:init(data)
    super.init(self, data)
    self.sprite.path = "world/events/saveblock"
    self.reusable = true
    local properties = data and data.properties or {}

    self.marker = properties["marker"]
    self.simple_menu = properties["simple"]
    self.text_once = properties["text_once"]
    self.heals = properties["heals"] ~= false
end

function event:doItem()
    Game.world:openMenu(SaveMenu(self.marker))
end

return event