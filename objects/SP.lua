local GameObject = require "objects/GameObject"
local SP = GameObject:extend()

function SP:new(area, x, y, options)
    SP.super.new(self, area, x, y, options)
    local direction = table.random({ -1, 1 })
    self.x = gw / 2 + direction * (gw / 2 + 48)
    self.y = random(48, gh - 48)
    self.depth = 10
    self.w, self.h = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
    self.collider:applyAngularImpulse(random(-24, 24))
end

function SP:update(dt)
    SP.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
    if self.x < (-48 - self.w) or self.x > (gw + 48 + self.w) then
        self:die()
    end
end

function SP:draw()
    SP.super.draw(self)
    love.graphics.setColor(skill_point_color)
    pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rhombus(self.x, self.y, 1.5 * self.w, 1.5 * self.h, 'line')
    draft:rhombus(self.x, self.y, 0.5 * self.w, 0.5 * self.h, 'fill')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function SP:destroy()
    SP.super.destroy(self)
end

function SP:die()
    self.dead = true
    self.area:addGameObject('SPEffect', self.x, self.y, { color = skill_point_color, w = self.w, h = self.h })
    self.area:addGameObject('InfoText', self.x + random(-self.w, self.w), self.y + random(-self.h, self.h), { text = '+SP', color = skill_point_color })
    for i = 1, love.math.random(4, 8) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, { s = 3, color = skill_point_color })
    end
end

return SP
