local GameObject = require "objects/GameObject"
local Projectile = require "objects/Projectile"
local Rock = GameObject:extend()

function Rock:new(area, x, y, options)
  Rock.super.new(self, area, x, y, options)

  local direction = table.random({ -1, 1 })
  self.x = options.x or gw / 2 + direction * (gw / 2 + 48)
  self.y = options.x or random(16, gh - 16)

  self.w, self.h = 8, 8
  self.collider = self.area.world:newPolygonCollider(createIrregularPolygon(8))
  self.collider:setPosition(self.x, self.y)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Enemy')
  self.collider:setFixedRotation(false)

  self.v = options.v or -direction * random(20, 40)
  self.collider:setLinearVelocity(self.v, 0)
  self.collider:applyAngularImpulse(random(-100, 100))

  self.max_hp = options.max_hp or 100
  self.hp = options.hp or self.max_hp
  self.hit_flash = false
end

function Rock:update(dt)
  Rock.super.update(self, dt)
end

function Rock:draw()
  Rock.super.draw(self)
  local color = self.hit_flash and default_color or hp_color
  love.graphics.setColor(color)
  local points = { self.collider:getWorldPoints(self.collider.shapes.main:getPoints()) }
  love.graphics.polygon('line', points)
  love.graphics.setColor(default_color)
end

function Rock:destroy()
  Rock.super.destroy(self)
end

function Rock:hit(damage)
  damage = damage or 100
  self.hp = self.hp - damage
  if self.hp <= 0 then
    current_room.score = current_room.score + 100
    self:die()
  else
    self.hit_flash = true
    self.timer:after(0.2, function()
      self.hit_flash = false
    end)
  end
end

function Rock:die()
  self.dead = true
  self.area:addGameObject('EnemyDeathEffect', self.x, self.y, { color = hp_color, w = 3 * self.w })
  self.area:addGameObject('Ammo', self.x, self.y)
end

return Rock
