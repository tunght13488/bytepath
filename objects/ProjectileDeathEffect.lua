local GameObject = require "objects/GameObject"
local ProjectileDeathEffect = GameObject:extend()

function ProjectileDeathEffect:new(area, x, y, options)
  ProjectileDeathEffect.super.new(self, area, x, y, options)
  self.current_color = default_color
  self.timer:after(0.1, function()
    self.current_color = self.color
    self.timer:after(0.15, function()
      self.dead = true
    end)
  end)
  self.depth = 20
end

function ProjectileDeathEffect:update(dt)
  ProjectileDeathEffect.super.update(self, dt)
end

function ProjectileDeathEffect:draw()
  ProjectileDeathEffect.super.draw(self)
  love.graphics.setColor(self.current_color)
  love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
end

function ProjectileDeathEffect:destroy()
  ProjectileDeathEffect.super.destroy(self)
end

return ProjectileDeathEffect
