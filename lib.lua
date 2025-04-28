local lib = {}

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
        return (self.parent and self.parent.z or 0) + self.z
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
            return Utils.between(own_z, other_z - 1, other_z + other.thickness + self.thickness, true)
                or Utils.between(other_z, own_z - 1, own_z + self.thickness + other.thickness, true)
            
        end)
        ::continue::
    end
end

function lib:loadObject(world, name, data)
    if name == "ground" then
        local z = data.properties.z or 0
        return GroundPlane(data.x,data.y + z+z,data.width, data.height, z)
    end
end

return lib