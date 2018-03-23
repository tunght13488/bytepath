local GameObject = require "objects/GameObject"
local InfoText = GameObject:extend()

function InfoText:new(area, x, y, options)
  InfoText.super.new(self, area, x, y, options)
  self.depth = 30
  self.font = fonts.kenpixel_16
  self.characters = {}
  self.background_colors = {}
  self.foreground_colors = {}
  for i = 1, #self.text do
    table.insert(self.characters, self.text:utf8sub(i, i))
  end
  self.visible = true
  self.all_colors = fn.append(default_colors, negative_colors)
  self.timer:after(0.70, function()
    self.timer:every(0.05, function() self.visible = not self.visible end, 6)
    self.timer:after(0.35, function() self.visible = true end)
    self.timer:every(0.035, function()
      local random_characters = '0123456789!@#$%¨&*()-=+[]^~/;?><.,|abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWYXZ'
      for i, character in ipairs(self.characters) do
        if love.math.random(1, 100) <= 20 then
          local r = love.math.random(1, #random_characters)
          self.characters[i] = random_characters:utf8sub(r, r)
        else
          self.characters[i] = character
        end
        if love.math.random(1, 100) <= 30 then
          self.background_colors[i] = table.random(self.all_colors)
        else
          self.background_colors[i] = nil
        end

        if love.math.random(1, 100) <= 5 then
          self.foreground_colors[i] = table.random(self.all_colors)
        else
          self.background_colors[i] = nil
        end
      end
    end)
  end)
  self.timer:after(1.10, function() self.dead = true end)
  -- local all_info_texts = self.area:getAllGameObjectsThat(function(o)
  --     if o:is(InfoText) and o.id ~= self.id then
  --         return true
  --     end
  -- end)
  -- print(self.id, self.x, self.y, self:getWidth(), self:getHeight())
  -- if all_info_texts then
  --     for _, info_text in ipairs(all_info_texts) do
  --         -- pinspect(info_text.id)
  --         if rectangle_overlap(self.x, self.y, self.x + self:getWidth(), self.y + self:getHeight(), info_text.x, info_text.y, info_text.x + info_text:getWidth(), info_text.y + info_text:getHeight()) then
  --             print(self.id, self.x, self.y, self:getWidth(), self:getHeight())
  --             print(info_text.id, info_text.x, info_text.y, info_text:getWidth(), info_text:getHeight())
  --             print('overlap')
  --         end
  --     end
  -- end
end

function InfoText:update(dt)
  InfoText.super.update(self, dt)
end

function InfoText:draw()
  InfoText.super.draw(self)
  love.graphics.setFont(self.font)
  for i = 1, #self.characters do
    local width = 0
    if i > 1 then
      for j = 1, i - 1 do
        width = width + self.font:getWidth(self.characters[j])
      end
    end

    if self.background_colors[i] then
      love.graphics.setColor(self.background_colors[i])
      love.graphics.rectangle('fill', self.x + width, self.y - self.font:getHeight() / 2, self.font:getWidth(self.characters[i]), self.font:getHeight())
    end
    love.graphics.setColor(self.foreground_colors[i] or self.color or default_color)
    love.graphics.print(self.characters[i], self.x + width, self.y, 0, 1, 1, 0, self.font:getHeight() / 2)
  end
  love.graphics.setColor(default_color)
end

function InfoText:getWidth()
  local width = 0
  for i = 1, #self.characters do
    width = width + self.font:getWidth(self.characters[i])
  end
  return width
end

function InfoText:getHeight()
  return self.font:getHeight()
end

function InfoText:destroy()
  InfoText.super.destroy(self)
end

return InfoText
