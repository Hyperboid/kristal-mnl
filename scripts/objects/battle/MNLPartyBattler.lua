---@class MNLPartyBattler: MNLBattler
local MNLPartyBattler, super = Class("MNLBattler")

---@param chara     PartyMember
---@param x?        number
---@param y?        number
function MNLPartyBattler:init(chara, x, y)
    self.chara = chara
    self.actor = chara:getActor()

    super.init(self, x, y, self.actor:getSize())
    self.z_vel = 0
    self.state_manager = StateManager("STANDING", self, true)
    self.state_manager:addState("AIR", {update = self.updateAir, enter = self.beginAir, leave = self.endAir})
    self.state_manager:addState("STANDING", {update = self.updateStanding, enter = self.beginStanding, leave = self.endStanding})
    self:setActor(self.actor, true)
    self.sprite:setFacing("right")
    self:setAnimation("battle/idle")
    self.gravity, self.jump_velocity = MNL:getJumpPhysics((2.5)*20, .2)
end

function MNLPartyBattler:onButtonPressed()
    print("Pushed button "..self.chara.id..".")
end

function MNLPartyBattler:getSpeed()
    return self.chara:getStat("speed")
end

function MNLPartyBattler:onButtonPressed()
    if self.state == "STANDING" then
        self.z_vel = self.jump_velocity
        Assets.playSound(self.chara.jump_sound, 1, 1)
        self:setState("AIR")
    end
end

function MNLPartyBattler:setState(state, ...)
    self.state_manager:setState(state, ...)
end

function MNLPartyBattler:update()
    self.state_manager:update()
    super.update(self)
end

function MNLPartyBattler:beginAir()
    self.sprite:setSprite("jump")
end
function MNLPartyBattler:endAir()
    self.sprite:resetSprite()
end
function MNLPartyBattler:beginGround()
    self:setAnimation("battle/idle")
end

function MNLPartyBattler:moveZ(z, speed)
    z = (z or 0) * (speed or 1)
    local sign = Utils.sign(z)
    for i=1,math.floor(math.abs(z)) do
        self.z = self.z + sign
        for _, value in ipairs(self.parent.children) do
            
        end
    end
end

function MNLPartyBattler:updateAir()
    self:moveZ((self.z_vel * (DT)))
    if not NOCLIP then
        self.z_vel = math.max(-300, self.z_vel - (self.gravity*DT))
    end
    if self.z <= 0 then
        self.z = 0
        self.z_vel = 0
        self:setState("STANDING")
    end
end

function MNLPartyBattler:getStat(name, default)
    return self.chara:getStat(name, default)
end

return MNLPartyBattler