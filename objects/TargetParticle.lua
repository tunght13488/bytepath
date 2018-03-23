local GameObject = require "objects/GameObject"
local TargetParticle = GameObject:extend()

function TargetParticle:new(area, x, y, options)
  TargetParticle.super.new(self, area, x, y, options)
  self.r = options.r or random(2, 3)
  self.timer:tween(options.d or random(0.1, 0.3),
    self,
    { r = 0, x = self.target_x, y = self.target_y },
    'out-cubic',
    function() self.dead = true end)
  self.depth = 20
end

function TargetParticle:update(dt)
  TargetParticle.super.update(self, dt)
end

function TargetParticle:draw()
  TargetParticle.super.draw(self)
  love.graphics.setColor(self.color)
  draft:rhombus(self.x, self.y, 2 * self.r, 2 * self.r, 'fill')
  love.graphics.setColor(default_color)
end

function TargetParticle:destroy()
  TargetParticle.super.destroy(self)
end

return TargetParticle
