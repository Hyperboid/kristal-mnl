---@class MNLLibrary
local lib = {}

Registry.registerGlobal("MNL", lib)
MNL = lib

function lib:init()
    Utils.hook(Registry.getPartyMember("kris"), "init", function (orig, pm,...)
        orig(pm,...)
        -- Give Kris the worst case of Main Character Syndrome
        pm.button = "confirm"
    end)
    ---@diagnostic disable-next-line: param-type-mismatch
    Utils.hook(Collider, "thickness", 1, true)
    ---@diagnostic disable-next-line: param-type-mismatch
    Utils.hook(Collider, "z", 1, true)
    Utils.hook(Collider, "getZ", function (orig, self)
        return ((self.parent and self.parent.z or 0) + self.z) + self.thickness
    end)
    Utils.hook(Collider, "getTransform", function (orig, self)
        if self.parent then self.parent.no_3d = true end
        local t = orig(self)
        if self.parent then self.parent.no_3d = false end
        return t
    end)
    for _, class in pairs(Collider.__includers) do
        ---@cast class Collider
        if class:includes(ColliderGroup) then goto continue end
        Utils.hook(class, "collidesWith", function (orig, self, other)
            if not orig(self, other) then return false end
            if not self.parent then return true end
            local own_z = self:getZ()
            local other_z = other:getZ()
            -- TODO: fix this shit
            ---@diagnostic disable-next-line: redundant-return-value
            return Utils.between(own_z, other_z - 1, other_z + other.thickness + self.thickness, true)
                or Utils.between(other_z, own_z - 1, own_z + self.thickness + other.thickness, true)
        end)
        if Kristal.getLibConfig("mnl", "draw_extruded_colliders") then
            Utils.hook(class, "draw", function (orig, self, r,g,b,a)
                if type(r) == "table" then r,g,b,a = Utils.unpackColor(r) end
                love.graphics.push()
                orig(self, r,g,b,a)
                for i=1,math.min(100,self.thickness)-.5,.5 do
                    love.graphics.translate(0, -1)
                    orig(self, r,g,b,(a or 1)/5)
                end
                love.graphics.translate(0, -1)
                orig(self, r,g,b,a)
                love.graphics.pop()
            end)
        end
        ::continue::
    end
end

function lib:loadObject(world, name, data)
    if name == "ground" then
        local z = data.properties.z or 0
        return GroundPlane(data.x,data.y + z+z,data.width, data.height, z)
    end
end

function lib:onRegisterEnemies()
    self.enemies = {}

    for _,path,enemy in Registry.iterScripts("battle/mnlenemies") do
        assert(enemy ~= nil, '"mnlenemies/'..path..'.lua" does not return value')
        enemy.id = enemy.id or path
        self.enemies[enemy.id] = enemy
    end
end

---@generic T:MNLEnemyBattler
---@param id MNLEnemyBattler.`T`
---@param ... any
---@return T
function lib:createEnemy(id, ...)
    if self.enemies[id] then
        return self.enemies[id](...)
    else
        error("Attempt to create non existent enemy \"" .. tostring(id) .. "\"")
    end
end

function lib:onRegisterWaves()
    self.waves = {}

    for _,path,enemy in Registry.iterScripts("battle/mnlwaves") do
        assert(enemy ~= nil, '"mnlwaves/'..path..'.lua" does not return value')
        enemy.id = enemy.id or path
        self.waves[enemy.id] = enemy
    end
end

---@generic T:MNLWave
---@param id MNLWave.`T`
---@param ... any
---@return T
function lib:createWave(id, ...)
    if self.waves[id] then
        return self.waves[id](...)
    else
        error("Attempt to create non existent wave \"" .. tostring(id) .. "\"")
    end
end


---@generic T:MNLEnemyBattler
---@param id MNLEnemyBattler.`T`
---@return T
function lib:getEnemy(id)
    return self.enemies[id]
end

function lib:getJumpPhysics(h, t)
    local g = (2*h)/(t^2)
    local v = math.sqrt(2*g*h)
    return g, v
end

function lib:getJumpDuration(g, h)
    local v = math.sqrt(2*g*h)
    local t = math.sqrt((2*h)/g)
    return t, v -- TV!?!? LIKE TENNA VISION!?!?!!??!?!?!? THE SONG BY SHAY!?!?!?!? HOLY FUCK
end

lib.DEFENSE_CONSTANT = 100
--- Returns damage that an attacker will deal to a target.
--- TODO: Adjust this to fit better with M&L gameplay
---@param attacker MNLPartyBattler|MNLEnemyBattler
---@param target MNLPartyBattler|MNLEnemyBattler
---@param attack_constant any
function lib:getAttackDamage(attacker, target, attack_constant)
    return Utils.round((attacker:getStat("attack", 1) * (self.DEFENSE_CONSTANT / (self.DEFENSE_CONSTANT + target:getStat("defense", 0)))) * attack_constant)
end

return lib