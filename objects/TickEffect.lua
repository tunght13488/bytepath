local GameObject = require "objects/GameObject"
local TickEffect = GameObject:extend()

function TickEffect:new(area, x, y, options)
  TickEffect.super.new(self, area, x, y, options)
  self.w, self.h = 32, 32
  self.y_offset = 0
  self.timer:tween(0.13, self, { h = 0, y_offset = 32 }, 'in-out-cubic', function() self.dead = true end)
  self.depth = 20
end

function TickEffect:update(dt)
  TickEffect.super.update(self, dt)
  if self.parent then self.x, self.y = self.parent.x, self.parent.y end
end

function TickEffect:draw()
  TickEffect.super.draw(self)
  love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.h / 2 + self.y_offset / 2, self.w, self.h)
end

function TickEffect:destroy()
  TickEffect.super.destroy(self)
end

return TickEffect
