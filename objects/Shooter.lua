local GameObject = require "objects/GameObject"
local Shooter = GameObject:extend()

function Shooter:new(area, x, y, options)
  Shooter.super.new(self, area, x, y, options)

  local direction = table.random({ -1, 1 })
  self.x = options.x or gw / 2 + direction * (gw / 2 + 48)
  self.y = options.x or random(16, gh - 16)

  self.w, self.h = 12, 8
  self.collider = self.area.world:newPolygonCollider({ self.w, 0, -self.w / 2, self.h, -self.w, 0, -self.w / 2, -self.h })
  self.collider:setPosition(self.x, self.y)
  self.collider:setObject(self)
  self.collider:setCollisionClass('Enemy')
  self.collider:setFixedRotation(false)
  self.collider:setAngle(direction == 1 and math.pi or 0)
  self.collider:setFixedRotation(true)

  self.v = options.v or -direction * random(20, 40)
  self.collider:setLinearVelocity(self.v, 0)
  self.collider:applyAngularImpulse(random(-100, 100))

  self.max_hp = options.max_hp or 100
  self.hp = options.hp or self.max_hp
  self.hit_flash = false

  self.timer:after(random(3, 5), function(f)
    self.area:addGameObject('PreAttackEffect',
      self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
      self.y + 1.4 * self.w * math.sin(self.collider:getAngle()),
      { shooter = self, color = hp_color, duration = 1 })
    self.timer:after(1, function()
      self.area:addGameObject('EnemyProjectile',
        self.x + 1.4 * self.w * math.cos(self.collider:getAngle()),
        self.y + 1.4 * self.w * math.sin(self.collider:getAngle()),
        {
          r = math.atan2(current_room.player.y - self.y, current_room.player.x - self.x),
          v = random(80, 100),
          s = 3.5
        })
      self.timer:after(random(3, 5), f)
    end)
  end)
end

function Shooter:update(dt)
  Shooter.super.update(self, dt)
end

function Shooter:draw()
  Shooter.super.draw(self)
  local color = self.hit_flash and default_color or hp_color
  love.graphics.setColor(color)
  local points = { self.collider:getWorldPoints(self.collider.shapes.main:getPoints()) }
  love.graphics.polygon('line', points)
  love.graphics.setColor(default_color)
end

function Shooter:destroy()
  Shooter.super.destroy(self)
end

function Shooter:hit(damage)
  damage = damage or 100
  self.hp = self.hp - damage
  if self.hp <= 0 then
    current_room.score = current_room.score + 150
    self:die()
  else
    self.hit_flash = true
    self.timer:after(0.2, function()
      self.hit_flash = false
    end)
  end
end

function Shooter:die()
  self.dead = true
  self.area:addGameObject('EnemyDeathEffect', self.x, self.y, { color = hp_color, w = 3 * self.w })
  self.area:addGameObject('Ammo', self.x, self.y)
end

return Shooter
