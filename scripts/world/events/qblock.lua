---@class Event.qblock : Event
local event, super = Class(Event, "qblock")

---@param data table
function event:init(data)
    super.init(self,data)
    local properties = data.properties or {}
    self.sprite = Sprite("world/events/qblock/default")
    self:addChild(self.sprite)
    self.sprite:setScale(2)
    self.solid = true
    self:move(0,10)
    self.sprite:move(0,10)
    local h = self.height/2
    self.ground_collider = Hitbox(self, 1,h+11,self.width-2,h-1)
    self.ground_collider.thickness = 30
    self:setHitbox(1,h+11,self.width-2,h-1)
    self.collider.thickness = 15
    self.collider.z = -20
    self:setOrigin(0,1)
end

function event:postLoad()
    if self:getFlag("used_once") then
        self.sprite:set("world/events/qblock/used")
    end
    self.z = self.z + 10
    self.y = self.y + 20
    self.init_z = self.z
    self.target_z = self.z + 10
end

function event:onHit(object, hit_type)
    if hit_type == "hammer" or object.z < (self.z-10) then
        Assets.playSound("bump")
        -- if self.bumping then return end
        local resume
        resume = coroutine.wrap(function ()
            self.bumping = true
            self.sprite.z = 0
            if self.timer_handle then self.world.map.timer:cancel(self.timer_handle) end
            self.timer_handle = self.world.map.timer:tween(.1, self.sprite, {
                z = 0 + 10
            }, "out-quad", resume)
            coroutine.yield()
            if self:getFlag("used_once", false) then
                self.world.timer:after(.1,resume)
                coroutine.yield()
            else
                self:setFlag("used_once", true)
                self:doItem(resume)
            end
            self.timer_handle = self.world.map.timer:tween(.1, self.sprite, {
                z = 0
            }, "in-quad", resume)
            self.sprite:set("world/events/qblock/used")
            coroutine.yield()
            self.bumping = false
        end)
        resume()
    end
end

function event:doItem(resume)
    -- TODO: spawn a coin sprite here
    Assets.playSound("bell")
    Game.money = Game.money + 1
    self.world.timer:after(.1,resume)
    coroutine.yield()
end

function event:getDebugRectangle()
    return {0, self.height/4, self.width, self.height*1.5}
end

function event:drawShadow()
    Draw.setColor(COLORS.black(.2))
    love.graphics.ellipse("fill", (self.width/2), self.height + self:getGroundLevel() * -2, 16,8)
end

function event:getSortPosition()
    return self.x, self.y-8
end

return event