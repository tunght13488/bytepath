local GameObject = Object:extend()

function GameObject:new(area, x, y, options)
    local options = options or {}
    if options then
        for k, v in pairs(options) do
            self[k] = v
        end
    end

    self.area = area
    self.x, self.y = x or 0, y or 0
    self.depth = 1
    self.creation_time = love.timer.getTime()
    self.id = UUID()
    self.dead = false
    self.timer = Timer()
end

function GameObject:update(dt)
    if self.timer then
        self.timer:update(dt)
    end
    if self.collider then
        self.x, self.y = self.collider:getPosition()
    end
end

function GameObject:draw()
end

function GameObject:destroy()
    self.timer:destroy()
    if self.collider then self.collider:destroy() end
    self.collider = nil
end

return GameObject
