---@class MNLBattle: Object
---@field MNL
local MNLBattle, super = Class(Object)

function MNLBattle:init()
    super.init(self)
    ---@type MNLPartyBattler[]
    self.party = {}
    ---@type MNLEnemyBattler[]
    self.enemies = {}
    self.action_select = MNLBattleActionSelect(self)
    self.state_manager = StateManager("", self, true)
    self.state_manager:addState("INTRO", {update = self.updateIntro})
    self.state_manager:addState("ACTIONSELECT", self.action_select)
    self.music = Music()
    self.timer = self:addChild(Timer())
end

function MNLBattle:isWorldHidden()
    return (not self.intro) or (self.intro.halfdone)
end

function MNLBattle:isHighlighted() return false end

function MNLBattle:onKeyPressed(key, is_repeat)
    if Kristal.Config["debug"] and Input.ctrl() then
        --[[] if key == "h" then
            for _,party in ipairs(self.party) do
                party:heal(math.huge)
            end
        end --]]
        if key == "y" then
            Input.clear(nil, true)
            self:setState("VICTORY")
        end
        if key == "m" then
            if self.music then
                if self.music:isPlaying() then
                    self.music:pause()
                else
                    self.music:resume()
                end
            end
        end
        if self.state == "DEFENDING" and key == "f" then
            self.encounter:onWavesDone()
        end
        if self.soul and self.soul.visible and key == "j" then
            local x, y = self:getSoulLocation()
            self.soul:shatter(6)

            -- Prevents a crash related to not having a soul in some waves
            self:spawnSoul(x, y)
            for _,heartbrust in ipairs(Game.stage:getObjects(HeartBurst)) do
                heartbrust:remove()
            end
            self.soul.visible = false
            self.soul.collidable = false
        end
        --[[ if key == "b" then
            for _,battler in ipairs(self.party) do
                battler:hurt(math.huge)
            end
        end --]]
        if key == "k" then
            Game:setTension(Game:getMaxTension() * 2, true)
        end
        if key == "n" then
            NOCLIP = not NOCLIP
        end
    end
    if (self.state ~= "MENU" and self.state ~= "INTRO" and self.state ~= "TRANSITION") and not is_repeat then
        for _, party in ipairs(self.party) do
            if not party.is_down and Input.is(party.chara.button, key) then
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
    self.update_child_list = true
    super.update(self)
end

function MNLBattle:sortChildren()
    Utils.pushPerformance("MNLBattle#sortChildren")
    Object.startCache()
    local positions = {}
    for _,child in ipairs(self.children) do
        local x, y = child:getSortPosition()
        positions[child] = {x = x, y = y}
    end
    table.stable_sort(self.children, function(a, b)
        local a_pos, b_pos = positions[a], positions[b]
        local ax, ay = a_pos.x, a_pos.y
        local bx, by = b_pos.x, b_pos.y
        if a.layer == b.layer then
            if a:includes(GroundPlane) and b:includes(GroundPlane) then
                return ((b.y-b.target_z)) > ((a.y-a.target_z))
            end
        end
        -- Sort children by Y position, or by follower index if it's a follower/player (so the player is always on top)
        return a.layer < b.layer or
              (a.layer == b.layer and (math.floor(ay) < math.floor(by) or
              (math.floor(ay) == math.floor(by) and (b == self.player or
              (a:includes(Follower) and b:includes(Follower) and b.index < a.index)
            ))))
    end)
    Object.endCache()
    Utils.popPerformance()
end

function MNLBattle:draw()
    if (not self.intro) or (self.intro.halfdone) then
        self.encounter:drawBackground()
    end
    Draw.setColor(COLORS.white)
    self.state_manager:draw()
    super.draw(self)
    Draw.setColor(COLORS.white)
    self.encounter:draw()
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
    ---@type (MNLPartyBattler|MNLEnemyBattler)[]
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
        self:setState("ACTIONSELECT", nil, self.current_battler)
    end
end

function MNLBattle:returnToWorld()
    if not Game:getConfig("keepTensionAfterBattle") then
        Game:setTension(0)
    end
    self.encounter:setFlag("done", true)
    self:remove()
    self.music:remove()
    if self.resume_world_music then
        Game.world.music:resume()
    end
    Game.battle = nil
    Game.state = "OVERWORLD"
end

return MNLBattle