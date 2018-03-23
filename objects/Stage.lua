local Area = require "objects/Area"
local Director = require "objects/Director"
local Stage = Object:extend()

function Stage:new()
  self.area = Area(self)
  self.area:addPhysicsWorld()
  self.area.world:addCollisionClass('Player')
  self.area.world:addCollisionClass('Projectile', { ignores = { 'Projectile' } })
  self.area.world:addCollisionClass('Collectable', { ignores = { 'Collectable', 'Projectile' } })
  self.area.world:addCollisionClass('Enemy', { ignores = { 'Enemy', 'Collectable' } })
  self.area.world:addCollisionClass('EnemyProjectile', { ignores = { 'EnemyProjectile', 'Enemy', 'Collectable' } })

  self.main_canvas = love.graphics.newCanvas(gw, gh)
  self.player = self.area:addGameObject('Player', gw / 2, gh / 2)
  self.director = Director(self)
  self.score = 0
  self.font = fonts.kenpixel_16

  -- input:bind('p', function()
  --     -- self.area:addGameObject('Ammo', random(0, gw), random(0, gh))
  --     self.area:addGameObject('Rock')
  -- end)

  -- timer:every(1, function()
  --     -- self.area:addGameObject('HP')
  --     -- self.area:addGameObject('Boost')
  --     -- self.area:addGameObject('SP')
  --     -- self.area:addGameObject('Attack')
  --     -- self.area:addGameObject('Rock')
  --     self.area:addGameObject('Shooter')
  -- end)
end

function Stage:update(dt)
  camera.smoother = Camera.smooth.damped(5)
  camera:lockPosition(dt, gw / 2, gh / 2)
  self.area:update(dt)
  self.director:update(dt)
end

function Stage:draw()
  local font_scale = 0.5

  love.graphics.setCanvas(self.main_canvas)
  love.graphics.clear()

  camera:attach(0, 0, gw, gh)
  -- camera:attach(0, 0, gw * sx, gh * sy)
  -- love.graphics.circle('line', gw / 2, gh / 2, 50)

  self.area:draw()

  love.graphics.setFont(self.font)

  -- Score
  love.graphics.setColor(default_color)
  love.graphics.print(self.score, gw - 20, 10, 0, font_scale, font_scale, math.floor(self.font:getWidth(self.score)), self.font:getHeight() / 2)
  love.graphics.setColor(255, 255, 255)

  -- SP
  love.graphics.setColor(skill_point_color)
  love.graphics.print(skill_points .. ' SP', 20, 10, 0, font_scale, font_scale, 0, self.font:getHeight() / 2)
  love.graphics.setColor(255, 255, 255)

  -- HP
  local r, g, b = unpack(hp_color)
  local hp, max_hp = self.player.hp, self.player.max_hp
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('fill', gw / 2 - 52, gh - 16, 48 * (hp / max_hp), 4)
  love.graphics.setColor(r - 32, g - 32, b - 32)
  love.graphics.rectangle('line', gw / 2 - 52, gh - 16, 48, 4)
  love.graphics.print('HP', gw / 2 - 52 + 24, gh - 16 - 8, 0, font_scale, font_scale, math.floor(self.font:getWidth('HP') / 2), math.floor(self.font:getHeight() / 2))
  love.graphics.print(hp .. '/' .. max_hp, gw / 2 - 52 + 24, gh - 16 + 10, 0, font_scale, font_scale, math.floor(self.font:getWidth(hp .. '/' .. max_hp) / 2), math.floor(self.font:getHeight() / 2))

  -- Ammo
  local r, g, b = unpack(ammo_color)
  local hp, max_hp = self.player.ammo, self.player.max_ammo
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('fill', gw / 2 - 52, 16, 48 * (hp / max_hp), 4)
  love.graphics.setColor(r - 32, g - 32, b - 32)
  love.graphics.rectangle('line', gw / 2 - 52, 16, 48, 4)
  love.graphics.print('AMMO', gw / 2 - 52 + 24, 16 - 8, 0, font_scale, font_scale, math.floor(self.font:getWidth('AMMO') / 2), math.floor(self.font:getHeight() / 2))
  love.graphics.print(hp .. '/' .. max_hp, gw / 2 - 52 + 24, 16 + 10, 0, font_scale, font_scale, math.floor(self.font:getWidth(hp .. '/' .. max_hp) / 2), math.floor(self.font:getHeight() / 2))

  -- Boost
  local r, g, b = unpack(boost_color)
  local hp, max_hp = math.floor(self.player.boost), self.player.max_boost
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('fill', gw / 2 + 4, 16, 48 * (hp / max_hp), 4)
  love.graphics.setColor(r - 32, g - 32, b - 32)
  love.graphics.rectangle('line', gw / 2 + 4, 16, 48, 4)
  love.graphics.print('BOOST', gw / 2 + 4 + 24, 16 - 8, 0, font_scale, font_scale, math.floor(self.font:getWidth('BOOST') / 2), math.floor(self.font:getHeight() / 2))
  love.graphics.print(hp .. '/' .. max_hp, gw / 2 + 4 + 24, 16 + 10, 0, font_scale, font_scale, math.floor(self.font:getWidth(hp .. '/' .. max_hp) / 2), math.floor(self.font:getHeight() / 2))

  -- Cycle
  local r, g, b = unpack(default_color)
  local hp, max_hp = self.player.cycle_timer, self.player.cycle
  love.graphics.setColor(r, g, b)
  love.graphics.rectangle('fill', gw / 2 + 4, gh - 16, 48 * (hp / max_hp), 4)
  love.graphics.setColor(r - 32, g - 32, b - 32)
  love.graphics.rectangle('line', gw / 2 + 4, gh - 16, 48, 4)
  love.graphics.print('CYCLE', gw / 2 + 4 + 24, gh - 16 - 8, 0, font_scale, font_scale, math.floor(self.font:getWidth('CYCLE') / 2), math.floor(self.font:getHeight() / 2))

  camera:detach()

  love.graphics.setCanvas()

  love.graphics.setColor(255, 255, 255, 255)
  love.graphics.setBlendMode('alpha', 'premultiplied')
  love.graphics.draw(self.main_canvas, 0, 0, 0, sx, sy)
  love.graphics.setBlendMode('alpha')
end

function Stage:destroy()
  self.area:destroy()
  self.area = nil
end

function Stage:finish()
  timer:after(1, function()
    gotoRoom('Stage', 'stage_room')
  end)
end

return Stage
