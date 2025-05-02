-- Since this state is rather complicated, we dedicate a whole StateClass to it.

---@class MNLBattleActionSelect: StateClass
---@overload fun(battle:MNLBattle):MNLBattleActionSelect
local MNLBattleActionSelect, super = Class(StateClass)

---@param battle MNLBattle
function MNLBattleActionSelect:init(battle)
    self.battle = battle
    self.helper_transform = love.math.newTransform()
    self.radius = 14
    self.selected_button = 1
    self.rotation_timer = 0
end

function MNLBattleActionSelect:registerEvents()
    self:registerEvent("enter", self.onEnter)
    self:registerEvent("leave", self.onLeave)
    self:registerEvent("keypressed", self.onKeyPressed)
    self:registerEvent("update", self.update)
end

function MNLBattleActionSelect:onKeyPressed(key)
    -- if self.rotation_timer ~= math.floor(self.rotation_timer) then return end
    if Input.is("left", key) then
        self.selected_button = Utils.clampWrap(self.selected_button + 1, 1, #self.buttons)
        self.rotation_timer = self.rotation_timer - 1
        if self.rotation_handle then
            self.battle.timer:cancel(self.rotation_handle)
        end
        self.rotation_handle = self.battle.timer:tween(0.2, self, {rotation_timer = 0},"out-quad")
        Assets.playSound("ui_move")
    end
    if Input.is("right", key) then
        self.selected_button = Utils.clampWrap(self.selected_button - 1, 1, #self.buttons)
        self.rotation_timer = self.rotation_timer + 1
        if self.rotation_handle then
            self.battle.timer:cancel(self.rotation_handle)
        end
        self.rotation_handle = self.battle.timer:tween(0.2, self, {rotation_timer = 0},"out-quad")
        Assets.playSound("ui_move")
    end
end

---@param battler MNLPartyBattler
function MNLBattleActionSelect:onEnter(prev_state, battler)
    self.battler = battler
    self:createButtons()
end

function MNLBattleActionSelect:onLeave()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end
end

function MNLBattleActionSelect:update()
    for index, button in ipairs(self.buttons) do
        button:setPosition(self:getButtonPos(index, button))
    end
end

function MNLBattleActionSelect:getButtonPos(index, button)
    return self.helper_transform:reset()
        :translate(self.battler:getPosition())
        :translate(self.battler:getScaledWidth() / -2, -(self.radius*5))
        :scale(4,2)
        :rotate(((index + (-(self.selected_button+self.rotation_timer))) / #self.buttons) * math.pi*2)
        :transformPoint(0, self.radius)
end


function MNLBattleActionSelect:createButtons()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end

    self.buttons = {}

    local btn_types = {"jump", "hammer", "special", "flee", "item"}

    for lib_id,_ in Kristal.iterLibraries() do
        btn_types = Kristal.libCall(lib_id, "getMNLActionBlocks", self.battler, btn_types) or btn_types
    end
    btn_types = Kristal.modCall("getMNLActionBlocks", self.battler, btn_types) or btn_types

    local start_x = (213 / 2) - ((#btn_types-1) * 35 / 2) - 1

    if (#btn_types <= 5) and Game:getConfig("oldUIPositions") then
        start_x = start_x - 5.5
    end

    for i,btn in ipairs(btn_types) do
        if type(btn) == "string" then
            local button = MNLActionBlock(btn, self.battler, math.floor(start_x + ((i - 1) * 35)) + 0.5, 21)
            button.z = 50
            button.actbox = self
            table.insert(self.buttons, button)
            self.battle:addChild(button)
        elseif type(btn) ~= "boolean" then -- nothing if a boolean value, used to create an empty space
            btn:setPosition(math.floor(start_x + ((i - 1) * 35)) + 0.5, 21)
            btn.battler = self.battler
            btn.actbox = self
            table.insert(self.buttons, btn)
            self.battle:addChild(btn)
        end
    end


    for index, button in ipairs(self.buttons) do
        button:setPosition(self:getButtonPos(index, button))
    end

    self.selected_button = Utils.clamp(self.selected_button or 1, 1, #self.buttons)
end

return MNLBattleActionSelect