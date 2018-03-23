require "globals"
require "utils"
require "libraries/utf8"
Object = require "libraries/classic/classic"
Input = require "libraries/boipushy/Input"
-- Timer = require "libraries/hump/timer"
-- Timer = require "libraries/chrono/Timer"
Timer = require "libraries/EnhancedTimer"
fn = require "libraries/Moses/moses_min"
inspect = require "libraries/inspect/inspect"
require "libraries/ModifiedCamera/Shake"
Camera = require "libraries/ModifiedCamera/camera"
wf = require "libraries/windfield/windfield"
Draft = require "libraries/draft/draft"
Vector = require "libraries/hump/vector"
lurker = require "libraries/lurker/lurker"


function love.load()
  love.window.setMode(sx * gw, sy * gh)
  love.graphics.setDefaultFilter('nearest')
  -- love.graphics.setLineStyle('rough')

  -- global vars
  timer = Timer()
  input = Input()
  camera = Camera()
  draft = Draft()
  slow_amount = 1
  fonts = {
    kenpixel_16 = love.graphics.newFont('resources/fonts/ken_fonts/kenpixel.ttf', 16)
  }
  skill_points = 0

  -- load objects
  local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)

  -- init room
  rooms = {}
  current_room = nil

  -- key bindings
  input:bind('f1', function()
    print("Before collection: " .. collectgarbage("count") / 1024)
    collectgarbage()
    print("After collection: " .. collectgarbage("count") / 1024)
    print("Object count: ")
    local counts = typeCount()
    for k, v in pairs(counts) do
      print(k, v)
    end
    print("-------------------------------------")
  end)

  input:bind('f2', 'toggle_homing_attack')
  input:bind('f3', 'toggle_movement')

  input:bind('a', 'left')
  input:bind('d', 'right')
  input:bind('s', 'down')
  input:bind('w', 'up')

  -- main
  gotoRoom('Stage', 'stage_room')
end

function love.update(dt)
  lurker.update()
  timer:update(dt * slow_amount)
  camera:update(dt * slow_amount)
  if current_room then current_room:update(dt * slow_amount) end
  if flash_seconds then
    flash_seconds = flash_seconds - dt
    if flash_seconds < 0 then flash_seconds = nil end
  end

  -- main
end

function love.draw()
  if current_room then current_room:draw() end

  if flash_frames then
    flash_frames = flash_frames - 1
    if flash_frames == -1 then flash_frames = nil end
  end
  if flash_frames or flash_seconds then
    love.graphics.setColor(background_color)
    love.graphics.rectangle('fill', 0, 0, sx * gw, sy * gh)
    love.graphics.setColor(255, 255, 255)
  end
end
