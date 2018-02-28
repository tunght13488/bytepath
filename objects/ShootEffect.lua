local GameObject = require "objects/GameObject"
local ShootEffect = GameObject:extend()

function ShootEffect:new(area, x, y, options)
    ShootEffect.super.new(self, area, x, y, options)
    self.w = 8
    self.timer:tween(0.1, self, { w = 0 }, 'in-out-cubic', function()
        self.dead = true
    end)
    self.depth = 20
end

function ShootEffect:update(dt)
    ShootEffect.super.update(self, dt)
    if self.player then
        self.x = self.player.x + self.d * math.cos(self.player.r)
        self.y = self.player.y + self.d * math.sin(self.player.r)
    end
end

function ShootEffect:draw()
    ShootEffect.super.draw(self)
    -- love.graphics.print('ShootEffect: '..self.x..', '..self.y, self.x + 15, self.y + 15)
    -- pushRotate(self.player.x, self.player.y, math.pi / 2)
    pushRotate(self.x, self.y, self.player.r + math.pi / 4)
    love.graphics.setColor(default_color)
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
    love.graphics.pop()
    -- love.graphics.pop()
end

function ShootEffect:destroy()
    ShootEffect.super.destroy(self)
end

return ShootEffect
