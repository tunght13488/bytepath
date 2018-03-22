local EnhancedTimer = Object:extend()
local Timer = require 'libraries/hump/timer'

function EnhancedTimer:new()
    self.timer = Timer()
    self.tags = {}
end

function EnhancedTimer:update(dt)
    if self.timer then self.timer:update(dt) end
end

function EnhancedTimer:during(tag, delay, func, after)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:during(delay, func, after)
        return self.tags[tag]
    else
        return self.timer:during(tag, delay, func, after)
    end
end

function EnhancedTimer:after(tag, delay, func)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:after(delay, func)
        return self.tags[tag]
    else
        return self.timer:after(tag, delay, func)
    end
end

function EnhancedTimer:every(tag, delay, func, count)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:every(delay, func, count)
        return self.tags[tag]
    else
        return self.timer:every(tag, delay, func, count)
    end
end

function EnhancedTimer:cancel(tag)
    if tag then
        if self.tags[tag] then
            self.timer:cancel(self.tags[tag])
            self.tags[tag] = nil
        else
            self.timer:cancel(tag)
        end
    end
end

function EnhancedTimer:clear()
    self.timer:clear()
    self.tags = {}
end

function EnhancedTimer:tween(tag, duration, subject, target, method, after)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:tween(duration, subject, target, method, after)
        return self.tags[tag]
    else
        return self.timer:tween(tag, duration, subject, target, method, after)
    end
end

function EnhancedTimer:destroy()
    self.timer:clear()
    self.timer = nil
    self.tags = {}
end


return EnhancedTimer
