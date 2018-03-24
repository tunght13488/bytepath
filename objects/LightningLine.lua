local GameObject = require "objects/GameObject"
local LightningLine = GameObject:extend()

function LightningLine:new(area, x, y, options)
  LightningLine.super.new(self, area, x, y, options)
  self:generate()
  self.alpha = 255
  self.timer:tween(0.15, self, { alpha = 0 }, 'in-out-cubic', function()
    self.dead = true
  end)
end

function LightningLine:update(dt)
  LightningLine.super.update(self, dt)
end

function LightningLine:generate()
  -- populate self.lines
  local lines = {
    { x1 = self.x1, y1 = self.y1, x2 = self.x2, y2 = self.y2 }
  }
  local offset = 10
  local generation = 5
  local length_scale = 0.7
  for i = 1, generation do
    local tmp_lines = {}
    for _, line in pairs(lines) do
      local start_point = Vector(line.x1, line.y1)
      local end_point = Vector(line.x2, line.y2)
      local mid_point = (start_point + end_point) / 2
      mid_point = mid_point + ((end_point - start_point):normalized() * random(-offset, offset)):perpendicular()
      tmp_lines[#tmp_lines + 1] = { x1 = start_point.x, y1 = start_point.y, x2 = mid_point.x, y2 = mid_point.y }
      tmp_lines[#tmp_lines + 1] = { x1 = mid_point.x, y1 = mid_point.y, x2 = end_point.x, y2 = end_point.y }
      -- local direction = mid_point - start_point
      -- local split_end = direction:rotated(random(-math.pi/18, math.pi/18)) * length_scale + mid_point
      -- tmp_lines[#tmp_lines + 1] = { x1 = mid_point.x, y1 = mid_point.y, x2 = split_end.x, y2 = split_end.y }
    end
    lines = tmp_lines
    offset = offset / 2
  end
  self.lines = lines
end

function LightningLine:draw()
  LightningLine.super.draw(self)
  for i, line in ipairs(self.lines) do
    local r, g, b = unpack(boost_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(2.5)
    love.graphics.line(line.x1, line.y1, line.x2, line.y2)

    local r, g, b = unpack(default_color)
    love.graphics.setColor(r, g, b, self.alpha)
    love.graphics.setLineWidth(1.5)
    love.graphics.line(line.x1, line.y1, line.x2, line.y2)
  end
  love.graphics.setLineWidth(1)
  love.graphics.setColor(255, 255, 255, 255)
  -- for i, line in ipairs(self.lines) do
  --   love.graphics.line(line.x1, line.y1, line.x2, line.y2)
  -- end
end

function LightningLine:destroy()
  LightningLine.super.destroy(self)
end

return LightningLine
