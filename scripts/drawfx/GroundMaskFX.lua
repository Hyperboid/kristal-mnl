---@class GroundMaskFX: FXBase
local GroundMaskFX, super = Class(FXBase)

function GroundMaskFX:init(priority)
    super.init(self, priority or 1000)
    self.inverted = true
end


function GroundMaskFX:draw(texture)
    local mask = Draw.pushCanvas(SCREEN_WIDTH, SCREEN_HEIGHT)
    for _, mask_obj in ipairs(self.parent.stage:getObjects(GroundPlane)) do
        love.graphics.replaceTransform(mask_obj.parent:getFullTransform())
        if mask_obj.drawMask then
            mask_obj:preDraw()
            mask_obj:drawMask(self.parent)
            mask_obj:postDraw()
        else
            mask_obj:fullDraw(not self.draw_children)
        end
    end
    Draw.popCanvas()
    Draw.setColor(1, 1, 1)
    love.graphics.stencil(function()
        local last_shader = love.graphics.getShader()
        love.graphics.setShader(Kristal.Shaders["Mask"])
        Draw.draw(mask)
        love.graphics.setShader(last_shader)
    end, "replace", 1)
    if not self.inverted then
        love.graphics.setStencilTest("greater", 0)
    else
        love.graphics.setStencilTest("less", 1)
    end
    Draw.drawCanvas(texture)
    love.graphics.setStencilTest()
end

return GroundMaskFX