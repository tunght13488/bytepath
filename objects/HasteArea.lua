local GameObject = require "objects/GameObject"
local HasteArea = GameObject:extend()

function HasteArea:new(area, x, y, options)
    HasteArea.super.new(self, area, x, y, options)

    self.r = random(64, 96)
    self.timer:after(4, function ()
        self.timer:tween(0.25, self, { r = 0 }, 'in-out-cubic', function ()
            self.dead = true
        end)
    end)
end

function HasteArea:update(dt)
    HasteArea.super.update(self, dt)

    local player = current_room.player
    if not player then return end
    local d = distance(self.x, self.y, player.x, player.y)
    if d < self.r and not player.inside_haste_area then
        player.inside_haste_area = true
    elseif d >= self.r and player.inside_haste_area then
        player.inside_haste_area = false
    end
end

function HasteArea:draw()
    HasteArea.super.draw(self)
    love.graphics.setColor(ammo_color)
    -- love.graphics.circle('line', self.x, self.y, self.r + random(-2, 2))
    love.graphics.circle('line', self.x, self.y, self.r)
    love.graphics.setColor(default_color)
end

function HasteArea:destroy()
    HasteArea.super.destroy(self)
end

return HasteArea
