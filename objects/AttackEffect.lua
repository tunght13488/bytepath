local GameObject = require "objects/GameObject"
local AttackEffect = GameObject:extend()

function AttackEffect:new(area, x, y, options)
  AttackEffect.super.new(self, area, x, y, options)
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

function AttackEffect:update(dt)
  AttackEffect.super.update(self, dt)
end

function AttackEffect:draw()
  AttackEffect.super.draw(self)
  if not self.visible then return end

  love.graphics.setColor(self.current_color)
  draft:rhombus(self.x, self.y, self.sx * 3 * self.w, self.sy * 3 * self.h, 'line')
  love.graphics.setColor(default_color)
  draft:rhombus(self.x, self.y, self.sx * 2.34 * self.w, self.sy * 2.34 * self.h, 'line')
  love.graphics.setColor(default_color)
end

function AttackEffect:destroy()
  AttackEffect.super.destroy(self)
end

return AttackEffect
