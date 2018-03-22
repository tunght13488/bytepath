local Area = Object:extend()

function Area:new(room)
    self.room = room
    self.game_objects = {}
end

function Area:update(dt)
    if self.world then self.world:update(dt) end
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:update(dt)
        if game_object.dead then
            game_object:destroy()
            table.remove(self.game_objects, i)
        end
    end
end

function Area:draw()
    if self.world then self.world:draw() end
    table.sort(self.game_objects, function(a, b)
        if a.depth == b.depth then
            return a.creation_time > b.creation_time
        else
            return a.depth > b.depth
        end
    end)

    for _, game_object in ipairs(self.game_objects) do game_object:draw() end
end

function Area:destroy()
    for i = #self.game_objects, 1, -1 do
        local game_object = self.game_objects[i]
        game_object:destroy()
        table.remove(self.game_objects, i)
    end
    self.game_object = {}
    if self.world then
        self.world:destroy()
        self.world = nil
    end
end

function Area:addGameObject(game_object_type, x, y, options)
    local options = options or {}
    local game_object = _G[game_object_type](self, x or 0, y or 0, options)
    table.insert(self.game_objects, game_object)
    return game_object
end

function Area:getGameObjects(predicate)
    return fn.select(self.game_objects, predicate)
end

function Area:queryCircleArea(x, y, radius, classes)
    return self:get_game_objects(function(_, game_object)
        for _, class in ipairs(classes) do
            if game_object:is(_G[class]) and distance(x, y, game_object.x, game_object.y) <= radius then
                return true
            end
        end
    end)
end

function Area:getClosestGameObject(x, y, radius, classes)
    local close_game_objects = self:query_circle_area(x, y, radius, classes)
    return fn.reduce(close_game_objects, function(closest_game_object, game_object)
        if closest_game_object then
            if distance(x, y, game_object.x, game_object.y) < distance(x, y, closest_game_object.x, closest_game_object.y) then
                return game_object
            else
                return closest_game_object
            end
        else
            return game_object
        end
    end)
end

function Area:addPhysicsWorld()
    self.world = wf.newWorld(0, 0, true)
end

function Area:getAllGameObjectsThat(filter)
    local out = {}
    for _, game_object in pairs(self.game_objects) do
        if filter(game_object) then
            table.insert(out, game_object)
        end
    end
    return out
end

return Area
