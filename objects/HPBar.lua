local HPBar = Object:extend()

function HPBar:new(hp)
  self.hp = hp
  self.bar = hp
  self.background = hp
  input:bind('d', 'take_damage')
end

function HPBar:update(dt)
  if input:down('take_damage', 0.5) then
    self.hp = math.max(self.hp - love.math.random(1, 100), 1)
    timer:tween('take_damage', 0.25, self, { bar = self.hp }, 'in-out-cubic')
    timer:tween('take_damage_background', 1, self, { background = self.hp }, 'in-out-cubic')
  end
end

function HPBar:draw()
  love.graphics.setColor(255, 128, 128, 100)
  love.graphics.rectangle('fill', 400, 300, self.bar, 50)
  love.graphics.setColor(255, 128, 128, 80)
  love.graphics.rectangle('fill', 400, 300, self.background, 50)
end

return HPBar
