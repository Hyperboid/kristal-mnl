---@class MNLBattle: Object
---@field MNL
local MNLBattle, super = Class(Object)

function MNLBattle:init()
    super.init(self)
    self.party = {}
    self.enemies = {}
    self.state_manager = StateManager("", self, true)
end

function MNLBattle:isWorldHidden()
    return (not self.intro) or (self.intro.halfdone)
end

function MNLBattle:isHighlighted() return false end

function MNLBattle:onKeyPressed(key, is_repeat)
    if self.state ~= "MENU" then
        for _, party in ipairs(self.party) do
            if Input.is(party.party.button, key) then
                party:onButtonPressed()
                break
            end
        end
    end
end

function MNLBattle:postInit(state, encounter)
    self.state = state
    if not isClass(encounter) then
        encounter = Registry.createEncounter(encounter)
    end
    ---@cast encounter MNLEncounter
    self.encounter = encounter
    if state == "TRANSITION" then
        self.intro = self:addChild(MNLBattleIntro(self.encounter.intro_type))
    else
        self:setState(state)
    end
end

--- Changes the state of the battle and calls [onStateChange()](lua://Battle.onStateChange)
---@param state     string
---@param reason    string?
function MNLBattle:setState(state, reason, ...)
    self.state_reason = reason
    self.state_manager:setState(state, ...)
end

function MNLBattle:onStateChange(old, new)
end

return MNLBattle