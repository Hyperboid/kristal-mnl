---@class Character : Character
local Character, super = Utils.hookScript(Character)

function Character:init(...)
    super.init(self, ...)
    self.draw_shadow = true
end

function Character:draw()
    if self.draw_shadow then
        Draw.setColor(COLORS.black(.2))
        love.graphics.ellipse("fill", (self.width/2),self.z + (self.height) - self:getGroundLevel(), 8,4)
    end
    super.draw(self)
end

function Character:setActor(actor)
    super.setActor(self,actor)
    if (self.world or Game.world).map.side then
        self.collider.y = self.collider.y - ((self.actor.hitbox_thickness or 0)*2)
        self.collider.y = self.collider.y - .5
        self.collider.height = self.collider.height + ((self.actor.hitbox_thickness or 0)*2)
    else
        self.collider.thickness = self.actor.hitbox_thickness or 1
    end
end


function Character:doMoveAmount(type, amount, other_amount)
    other_amount = other_amount or 0

    if amount == 0 then
        self["last_collided_"..type] = false
        return false, false
    end

    local other = type == "x" and "y" or "x"

    local sign = Utils.sign(amount)
    for i = 1, math.ceil(math.abs(amount)) do
        local moved = sign
        if (i > math.abs(amount)) then
            moved = (math.abs(amount) % 1) * sign
        end

        local last_a = self[type]
        local last_b = self[other]

        self[type] = self[type] + moved

        if (not self.noclip) and (not NOCLIP) then
            Object.startCache()
            local collided, target = self:checkSolidCollision()
            if collided and not (other_amount > 0) then
                for j = 1, 2 do
                    Object.uncache(self)
                    self[other] = self[other] - j
                    collided, target = self:checkSolidCollision()
                    if not collided then break end
                end
            end
            if collided and not (other_amount < 0) then
                self[other] = last_b
                for j = 1, 2 do
                    Object.uncache(self)
                    self[other] = self[other] + j
                    collided, target = self:checkSolidCollision()
                    if not collided then break end
                end
            end
            Object.endCache()

            if collided then
                self[type] = last_a
                self[other] = last_b

                if target and target.onCollide then
                    target:onCollide(self)
                end

                self["last_collided_"..type] = true
                return i > 1, target
            end
        end
    end
    self["last_collided_"..type] = false
    return true, false
end

function Character:checkSolidCollision()
    if (self.world.map.data.properties.floor or -math.huge) > self.collider:getZ() then
        return true
    end
    return self.world:checkCollision(self.collider, self.enemy_collision)
end

return Character