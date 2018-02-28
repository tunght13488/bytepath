local GameObject = require "objects/GameObject"
local Attack = GameObject:extend()

function Attack:new(area, x, y, options)
    Attack.super.new(self, area, x, y, options)
    local direction = table.random({ -1, 1 })
    self.x = gw / 2 + direction * (gw / 2 + 48)
    self.y = random(48, gh - 48)
    if options.attack then
        self.attack = options.attack
    else
        local attacks_without_neutral = table.shallow_copy(attacks)
        attacks_without_neutral['Neutral'] = nil
        self.attack = table.randomp(attacks_without_neutral)
    end
    self.depth = 10
    self.w, self.h = 12, 12
    self.font = fonts.kenpixel_16
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.w, self.h)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.v = -direction * random(20, 40)
    self.collider:setLinearVelocity(self.v, 0)
end

function Attack:update(dt)
    Attack.super.update(self, dt)
    self.collider:setLinearVelocity(self.v, 0)
    if self.x < (-48 - self.w) or self.x > (gw + 48 + self.w) then
        self:die()
    end
end

function Attack:draw()
    Attack.super.draw(self)
    local width = self.font:getWidth(attacks[self.attack].abbreviation)
    love.graphics.setColor(attacks[self.attack].color)
    draft:rhombus(self.x, self.y, 2 * self.w, 2 * self.h, 'line')
    love.graphics.setFont(self.font)
    local scale = 0.4
    love.graphics.print(attacks[self.attack].abbreviation, self.x - width * scale / 2, self.y - self.font:getHeight() * scale / 2, 0, scale)
    love.graphics.setColor(default_color)
    draft:rhombus(self.x, self.y, 1.5 * self.w, 1.5 * self.h, 'line')
    love.graphics.setColor(default_color)
end

function Attack:destroy()
    Attack.super.destroy(self)
end

function Attack:die()
    self.dead = true
    self.area:addGameObject('AttackEffect', self.x, self.y, { color = attacks[self.attack].color, w = self.w, h = self.h })
    self.area:addGameObject('InfoText', self.x + random(-self.w, self.w), self.y + random(-self.h, self.h), { text = '+' .. self.attack, color = attacks[self.attack].color })
    for i = 1, love.math.random(4, 8) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, { s = 3, color = attacks[self.attack].color })
    end
end

return Attack
