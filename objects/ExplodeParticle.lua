local GameObject = require "objects/GameObject"
local ExplodeParticle = GameObject:extend()

function ExplodeParticle:new(area, x, y, options)
  ExplodeParticle.super.new(self, area, x, y, options)
  self.color = options.color or default_color
  self.r = random(0, 2 * math.pi)
  self.s = options.s or random(2, 3)
  self.v = options.v or random(75, 150)
  self.offset = 8
  self.dx = 0
  self.dy = 0
  self.line_width = 2
  self.timer:tween(options.d or random(0.3, 0.5), self, { s = 0, v = 0, line_width = 0 }, 'linear', function()
    self.dead = true
  end)
  self.depth = 20
end

function ExplodeParticle:update(dt)
  ExplodeParticle.super.update(self, dt)
  self.dx = self.dx + self.v * dt * math.cos(self.r)
  self.dy = self.dy + self.v * dt * math.sin(self.r)
end

function ExplodeParticle:draw()
  ExplodeParticle.super.draw(self)
  love.graphics.setLineWidth(self.line_width)
  love.graphics.setColor(self.color)
  love.graphics.line(self.x + self.offset * math.cos(self.r) + self.dx, self.y + self.offset * math.sin(self.r) + self.dy, self.x + self.offset * math.cos(self.r) + self.dx + self.s * math.cos(self.r), self.y + self.offset * math.sin(self.r) + self.dy + self.s * math.sin(self.r))
  love.graphics.setColor(255, 255, 255)
  love.graphics.setLineWidth(1)
end

function ExplodeParticle:destroy()
  ExplodeParticle.super.destroy(self)
end

return ExplodeParticle
