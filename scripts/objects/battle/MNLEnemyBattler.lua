---@class MNLEnemyBattler: MNLBattler
local MNLEnemyBattler, super = Class("MNLBattler")
---@cast super MNLBattler

function MNLEnemyBattler:init(actor, use_overlay)
    super.init(self)
    self.name = "Test Enemy"

    if actor then
        self:setActor(actor, use_overlay)
    end
    self.speed = 0
    self.attack = 1
    self.level = 1
    self.defense = 3
    self.max_health = 60
    self.extra_stats = {}
    self.waves = {}
end

function MNLEnemyBattler:postInit()
    self.health = self.health or self.max_health
end

function MNLEnemyBattler:getSpeed()
    return self.speed
end

function MNLEnemyBattler:getAttackerPosition()
    return self.x-100, self.y
end

--- An override of [`Battler:statusMessage()`](lua://Battler.statusMessage) that positions the message for this EnemyBattler
---@param type?     string  The type of message to display:
---|"mercy"     # Indicates that the message will be a mercy number
---|"damage"    # Indicates that the message will be a damage number
---|"msg"       # Indicates that the message will use a unique sprite, such as MISS or DOWN text
---@param arg?      any     An additional argument which depends on what `type` is set to:
---|"mercy"     # The amount of mercy added
---|"damage"    # The amount of damage dealt
---|"msg"       # The path to the sprite, relative to `ui/battle/message`, to use
---@param color?    table   The color used to draw the status message, defaulting to white
---@param kill?     boolean Whether this status should cause all other statuses to disappear.
---@return DamageNumber
function MNLEnemyBattler:statusMessage(type, arg, color, kill)
    return super.statusMessage(self, self.width/2, self.height/2, type, arg, color, kill)
end

---@param damage number
---@param battler MNLPartyBattler
function MNLEnemyBattler:getAttackDamage(damage, battler)
    return MNL:getAttackDamage(battler, self, damage)
end

function MNLEnemyBattler:getStat(name, default)
    if name == "speed" then
        return self.speed
    elseif name == "health" then
        return self.max_health
    elseif name == "attack" then
        return self.attack
    elseif name == "defense" then
        return self.defense
    elseif name == "level" then
        return self.level
    elseif self.extra_stats[name] then
        return self.extra_stats[name]
    else
        return default
    end
end

function MNLEnemyBattler:update()
    if self.wave then
        self.wave:update()
    end
    super.update(self)
end

---@param wave MNLWave
function MNLEnemyBattler:setWave(wave)
    if type(wave) == "string" then
        wave = MNL:createWave(wave)
    end
    self.wave = wave
    self.wave:setParent(self)
    self.wave:onStart()
end

function MNLEnemyBattler:selectWave()
    
    self:setWave((Utils.pick(self:getNextWaves())) or MNLWave())
end

function MNLEnemyBattler:getNextWaves()
    if self.wave_override then
        local wave = self.wave_override
        self.wave_override = nil
        return {wave}
    end
    return self.waves
end

function MNLEnemyBattler:hurt(amount)
    -- Placeholder
    local info = debug.getinfo(2)
    print("Hurting" .. self.id .. " for "..amount .. " hp @ " .. info.source..":"..info.currentline)
    -- Will return a MNLDamageNumber once that exists
    return Object()
end

return MNLEnemyBattler