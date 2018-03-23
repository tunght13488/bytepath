local GameObject = require "objects/GameObject"
local EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, options)
  EnemyProjectile.super.new(self, area, x, y, options)

  self.s = options.s or 2.5
  self.v = options.v or 200
  self.depth = 10
  self.damage = options.damage or 10

  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setCollisionClass('EnemyProjectile')
  self.collider:setObject(self)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
end

function EnemyProjectile:update(dt)
  EnemyProjectile.super.update(self, dt)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))
  if self.x < 0 then self:die() end
  if self.y < 0 then self:die() end
  if self.x > gw then self:die() end
  if self.y > gh then self:die() end

  if self.collider:enter('Player') then
    local collision_data = self.collider:getEnterCollisionData('Player')
    local object = collision_data.collider:getObject()
    object:hit(self.damage)
    self:die()
  end
end

function EnemyProjectile:draw()
  EnemyProjectile.super.draw(self)
  love.graphics.setColor(hp_color)
  pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
  love.graphics.setLineWidth(self.s - self.s / 4)
  love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y)
  love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
  love.graphics.setLineWidth(1)
  love.graphics.pop()
  love.graphics.setColor(default_color)
end

function EnemyProjectile:destroy()
  EnemyProjectile.super.destroy(self)
end

function EnemyProjectile:die()
  self.dead = true
  self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, { color = hp_color, w = 3 * self.s })
end

return EnemyProjectile
