---@class MNLBattleIntro: Object
---@field intro_type MNLEncounter.__intro_type
local MNLBattleIntro, super = Class(Object)

function MNLBattleIntro:init(intro_type, mid_callback)
    super.init(self)
    self.intro_type = intro_type
    self.mid_callback = mid_callback
    self.anim_timer = 0
end

function MNLBattleIntro:update()
    self.anim_timer = self.anim_timer + (DT*4)
    if self.anim_timer >= 1 and not self.halfdone and self.mid_callback then
        self.mid_callback()
    end
    self.halfdone = self.anim_timer >= 1
end

function MNLBattleIntro:draw()
    if self.anim_timer < 1 then
        love.graphics.rectangle("fill", 0,0,SCREEN_WIDTH * self.anim_timer, SCREEN_HEIGHT)
    else
        love.graphics.rectangle("fill", SCREEN_WIDTH * math.max(0,self.anim_timer-4),0,SCREEN_WIDTH, SCREEN_HEIGHT)
    end
end


return MNLBattleIntro