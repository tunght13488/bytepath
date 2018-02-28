local GameObject = require "objects/GameObject"
local EnemyDeathEffect = GameObject:extend()

function EnemyDeathEffect:new(area, x, y, options)
    EnemyDeathEffect.super.new(self, area, x, y, options)
    self.current_color = default_color
    self.timer:after(0.1, function()
        self.current_color = self.color
        self.timer:after(0.15, function()
            self.dead = true
        end)
    end)
    self.depth = 20
end

function EnemyDeathEffect:update(dt)
    EnemyDeathEffect.super.update(self, dt)
end

function EnemyDeathEffect:draw()
    EnemyDeathEffect.super.draw(self)
    love.graphics.setColor(self.current_color)
    love.graphics.rectangle('fill', self.x - self.w / 2, self.y - self.w / 2, self.w, self.w)
end

function EnemyDeathEffect:destroy()
    EnemyDeathEffect.super.destroy(self)
end

return EnemyDeathEffect
