function Mod:init()
    print("Loaded "..self.info.name.."!")
    FOLLOW_DELAY = 0.35
end

function Mod:postInit()
    Game.world.camera.keep_in_bounds = false
end

function Mod:postLoad()
    Game:setFlag("has_hammers", true)
end
