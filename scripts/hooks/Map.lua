---@class Map : Map
local Map, super = Class("Map")


function Map:init(world, data)
    super.init(self,world,data)

    self.side = data and data.properties and data.properties["side"] or false
    self.floor = data and data.properties and data.properties["floor"]
end

function Map:loadHitboxes(layer)
    local hitboxes = super.loadHitboxes(self, layer)
    if not self.side then
        for _, collider in ipairs(hitboxes) do
            collider.thickness = math.huge
        end
    end
    local floor = Hitbox(self.world, 0,0,1000,1000)
    floor.z = -5
    table.insert(hitboxes, floor)
    return hitboxes
end

function Map:loadObject(name, data)
    local obj = super.loadObject(self,name,data)
    if data.properties.z then
        obj.z = data.properties.z
        if not obj:includes(GroundPlane) then
            obj.y = obj.y + (obj.z*2)
            
        end
    end
    return obj
end

function Map:loadObjects(layer, depth, layer_type)
    super.loadObjects(self,layer, depth, layer_type)
    for _, event in pairs(self.events_by_layer[layer.name]) do
        event.z = layer.properties and layer.properties.z or event.z
    end
end

return Map