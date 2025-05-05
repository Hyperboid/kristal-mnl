---@class MNLWave.basic : MNLWave
local wave, super = Class(MNLWave, "basic")

function wave:init()
    super.init(self)
end

function wave:run(await, resume)
    local ox, oy = self.parent:getPosition()
    local target = Utils.pick(self.battle.party)
    await(self.timer:tween(1,self.parent, {x = target.x, y = target.y}))
    await(self.timer:tween(1,self.parent, {x = ox, y = oy}))
end

return wave