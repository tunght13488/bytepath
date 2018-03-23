function recursiveEnumerate(folder, file_list)
  local items = love.filesystem.getDirectoryItems(folder)
  for _, item in ipairs(items) do
    local file = folder .. '/' .. item
    if love.filesystem.isFile(file) then
      table.insert(file_list, file)
    elseif love.filesystem.isDirectory(file) then
      recursiveEnumerate(file, file_list)
    end
  end
end

function requireFiles(files)
  for _, file in ipairs(files) do
    local file = file:sub(1, -5)
    local class_name = file:match(".*/(.+)$")
    _G[class_name] = require(file)
  end
end

function UUID()
  local fn = function(x)
    local r = love.math.random(16) - 1
    r = (x == "x") and (r + 1) or (r % 4) + 9
    return ("0123456789abcdef"):sub(r, r)
  end
  return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end

function pinspect(...)
  print(inspect(...))
end

function distance(x1, y1, x2, y2)
  return math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))
end

function resize(s)
  sx, sy = s, s
  love.window.setMode(sx * gw, sy * gh)
end

function random(min, max)
  local min, max = min or 0, max or 1
  return (min > max and (love.math.random() * (min - max) + max)) or (love.math.random() * (max - min) + min)
end

function countAll(f)
  local seen = {}
  local count_table
  count_table = function(t)
    if seen[t] then return end
    f(t)
    seen[t] = true
    for k, v in pairs(t) do
      if type(v) == "table" then
        count_table(v)
      elseif type(v) == "userdata" then
        f(v)
      end
    end
  end
  count_table(_G)
end

function typeCount()
  local counts = {}
  local enumerate = function(o)
    local t = typeName(o)
    counts[t] = (counts[t] or 0) + 1
  end
  countAll(enumerate)
  return counts
end

global_type_table = nil
function typeName(o)
  if global_type_table == nil then
    global_type_table = {}
    for k, v in pairs(_G) do
      global_type_table[v] = k
    end
    global_type_table[0] = "table"
  end
  return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function pushRotate(x, y, r)
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(r or 0)
  love.graphics.translate(-x, -y)
end

function pushRotateScale(x, y, r, sx, sy)
  love.graphics.push()
  love.graphics.translate(x, y)
  love.graphics.rotate(r or 0)
  love.graphics.scale(sx or 1, sy or sx or 1)
  love.graphics.translate(-x, -y)
end

--function addRoom(room_type, room_name, ...)
--    local room = _G[room_type](room_name, ...)
--    rooms[room_name] = room
--    return room
--end

--function gotoRoom(room_type, room_name, ...)
--    if current_room and rooms[room_name] then
--        if current_room.deactivate then current_room:deactivate() end
--        current_room = rooms[room_name]
--        if current_room.activate then current_room:activate() end
--    else
--        current_room = addRoom(room_type, room_name, ...)
--    end
--end

function gotoRoom(room_type, ...)
  current_room = _G[room_type](...)
end

function slow(amount, duration)
  slow_amount = amount
  timer:tween(duration, _G, { slow_amount = 1 }, 'in-out-cubic', nil, 'slow')
end

function flash(frames)
  flash_frames = frames
end

function flashS(seconds)
  flash_seconds = seconds
end

function table.pack(...)
  return { n = select("#", ...), ... }
end

function table.random(t)
  return t[love.math.random(1, #t)]
end

function table.shallow_copy(t)
  local nt = {}
  for k, v in pairs(t) do
    nt[k] = v
  end
  return nt
end

function table.keys(t)
  local c = 1
  local keys = {}
  for k, _ in pairs(t) do
    keys[c] = k
    c = c + 1
  end
  return keys
end

function table.randomp(t)
  local k = table.random(table.keys(t))
  return k, t[k]
end

function table.merge(t1, t2)
  local new_table = {}
  for k, v in pairs(t1) do new_table[k] = v end
  for k, v in pairs(t2) do new_table[k] = v end
  return new_table
end

function rectangle_overlap(ax1, ax2, ay1, ay2, bx1, bx2, by1, by2)
  return ax1 < bx2 and ax2 > bx1 and ay1 > by2 and ay2 < by1
end

function createIrregularPolygon(size, point_amount)
  local point_amount = point_amount or 8
  local points = {}
  for i = 1, point_amount do
    local angle_interval = 2 * math.pi / point_amount
    local distance = size + random(-size / 4, size / 4)
    local angle = (i - 1) * angle_interval + random(-angle_interval / 4, angle_interval / 4)
    table.insert(points, distance * math.cos(angle))
    table.insert(points, distance * math.sin(angle))
  end
  return points
end

function chanceList(...)
  return {
    chance_list = {},
    chance_definitions = { ... },
    next = function(self)
      if #self.chance_list == 0 then
        for _, chance_definition in ipairs(self.chance_definitions) do
          for i = 1, chance_definition[2] do
            table.insert(self.chance_list, chance_definition[1])
          end
        end
      end
      return table.remove(self.chance_list, love.math.random(1, #self.chance_list))
    end
  }
end
