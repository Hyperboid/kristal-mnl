---@class MNLWave.loop : MNLWave
local wave, super = Class(MNLWave, "loop")

function wave:init()
    super.init(self)
end

function wave:run(await, resume)
    local ox, oy = self.parent:getPosition()
    for i = 1, 10 do
        local target = Utils.pick(self.battle.party)
        await(self.timer:tween(.5,self.parent, {x = target.x+(target.width/2), y = target.y+2}))
        await(self.timer:tween(.1,self.parent, {x = target.x+(target.width*4), y = target.y+2}))
        await(self.timer:tween(.5,self.parent, {x = ox, y = oy}))
    end
end

return wave