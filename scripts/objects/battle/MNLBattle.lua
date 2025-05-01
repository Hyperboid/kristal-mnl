---@class MNLBattle: Object
---@field MNL
local MNLBattle, super = Class(Object)

function MNLBattle:init()
    super.init(self)
    self.party = {}
    self.enemies = {}
    self.state_manager = StateManager("", self, true)
    self.state_manager:addState("INTRO", {update = self.updateIntro})
    self.music = Music()
end

function MNLBattle:isWorldHidden()
    return (not self.intro) or (self.intro.halfdone)
end

function MNLBattle:isHighlighted() return false end

function MNLBattle:onKeyPressed(key, is_repeat)
    if (self.state ~= "MENU" and self.state ~= "INTRO" and self.state ~= "TRANSITION") and not is_repeat then
        for _, party in ipairs(self.party) do
            if Input.is(party.chara.button, key) then
                party:onButtonPressed()
                break
            end
        end
    end
    self.state_manager:call("keypressed", key, is_repeat)
end

function MNLBattle:postInit(state, encounter)
    self.state = state
    if not isClass(encounter) then
        encounter = Registry.createEncounter(encounter)
    end
    ---@cast encounter MNLEncounter
    self.encounter = encounter

    for index, party in ipairs(Game.party) do
        local battler = MNLPartyBattler(party)
        self:addChild(battler)
        
        table.insert(self.party,battler)
        battler.x, battler.y = self.encounter:getPartyPosition(index)
        battler.target_x, battler.target_y = battler.x, battler.y
        if state == "TRANSITION" then
            battler.x = battler.x - 200
        end
    end

    if Game.world.music:isPlaying() and self.encounter.music then
        self.resume_world_music = true
        Game.world.music:pause()
    end
    if state == "TRANSITION" then
        self.intro = self:addChild(MNLBattleIntro(self.encounter.intro_type, function ()
            -- TODO: make cool background appear here
        end, function ()
            self:setState("INTRO")
        end))
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
    if new == "INTRO" then
        if self.encounter.music then
            self.music:play(self.encounter.music)
        end
        for _, battler in ipairs(Utils.mergeMultiple(self.party, self.enemies)) do
            ---@cast battler MNLBattler
            battler:walkToSpeed(battler.target_x, battler.target_y, 8)
        end
    end
end

function MNLBattle:update()
    self.state_manager:update()
    super.update(self)
end

function MNLBattle:draw()
    self.state_manager:draw()
    super.draw(self)
end

function MNLBattle:updateIntro()
    for  _, battler in ipairs(Utils.mergeMultiple(self.party, self.enemies)) do
        ---@cast battler MNLBattler
        if battler.physics.move_target then
            return
        end
    end
    self:startNextTurn()
end

---@return MNLPartyBattler|MNLEnemyBattler
function MNLBattle:getNextBattler()
    ---@type MNLBattler[]
    local battlers = Utils.mergeMultiple(self.party, self.enemies)
    table.sort(battlers, function (a, b)
        return a:getSpeed() < b:getSpeed()
    end)
    print(Utils.dump(battlers))
    if self.current_battler then
        return battlers[(Utils.getIndex(battlers, self.current_battler)%#battlers)+1]
    end
    return battlers[1]
end

function MNLBattle:startNextTurn()
    self.current_battler = self:getNextBattler()

    if self.current_battler:includes(MNLEnemyBattler) then
        self:setState("ENEMYACTION")
    else
        self:setState("ACTIONSELECT")
    end
end

function MNLBattle:returnToWorld()
    if not Game:getConfig("keepTensionAfterBattle") then
        Game:setTension(0)
    end
    self.encounter:setFlag("done", true)
    self:remove()
    Game.battle = nil
    Game.state = "OVERWORLD"
end

return MNLBattle