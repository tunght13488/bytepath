local GameObject = require "objects/GameObject"
local BoostEffect = GameObject:extend()

function BoostEffect:new(area, x, y, options)
  BoostEffect.super.new(self, area, x, y, options)
  self.depth = 20
  self.current_color = default_color
  self.timer:after(0.2, function()
    self.current_color = boost_color
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

function BoostEffect:update(dt)
  BoostEffect.super.update(self, dt)
end

function BoostEffect:draw()
  BoostEffect.super.draw(self)
  if not self.visible then return end

  love.graphics.setColor(self.current_color)
  draft:rhombus(self.x, self.y, self.sx * 1.34 * self.w, self.sy * 1.34 * self.h, 'fill')
  draft:rhombus(self.x, self.y, self.sx * 2 * self.w, self.sy * 2 * self.h, 'line')
  love.graphics.setColor(default_color)
end

function BoostEffect:destroy()
  BoostEffect.super.destroy(self)
end

return BoostEffect
