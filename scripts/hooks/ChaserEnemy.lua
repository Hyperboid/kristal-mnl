---@class ChaserEnemy : ChaserEnemy
---@field world World?
local ChaserEnemy, super = Class("ChaserEnemy")

function ChaserEnemy:onCollide(player)
    if not (
        (self.encounter and Registry.getEncounter(self.encounter):includes(MNLEncounter))
        or (self.enemy and Registry.getEnemy(self.enemy):includes(MNLEnemyBattler))
    ) then
        return super.onCollide(self, player)
    end
    if self:isActive() and player:includes(Player) then
        ---@cast player Player
        local stomped = player.z_vel < 0
        self.encountered = true
        ---@type string|Encounter
        local encounter = self.encounter
        if not encounter and Registry.getEnemy(self.enemy or self.actor.id) then
            encounter = Encounter()
            encounter:addEnemy(self.actor.id)
        end
        if encounter then
            if stomped then
                Assets.playSound("jump",1,2.5)
            else
                Assets.playSound("tensionhorn")
            end
            self.world.encountering_enemy = true
            self.sprite:setAnimation("hurt")
            self.sprite.aura = false
            Game.lock_movement = true
            self.world.timer:script(function(wait)
                wait(12/30)
                if not stomped then
                    wait(8/30)
                end
                self.world.encountering_enemy = false
                Game.lock_movement = false
                local enemy_target = self
                if self.enemy then
                    enemy_target = {{self.enemy, self}}
                end
                Game:encounter(encounter, true, enemy_target, self)
            end)
        end
    end
end

return ChaserEnemy