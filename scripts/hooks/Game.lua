---@class Game : Game
local Game, super = Utils.hookScript(Game)

local function r_includes(getter, check, class)
    if isClass(check) then
        return check:includes(class)
    else
        check = getter(check)
        return check and check:includes(class) or false
    end
end

function Game:encounter(encounter, transition, enemy, context)
    if r_includes(Registry.getEncounter, encounter, MNLEncounter) then
        if transition == nil then transition = true end

        if self.battle then
            error("Attempt to enter battle while already in battle")
        end

        if enemy and not isClass(enemy) then
            self.encounter_enemies = enemy
        else
            self.encounter_enemies = {enemy}
        end

        self.state = "BATTLE"

        self.battle = MNLBattle()

        if context then
            self.battle.encounter_context = context
        end

        if type(transition) == "string" then
            self.battle:postInit(transition, encounter)
        else
            self.battle:postInit(transition and "TRANSITION" or "INTRO", encounter)
        end

        self.stage:addChild(self.battle)
    else
        return super.encounter(self, encounter, transition, enemy, context)
    end
end

return Game