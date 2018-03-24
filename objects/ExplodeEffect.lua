local GameObject = require "objects/GameObject"
local ExplodeEffect = GameObject:extend()

function ExplodeEffect:new(area, x, y, options)
  ExplodeEffect.super.new(self, area, x, y, options)
  self.current_color = default_color
  self.timer:after(0.1, function()
    self.current_color = self.color
    self.timer:after(0.15, function()
      self.dead = true
    end)
  end)
  self.timer:tween(0.1, self, { w = 4 * self.w }, 'in-out-cubic', function()
    self.timer:tween(0.15, self, { w = 0 }, 'in-out-cubic')
  end)
  self.depth = 20
end

function ExplodeEffect:update(dt)
  ExplodeEffect.super.update(self, dt)
end

function ExplodeEffect:draw()
  ExplodeEffect.super.draw(self)
  love.graphics.setColor(self.current_color)
  love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
end

function ExplodeEffect:destroy()
  ExplodeEffect.super.destroy(self)
end

return ExplodeEffect
