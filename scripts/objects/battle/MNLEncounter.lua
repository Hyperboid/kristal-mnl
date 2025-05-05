---@class MNLEncounter: Class
---@field intro_type MNLEncounter.__intro_type
local MNLEncounter, super = Class()

---@alias MNLEncounter.__intro_type "normal"|"event"|"miniboss"

function MNLEncounter:init()
    super.init(self)
    self.intro_type = "normal"
    self.music = "battle_mnl"
end

-- Callbacks

--- *(Override)* Called in [`Battle:postInit()`](lua://Battle.postInit). \
--- *If this function returns `true`, then the battle will not override any state changes made here.*
---@return boolean?
function MNLEncounter:onBattleInit() end
--- *(Override)* Called when the battle enters the `"INTRO"` state and the characters do their starting animations.
function MNLEncounter:onBattleStart() end
--- *(Override)* Called when the battle is completed and the victory text (if presesnt) is advanced, just before the transition out.
function MNLEncounter:onBattleEnd() end

--- *(Override)* Called at the start of each new turn, just before the player starts choosing an action, or an enemy starts attacking.
---@param prev_battler MNLPartyBattler|MNLEnemyBattler
---@param battler MNLPartyBattler|MNLEnemyBattler
function MNLEncounter:onTurnStart(prev_battler, battler) end
--- *(Override)* Called at the end of each turn, at the same time all waves end.
function MNLEncounter:onTurnEnd() end

--- *(Override)* Called when the party start performing their actions.
function MNLEncounter:onActionsStart() end
--- *(Override)* Called when the party finish performing their actions.
function MNLEncounter:onActionsEnd() end

--- *(Override)* Called when [`Battle:setState()`](lua://Battle.setState) is called. \
--- *Changing the state to something other than `new`, or returning `true` will stop the standard state change code for this state change from occurring.*
---@param old string
---@param new string
---@return boolean?
function MNLEncounter:beforeStateChange(old, new) end
--- *(Override)* Called when [`Battle:setState()`](lua://Battle.setState) is called, after any state change code has run.
---@param old string
---@param new string
function MNLEncounter:onStateChange(old, new) end

--- *(Override)* Called when an [`MNLActionBlock`](lua://MNLActionBlock.init) is selected.
---@param battler   PartyBattler
---@param button    MNLActionBlock
function MNLEncounter:onActionSelect(battler, button) end


--- Adds an enemy to the encounter.
---@param enemy string|EnemyBattler The id of an `EnemyBattler`, or an `EnemyBattler` instance.
---@param x? number
---@param y? number
---@param ... any   Additional arguments to pass to [`EnemyBattler:init()`](lua://EnemyBattler.init).
---@return EnemyBattler
function MNLEncounter:addEnemy(enemy, x, y, ...)
    local enemy_obj
    if type(enemy) == "string" then
        enemy_obj = MNL:createEnemy(enemy, ...)
    else
        enemy_obj = enemy
    end
    local enemies = self.queued_enemy_spawns
    local enemies_index
    local transition = false
    if Game.battle and Game.state == "BATTLE" then
        enemies = Game.battle.enemies
        enemies_index = Game.battle.enemies_index
        transition = Game.battle.state == "TRANSITION"
    end
    x, y = x or (550 + (10 * #enemies)), y or (200 + (45 * #enemies))
    if transition then
        enemy_obj:setPosition(x + 200, y)
    end
    enemy_obj.target_x = x
    enemy_obj.target_y = y
    if not transition then
        enemy_obj:setPosition(x, y)
    end
    enemy_obj.encounter = self
    enemy_obj:postInit()
    table.insert(enemies, enemy_obj)
    if enemies_index then
        table.insert(enemies_index, enemy_obj)
    end
    if Game.battle and Game.state == "BATTLE" then
        Game.battle:addChild(enemy_obj)
    end
    return enemy_obj
end

function MNLEncounter:update() end

function MNLEncounter:getPartyPosition(index)
    local x, y = 0, 0
    if #Game.battle.party == 1 then
        x = 80
        y = 140
    elseif #Game.battle.party == 2 then
        x = 80
        y = 100 + (160 * (index - 1))
    elseif #Game.battle.party == 3 then
        x = 80
        y = 50 + (160 * (index - 1))
    end

    local battler = Game.battle.party[index]
    local ox, oy = battler.chara:getBattleOffset()
    x = x + (battler.actor:getWidth()/2 + ox) * 2
    y = y + (battler.actor:getHeight()  + oy) * 2
    return x, y
    -- return 50, 50
end

function MNLEncounter:drawBackground() end
function MNLEncounter:draw()
end

function MNLEncounter:setFlag(flag, value)
    
end

return MNLEncounter
