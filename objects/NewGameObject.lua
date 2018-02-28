local GameObject = require "objects/GameObject"
local NewGameObject = GameObject:extend()

function NewGameObject:new(area, x, y, options)
    NewGameObject.super.new(self, area, x, y, options)
end

function NewGameObject:update(dt)
    NewGameObject.super.update(self, dt)
end

function NewGameObject:draw()
    NewGameObject.super.draw(self)
end

function NewGameObject:destroy()
    NewGameObject.super.destroy(self)
end

return NewGameObject
