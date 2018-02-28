local GameObject = require "objects/GameObject"
local HPEffect = GameObject:extend()

function HPEffect:new(area, x, y, options)
    HPEffect.super.new(self, area, x, y, options)
    self.depth = 20
    self.current_color = default_color
    self.timer:after(0.2, function()
        self.current_color = hp_color
        self.timer:after(0.35, function()
            self.dead = true
        end)
    end)
    self.visible = true
    self.timer:after(0.2, function()
        self.timer:every(0.05, function() self.visible = not self.visible end, 6)
        self.timer:after(0.35, function() self.visible = true end)
    end)
    self.sx, self.sy = 1, 1
    self.timer:tween(0.35, self, { sx = 2, sy = 2 }, 'in-out-cubic')
end

function HPEffect:update(dt)
    HPEffect.super.update(self, dt)
end

function HPEffect:draw()
    HPEffect.super.draw(self)
    if not self.visible then return end

    local scale = 2.5
    love.graphics.setColor(default_color)
    love.graphics.circle('line', self.x, self.y, scale * self.w)
    love.graphics.setColor(self.current_color)
    draft:rectangle(self.x, self.y, scale * 1.2 * self.w, scale * self.h / 2, 'fill')
    draft:rectangle(self.x, self.y, scale * self.w / 2, scale * 1.2 * self.h, 'fill')
    love.graphics.setColor(default_color)
end

function HPEffect:destroy()
    HPEffect.super.destroy(self)
end

return HPEffect
