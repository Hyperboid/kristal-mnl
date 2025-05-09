---@class MNLWave: Class
---@overload fun():MNLWave
local MNLWave, super = Class()

function MNLWave:init(parent)
    self.timer = Timer()
end

---@param parent MNLEnemyBattler
function MNLWave:setParent(parent)
    self.parent = parent
    self.battle = self.parent.battle or self.battle
end

function MNLWave:update()
    self.timer:fullUpdate()
    if self.thread and coroutine.status(self.thread) == "dead" then self:finish() end
end

function MNLWave:beforeEnd() end
function MNLWave:onEnd() end

function MNLWave:finish()
    if self.ended then return end
    if self:beforeEnd() then return end
    self.ended = true
    self.parent.wave = nil
    self.parent.battle:startNextTurn()
    self:onEnd()
end

function MNLWave:runCoroutine(f, ...)
    local resumed_running = false
    local thread = coroutine.create(f)
    local resume = function (...)
        if coroutine.status(thread) == "dead" then self:finish() end
        if coroutine.status(thread) == "running" then
            resumed_running = true
            return
        end
        local ok, msg = coroutine.resume(thread, ...)
        if not ok then
            COROUTINE_TRACEBACK = debug.traceback(thread)
            error(msg)
        end
    end
    local function await(...)
        if resumed_running then
            resumed_running = false
            return
        end
        local arg1 = ...
        if type(arg1) == "table" and arg1.after ~= resume then
            arg1.after = Utils.override(arg1.after, function (orig, ...)
                resume()
                orig(...)
            end)
        end
        return coroutine.yield(...)
    end
    resume(self, await, resume, ...)
    return thread, await, resume
end

function MNLWave:onStart()
    self.thread = self:runCoroutine(self.run)
end

---@async
---@param await async fun(...) Yields the coroutine. If passed a timer handle, will automatically add resume as a callback.
---@param resume fun() Resumes the coroutine after having yielded. Can also prevent yielding from the next await.
function MNLWave:run(await, resume)
    await(self.timer:after(0))
    self:finish()
end

-- *Override* Called when the attacker is directly counter-attacked.
---@param battler MNLPartyBattler
function MNLWave:onCounterAttack(battler) end

return MNLWave