local EnhancedTimer = Object:extend()
local Timer = require 'libraries/hump/timer'

function EnhancedTimer:new()
    self.timer = Timer()
    self.tags = {}
end

function EnhancedTimer:update(dt)
    if self.timer then self.timer:update(dt) end
end

function EnhancedTimer:during(delay, func, after, tag)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:during(delay, func, after)
        return self.tags[tag]
    else
        return self.timer:during(delay, func, after)
    end
end

function EnhancedTimer:after(delay, func, tag)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:after(delay, func)
        return self.tags[tag]
    else
        return self.timer:after(delay, func)
    end
end

function EnhancedTimer:every(delay, func, count, tag)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:every(delay, func, count)
        return self.tags[tag]
    else
        return self.timer:every(delay, func, count)
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

function EnhancedTimer:tween(duration, subject, target, method, after, tag)
    if type(tag) == 'string' then
        self:cancel(tag)
        self.tags[tag] = self.timer:tween(duration, subject, target, method, after)
        return self.tags[tag]
    else
        return self.timer:tween(duration, subject, target, method, after)
    end
end

function EnhancedTimer:destroy()
    self.timer:clear()
    self.timer = nil
    self.tags = {}
end


return EnhancedTimer
