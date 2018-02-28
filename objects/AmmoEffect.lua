local GameObject = require "objects/GameObject"
local AmmoEffect = GameObject:extend()

function AmmoEffect:new(area, x, y, options)
    AmmoEffect.super.new(self, area, x, y, options)
    self.depth = 20
    self.current_color = default_color
    self.timer:after(0.1, function()
        self.current_color = self.color
        self.timer:after(0.15, function()
            self.dead = true
        end)
    end)
end

function AmmoEffect:update(dt)
    AmmoEffect.super.update(self, dt)
end

function AmmoEffect:draw()
    AmmoEffect.super.draw(self)
    love.graphics.setColor(self.current_color)
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
end

function AmmoEffect:destroy()
    AmmoEffect.super.destroy(self)
end

return AmmoEffect
