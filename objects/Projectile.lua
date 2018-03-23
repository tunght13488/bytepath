local GameObject = require "objects/GameObject"
local Projectile = GameObject:extend()

function Projectile:new(area, x, y, options)
  Projectile.super.new(self, area, x, y, options)

  self.s = options.s or (self.attack == 'Homing' and 4 or 2.5)
  if self.parent and self.parent.projectile_size_multiplier then
    self.s = self.s * self.parent.projectile_size_multiplier
  end
  self.original_v = options.v or 200
  self.v = self.original_v
  self.depth = 10
  self.color = options.color or attacks[self.attack].color
  self.damage = options.damage or 100
  self.projectile_duration_multiplier = 1
  if self.parent and self.parent.projectile_duration_multiplier then
    self.projectile_duration_multiplier = self.parent.projectile_duration_multiplier
  end
  self.rv = table.random({ random(-2 * math.pi, -math.pi), random(math.pi, 2 * math.pi) })

  -- Collision
  self.collider = self.area.world:newCircleCollider(self.x, self.y, self.s)
  self.collider:setCollisionClass('Projectile')
  self.collider:setObject(self)
  self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

  -- Trail
  self.trail_color = skill_point_color
  if self.attack == 'Homing' then
    self.timer:every(0.01, function()
      self.area:addGameObject('TrailParticle',
        self.x - self.s * math.cos(self.r),
        self.y - self.s * math.sin(self.r),
        { parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color })
    end)
  end

  -- Effect
  if self.attack ~= 'Homing' then
    if current_room.player.projectile_ninety_degree_change then
      self.timer:after(0.2, function()
        self.ninety_degree_direction = table.random({ -1, 1 })
        self.r = self.r + self.ninety_degree_direction * math.pi / 2
        self.timer:every('ninety_degree_first', 0.25 / current_room.player.angle_change_frequency_multiplier, function()
          self.r = self.r - self.ninety_degree_direction * math.pi / 2
          self.timer:after('ninety_degree_second', 0.1 / current_room.player.angle_change_frequency_multiplier, function()
            self.r = self.r - self.ninety_degree_direction * math.pi / 2
            self.ninety_degree_direction = -1 * self.ninety_degree_direction
          end)
        end)
      end)
    end
    if current_room.player.projectile_random_degree_change then
      self.timer:every('random_degree', 0.25 / current_room.player.angle_change_frequency_multiplier, function()
        self.random_degree_direction = random(-math.pi, math.pi)
        self.r = self.r + self.random_degree_direction
      end)
    end
    if current_room.player.wavy_projectiles then
      local direction = table.random({ -1, 1 })
      self.timer:tween(0.25, self, { r = self.r + direction * math.pi / 8 * current_room.player.projectile_waviness_multiplier }, 'linear', function()
        self.timer:tween(0.25, self, { r = self.r - direction * math.pi / 4 * current_room.player.projectile_waviness_multiplier }, 'linear')
      end)
      self.timer:every(0.75, function()
        self.timer:tween(0.25, self, { r = self.r + direction * math.pi / 4 * current_room.player.projectile_waviness_multiplier }, 'linear', function()
          self.timer:tween(0.5, self, { r = self.r - direction * math.pi / 4 * current_room.player.projectile_waviness_multiplier }, 'linear')
        end)
      end)
    end
    if current_room.player.fast_slow then
      local initial_v = self.v
      self.timer:tween('fast_slow_first', 0.2, self, { v = initial_v * 2 * current_room.player.projectile_acceleration_multiplier }, 'in-out-cubic', function()
        self.timer:tween('fast_slow_second', 0.3, self, { v = initial_v / 2 / current_room.player.projectile_deceleration_multiplier }, 'linear')
      end)
    end
    if current_room.player.slow_fast then
      local initial_v = self.v
      self.timer:tween('slow_fast_first', 0.2, self, { v = initial_v / 2 / current_room.player.projectile_deceleration_multiplier }, 'in-out-cubic', function()
        self.timer:tween('slow_fast_second', 0.3, self, { v = initial_v * 2 * current_room.player.projectile_acceleration_multiplier }, 'linear')
      end)
    end
    if self.shield then
      self.orbit_distance = random(32, 64)
      self.orbit_speed = random(-6, 6)
      self.orbit_offset = random(0, 2 * math.pi)
      self.invisible = true
      self.timer:after(0.05, function() self.invisible = false end)
    end
  end

  if self.attack == 'Blast' then
    self.damage = 75
    self.color = table.random(negative_colors)
    if not self.shield then
      self.timer:tween(random(0.4, 0.6) * self.projectile_duration_multiplier, self, { v = 0 }, 'linear', function() self:die() end)
    end
  end

  if self.attack == 'Flame' then
    self.damage = 50
    if not self.shield then
      self.timer:tween(random(0.6, 1) * self.projectile_duration_multiplier, self, { v = 0 }, 'linear', function() self:die() end)
    end
    self.timer:every(0.05, function()
      self.area:addGameObject('ProjectileTrail',
        self.x,
        self.y,
        { r = self.r, color = self.color, s = self.s })
    end)
  end

  -- Homing shape
  self.polygons = {
    {
      color = default_color,
      verticles = {
        0, self.s,
        self.s, 0,
        0, -self.s,
      },
    },
    {
      color = self.color,
      verticles = {
        0, self.s,
        -self.s, 0,
        0, -self.s,
      },
    },
  }

  self.time = 0
  self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:update(dt)
  Projectile.super.update(self, dt)
  self.time = self.time + dt

  local spd_multiplier = 1
  if current_room and current_room.player and (not current_room.player.dead) then
    spd_multiplier = current_room.player.pspd_multiplier.value
  end

  if self.x < 0 then self:die() end
  if self.y < 0 then self:die() end
  if self.x > gw then self:die() end
  if self.y > gh then self:die() end

  if self.attack == 'Spread' then
    self.color = table.random(default_colors)
  end

  if self.attack == 'Homing' then
    -- Acquire new target
    if not self.target then
      local targets = self.area:getAllGameObjectsThat(function(e)
        for _, enemy in ipairs(enemies) do
          if e:is(_G[enemy]) and (not e.dead) and (distance(e.x, e.y, self.x, self.y) < 400) then
            return true
          end
        end
      end)
      self.target = table.remove(targets, love.math.random(1, #targets))
    end
    if self.target and self.target.dead then self.target = nil end

    -- Move towards target
    if self.target then
      local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
      local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
      self.r = angle
      local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
      local final_heading = (projectile_heading + 0.1 * to_target_heading):normalized()
      self.collider:setLinearVelocity(self.v * spd_multiplier * final_heading.x, self.v * spd_multiplier * final_heading.y)
    end
  else
    self.collider:setLinearVelocity(self.v * spd_multiplier * math.cos(self.r), self.v * spd_multiplier * math.sin(self.r))
  end

  -- Collide with Enemy
  if self.collider:enter('Enemy') then
    local collision_data = self.collider:getEnterCollisionData('Enemy')
    local object = collision_data.collider:getObject()
    if object then
      object:hit(self.damage)
      self:die()
      if object.hp <= 0 then
        current_room.player:onKill(object)
      end
    end
  end

  -- Collide with EnemyProjectile
  -- if self.collider:enter('EnemyProjectile') then
  --     local collision_data = self.collider:getEnterCollisionData('EnemyProjectile')
  --     local object = collision_data.collider:getObject()
  --     self:die()
  --     object:die()
  -- end

  if self.attack ~= 'Homing' then
    if self.shield then
      self.collider:setPosition(self.parent.x + self.orbit_distance * math.cos(self.orbit_speed * self.time + self.orbit_offset),
        self.parent.y + self.orbit_distance * math.sin(self.orbit_speed * self.time + self.orbit_offset))
      local x, y = self.collider:getPosition()
      local dx, dy = x - self.previous_x, y - self.previous_y
      self.r = Vector(dx, dy):angleTo()
      self.timer:after(6 * self.projectile_duration_multiplier, function() self:die() end)
    end
  end

  if self.attack == 'Spin' then
    self.r = self.r + self.rv * dt
    self.timer:after(random(2.4, 3.2), function() self:die() end)
    self.timer:every(0.05, function()
      self.area:addGameObject('ProjectileTrail',
        self.x,
        self.y,
        { r = Vector(self.collider:getLinearVelocity()):angleTo(), color = self.color, s = self.s })
    end)
  end

  self.previous_x, self.previous_y = self.collider:getPosition()
end

function Projectile:draw()
  Projectile.super.draw(self)
  if self.invisible then return end
  if self.attack == 'Homing' then
    pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
    -- love.graphics.setColor(self.color)
    -- draft:triangleRight(self.x, self.y, self.s, self.s, 'fill')
    -- draft:rhombus(self.x, self.y, self.s, self.s, 'fill')
    for _, polygon in ipairs(self.polygons) do
      love.graphics.setColor(polygon.color)
      local verticles = fn.map(polygon.verticles, function(k, v)
        if k % 2 == 1 then
          return self.x + v
        else
          return self.y + v
        end
      end)
      draft:polygon(verticles, 'fill')
    end
    love.graphics.pop()
    love.graphics.setColor(default_color)
  else
    love.graphics.setColor(default_color)
    pushRotate(self.x, self.y, Vector(self.collider:getLinearVelocity()):angleTo())
    love.graphics.setLineWidth(self.s - self.s / 4)
    love.graphics.setColor(self.color)
    love.graphics.line(self.x - 2 * self.s, self.y, self.x, self.y)
    love.graphics.setColor(default_color)
    love.graphics.line(self.x, self.y, self.x + 2 * self.s, self.y)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
  end
  love.graphics.setColor(default_color)
end

function Projectile:destroy()
  Projectile.super.destroy(self)
end

function Projectile:die()
  self.dead = true
  self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, { color = hp_color, w = 3 * self.s })
end

return Projectile
