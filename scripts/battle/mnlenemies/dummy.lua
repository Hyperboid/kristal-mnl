local Dummy, super = Class(MNLEnemyBattler)

function Dummy:init()
    super.init(self)

    -- Enemy name
    self.name = "Dummy"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("dummy")

    -- Enemy health
    self.max_health = 60
    self.health = 60
    -- Enemy attack (determines collision damage)
    self.attack = 4
    self.defense = 4
    -- Enemy reward
    self.money = 40
    self.waves = {
        "basic",
    }
end

return Dummy