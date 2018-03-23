local GameObject = require "objects/GameObject"
local TrailParticle = GameObject:extend()

function TrailParticle:new(area, x, y, options)
  TrailParticle.super.new(self, area, x, y, options)
  self.r = options.r or random(4, 6)
  self.timer:tween(options.d or random(0.3, 0.5), self, { r = 0 }, 'linear', function() self.dead = true end)
  self.depth = 10
end

function TrailParticle:update(dt)
  TrailParticle.super.update(self, dt)
end

function TrailParticle:draw()
  TrailParticle.super.draw(self)
  love.graphics.setColor(self.color)
  love.graphics.circle('fill', self.x, self.y, self.r)
end

function TrailParticle:destroy()
  TrailParticle.super.destroy(self)
end

return TrailParticle
