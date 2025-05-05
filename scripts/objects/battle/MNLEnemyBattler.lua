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
    self:setWave(MNLWave())
end

return MNLEnemyBattler