local GameObject = require "objects/GameObject"
local HP = GameObject:extend()

function HP:new(area, x, y, options)
    HP.super.new(self, area, x, y, options)
    local direction = table.random({ -1, 1 })
    self.x = gw / 2 + direction * (gw / 2 + 48)
    -- self.x = gw / 4
    self.y = random(48, gh - 48)
    self.depth = 10
    self.w, self.h = 8, 8
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction * random(20, 40)
    -- self.v = 0
    self.collider:setLinearVelocity(self.v, 0)
end

function HP:update(dt)
    HP.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
    if self.x < (-48 - self.w) or self.x > (gw + 48 + self.w) then
        self:die()
    end
end

function HP:draw()
    HP.super.draw(self)
    love.graphics.setColor(default_color)
    love.graphics.circle('line', self.x, self.y, self.w)
    love.graphics.setColor(hp_color)
    draft:rectangle(self.x, self.y, 1.2 * self.w, self.h / 2, 'fill')
    draft:rectangle(self.x, self.y, self.w / 2, 1.2 * self.h, 'fill')
    love.graphics.setColor(default_color)
end

function HP:destroy()
    HP.super.destroy(self)
end

function HP:die()
    self.dead = true
    self.area:addGameObject('HPEffect', self.x, self.y, { color = Boost_color, w = self.w, h = self.h })
    self.area:addGameObject('InfoText', self.x + random(-self.w, self.w), self.y + random(-self.h, self.h), { text = '+HP', color = hp_color })
    for i = 1, love.math.random(4, 8) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, { s = 3, color = Boost_color })
    end
end

return HP
