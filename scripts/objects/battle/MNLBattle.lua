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
    self.enemy_select = MNLBattleEnemySelect(self)
    self.state_manager = StateManager("", self, true)
    self.state_manager:addState("INTRO", {update = self.updateIntro})
    self.state_manager:addState("ACTIONS", {enter = self.beginActions})
    self.state_manager:addState("ACTIONSELECT", self.action_select)
    self.state_manager:addState("ENEMYSELECT", self.enemy_select)
    self.music = Music()
    self.timer = self:addChild(Timer())
    self.last_button_pressed = {}
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
    if self.state_manager:call("keypressed", key, is_repeat) then return end
    if (self.state ~= "MENU" and self.state ~= "INTRO" and self.state ~= "TRANSITION") and not is_repeat then
        for _, party in ipairs(self.party) do
            if not party.is_down and Input.is(party.chara.button, key) then
                party:onButtonPressed()
                self.last_button_pressed[party] = RUNTIME
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

    for index, party in ipairs(Game.party) do
        local battler = MNLPartyBattler(party)
        self:addChild(battler)
        
        table.insert(self.party,battler)
        self.last_button_pressed[battler] = 0
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
        return a:getSpeed() > b:getSpeed()
    end)
    if self.current_battler then
        return battlers[(Utils.getIndex(battlers, self.current_battler)%#battlers)+1]
    end
    return battlers[1]
end

function MNLBattle:startNextTurn()
    if self.current_battler then
        if self.current_battler.target_x and self.current_battler.target_y then
            self.current_battler:setPosition(self.current_battler.target_x, self.current_battler.target_y)
        end
        self.current_battler:resetPhysics()
        if self.current_battler:includes(MNLPartyBattler) then
            self.current_battler:setState("STANDING")
        end
    end
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

function MNLBattle:runCoroutine(f, ...)
    local resumed_running = false
    local thread = coroutine.create(f)
    local resume = function (...)
        if coroutine.status(thread) == "dead" then return end
        if coroutine.status(thread) == "running" then
            resumed_running = true
            return
        end
        local ok, msg = coroutine.resume(thread, ...)
        if not ok then
            COROUTINE_TRACEBACK = debug.traceback(thread)
            error(msg)
        end
    end
    local function await(handle, ...)
        if resumed_running then
            resumed_running = false
            return
        end
        if type(handle) == "table" and handle.after ~= resume then
            handle.after = Utils.override(handle.after, function (orig, ...)
                resume()
                orig(...)
            end)
        end
        return coroutine.yield(handle, ...)
    end
    resume(self, await, resume, ...)
    return thread, await, resume
end

function MNLBattle:onConfirmEnemy(target)
    self:setState("ACTIONS", nil, self.state_reason, self.current_battler, target)
end

function MNLBattle:beginActions(prev, action_type, user, target)
    if action_type == "JUMP" then
        self:runCoroutine(self.handleJumpAttack, self.current_battler, target)
    end
end

---@async
---@param await async fun(...)
---@param resume fun()
---@param party MNLPartyBattler
---@param enemy MNLEnemyBattler
function MNLBattle:handleJumpAttack(await, resume, party, enemy)
    await(self.timer:afterCond(function ()
        return party.state == "STANDING"
    end, resume))
    party:setState("ACTIONS")
    local x,y = enemy:getAttackerPosition()
    await(party:walkToSpeed(x, y, 10, resume))
    await(party:setAnimation("battle/jump_ready", resume))
    local t = 0.3
    self.timer:tween(t*1.9, party, {x = enemy.x})
    for i = 1, 2 do
        
        await(self.timer:tween(t, party, {
            z = (enemy.collider.thickness*2) + 50,
        }, "out-quad"))
        await(self.timer:tween(t, party, {
            z = (enemy.collider.thickness*2),
        }, "in-quad"))
        if (RUNTIME - self.last_button_pressed[party] ) < 0.3 then
            enemy:explode(nil, nil, true)
        else

            break
        end
    end
    await(self.timer:after(0))
    local htween = self.timer:tween(t*1.9, party, {x = party.target_x, y = party.target_y})
    await(self.timer:after(0))

    await(self.timer:tween(t, party, {
        z = (enemy.collider.thickness*2) + 50,
    }, "out-quad"))
    await(self.timer:tween(t, party, {
        z = 0,
    }, "in-quad"))
    self.timer:cancel(htween)
    await(self.timer:after(0))
    self:startNextTurn()
end

return MNLBattle