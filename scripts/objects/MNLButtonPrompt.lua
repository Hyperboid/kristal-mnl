---@class MNLButtonPrompt: Object
---@field world World
local MNLButtonPrompt, super = Class(Object)

function MNLButtonPrompt:init(x,y)
    super.init(self, x, y)
end

function MNLButtonPrompt:draw()
    super.draw(self)
    if not self.world.player:isMovementEnabled() then return end
    love.graphics.push()
    love.graphics.translate(SCREEN_WIDTH, SCREEN_HEIGHT)
    love.graphics.translate(-10, -10)
    love.graphics.scale(2)
    love.graphics.translate(-70, -70)
    Draw.draw(Assets.getTexture("ui/btn/backplate"),-4,-4)
    for i, chara in ipairs(Utils.mergeMultiple({self.world.player}, self.world.followers)) do
        ---@cast chara Player|Follower
        local x, y, sprite
        if i == 1 then
            x,y = 30, 0
        elseif i == 2 then
            x,y = 0, 30
        end
        if chara.party == "mario" then
            x,y = 30, 0
            sprite = "ui/btn/mario"
        end
        if chara.party == "luigi" then
            x,y = 0, 30
            sprite = "ui/btn/luigi"
        end
        if sprite and x and y then
            local action = chara.desired_action or chara:getDesiredAction()
            Draw.setColor(Game:getPartyMember(chara.party):getColor())
            if action == "none" then
                Draw.draw(Assets.getFramesOrTexture("ui/btn/action/none")[1], x,y)
            else
                Draw.draw(Assets.getFramesOrTexture("ui/btn/action/base")[1], x,y)
                Draw.setColor(COLORS.white)
                Draw.draw(Assets.getFramesOrTexture("ui/btn/action/"..action)[1], x,y)
            end
        end
    end
    love.graphics.pop()
end

return MNLButtonPrompt