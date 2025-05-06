local Dummy, super = Class(MNLEncounter)

function Dummy:init()
    super.init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The tutorial begins...?"

    -- Battle music ("battle_mnl" is Wondrous Encounter)
    self.music = "battle_mnl"
    -- Enables the purple grid battle background
    self.background = true

    self:addEnemy("dummy", 510, 240)
end

function Dummy:drawBackground()
    Draw.setColor(COLORS.white(0.1))
    for i=0.1,1.2,0.1 do
        love.graphics.ellipse("fill", SCREEN_WIDTH/2, SCREEN_HEIGHT/2, SCREEN_WIDTH*i, SCREEN_HEIGHT*i/2)
    end
end

return Dummy