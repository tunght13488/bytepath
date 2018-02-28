local GameObject = require "objects/GameObject"
local Ammo = require "objects/Ammo"
local Boost = require "objects/Boost"
local HP = require "objects/HP"
local Stat = require "objects/Stat"
local Player = GameObject:extend()

function Player:new(area, x, y, options)
    Player.super.new(self, area, x, y, options)

    self.x, self.y = x, y
    self.w, self.h = 12, 12
    self.depth = 10
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.w)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Player')

    -- Movement
    self.r = -math.pi / 2
    self.rv = 1.66 * math.pi
    self.v = 0
    self.base_max_v = 100
    self.max_v = self.base_max_v
    self.a = 100

    -- Ammo
    self.max_ammo = 100
    self.ammo = self.max_ammo
    self.shoot_timer = 0
    self.shoot_cooldown = 0.24
    self:setAttack('Neutral')

    -- Boost
    self.max_boost = 100
    self.boost = self.max_boost
    self.boost_recovery_spped = 10
    self.boost_consumption_speed = 50
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2

    -- HP
    self.max_hp = 100
    self.hp = self.max_hp
    self.invincible = false
    self.invincible_timer = 0
    self.invincible_cooldown = 2
    self.invisible = false
    self.invisible_timer = 0

    -- Cycle
    self.cycle = 5
    self.cycle_timer = 0

    -- Multipliers
    self.hp_multiplier = 1
    self.ammo_multiplier = 1
    self.boost_multiplier = 1
    self.aspd_multiplier = Stat(1)

    -- Flats
    self.flat_hp = 0
    self.flat_ammo = 0
    self.flat_boost = 0
    self.ammo_gain = 0

    -- Chances
    self.launch_homing_projectile_on_ammo_pickup_chance = 0
    self.regain_hp_on_ammo_pickup_chance  = 0
    self.regain_hp_on_sp_pickup_chance = 0
    self.spawn_haste_area_on_hp_pickup_chance = 0
    self.spawn_haste_area_on_sp_pickup_chance = 0
    self.spawn_sp_on_cycle_chance = 0
    self.barrage_on_kill_chance = 0
    self.spawn_hp_on_cycle_chance = 0
    self.regain_hp_on_cycle_chance = 0
    self.regain_full_ammo_on_cycle_chance = 0
    self.change_attack_on_cycle_chance = 100
    self.spawn_haste_area_on_cycle_chance = 100
    self.barrage_on_cycle_chance = 100
    self.launch_homing_projectile_on_cycle_chance = 100
    self.regain_ammo_on_kill_chance = 100
    self.launch_homing_projectile_on_kill_chance = 100
    self.regain_boost_on_kill_chance = 100
    self.spawn_boost_on_kill_chance = 100
    self.gain_aspd_boost_on_kill_chance = 100

    self.ship = 'Fighter'
    self.polygons = {}

    if self.ship == 'Fighter' then
        self.polygons[1] = {
            self.w, 0, -- 1
            self.w / 2, -self.w / 2, -- 2
            -self.w / 2, -self.w / 2, -- 3
            -self.w, 0, -- 4
            -self.w / 2, self.w / 2, -- 5
            self.w / 2, self.w / 2, -- 6
        }
        self.polygons[2] = {
            self.w / 2, -self.w / 2, -- 7
            0, -self.w, -- 8
            -self.w - self.w / 2, -self.w, -- 9
            -3 * self.w / 4, -self.w / 4, -- 10
            -self.w / 2, -self.w / 2, -- 11
        }
        self.polygons[3] = {
            self.w / 2, self.w / 2, -- 12
            -self.w / 2, self.w / 2, -- 13
            -3 * self.w / 4, self.w / 4, -- 14
            -self.w - self.w / 2, self.w, -- 15
            0, self.w, -- 16
        }
    end

    -- Trail
    self.trail_color = skill_point_color
    self.timer:every(0.01, function()
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle',
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r - math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r - math.pi / 2),
                { parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color })
            self.area:addGameObject('TrailParticle',
                self.x - 0.9 * self.w * math.cos(self.r) + 0.2 * self.w * math.cos(self.r + math.pi / 2),
                self.y - 0.9 * self.w * math.sin(self.r) + 0.2 * self.w * math.sin(self.r + math.pi / 2),
                { parent = self, r = random(2, 4), d = random(0.15, 0.25), color = self.trail_color })
        end
    end)

    -- treeToPlayer(self)
    self:setStats()
    self:generateChances()
end

function Player:update(dt)
    Player.super.update(self, dt)

    -- Cycle
    self.cycle_timer = self.cycle_timer + dt
    if self.cycle_timer > self.cycle then
        self.cycle_timer = 0
        self:tick()
    end

    -- Turn
    if input:down('left') then self.r = self.r - self.rv * dt end
    if input:down('right') then self.r = self.r + self.rv * dt end

    -- Boost
    self.max_v = self.base_max_v
    self.boost = math.min(self.boost + self.boost_recovery_spped * dt, self.max_boost)
    self.boost_timer = self.boost_timer + dt
    if self.boost_timer > self.boost_cooldown then self.can_boost = true end
    self.boosting = false
    if input:down('up') and self.boost > 1 and self.can_boost then
        self.boosting = true
        self.boost = self.boost - self.boost_consumption_speed * dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
        end
        self.max_v = 1.5 * self.base_max_v
    end
    if input:down('down') and self.boost > 1 and self.can_boost then
        self.boosting = true
        self.boost = self.boost - self.boost_consumption_speed * dt
        self.max_v = 0.5 * self.base_max_v
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
        end
    end

    -- Toggle homing attack
    if input:released('toggle_homing_attack') then
        if self.attack == 'Neutral' then
            self:setAttack('Homing')
        else
            self:setAttack('Neutral')
        end
    end

    -- Toggle movement
    if input:released('toggle_movement') then
        if self.a == 100 then
            self.a = 0
            self.v = 0
        else
            self.a = 100
        end
    end

    -- Trail
    self.trail_color = skill_point_color
    if self.boosting then
        self.trail_color = boost_color
    end

    -- Move
    self.v = math.min(self.v + self.a * dt, self.max_v)
    self.collider:setLinearVelocity(self.v * math.cos(self.r), self.v * math.sin(self.r))

    -- Die if hit boundaries
    if self.x < 0 then self:die() end
    if self.y < 0 then self:die() end
    if self.x > gw then self:die() end
    if self.y > gh then self:die() end

    -- Collision
    if self.collider:enter('Collectable') then
        local collision_data = self.collider:getEnterCollisionData('Collectable')
        local object = collision_data.collider:getObject()
        if object:is(Ammo) then
            current_room.score = current_room.score + 50
            self:addAmmo(5 + self.ammo_gain)
            self:onAmmoPickup()
            object:die()
        elseif object:is(Boost) then
            current_room.score = current_room.score + 150
            self:addBoost(25)
            self:onBoostPickup()
            object:die()
        elseif object:is(HP) then
            self:addHP(25)
            self:onHPPickup()
            object:die()
        elseif object:is(SP) then
            skill_points = skill_points + 1
            current_room.score = current_room.score + 250
            self:onSPPickup()
            object:die()
        elseif object:is(Attack) then
            current_room.score = current_room.score + 50
            self:setAttack(object.attack)
            object:die()
        end
    elseif self.collider:enter('Enemy') then
        self:hit(30)
    end

    if self.inside_haste_area then self.aspd_multiplier:decrease(100) end
    if self.aspd_boosting then self.aspd_multiplier:decrease(100) end
    self.aspd_multiplier:update(dt)

    -- Shoot
    self.shoot_timer = self.shoot_timer + dt
    if self.shoot_timer > self.shoot_cooldown * self.aspd_multiplier.value then
        self.shoot_timer = 0
        self:shoot()
    end

    -- Blink on invincible
    if self.invincible then
        self.invincible_timer = self.invincible_timer + dt
        if self.invincible_timer > self.invincible_cooldown then
            self.invincible = false
            self.invincible_timer = 0
        end
        self.invisible_timer = self.invisible_timer + dt
        if self.invisible_timer > 0.04 then
            self.invisible = not self.invisible
            self.invisible_timer = 0
        end
    else
        self.invisible = false
    end
end

function Player:draw()
    ShootEffect.super.draw(self)
    if self.invisible then return end
    -- love.graphics.print('Player: '..self.x..', '..self.y, self.x + 15, self.y + 15)

    -- love.graphics.circle('line', self.x, self.y, self.w)
    -- love.graphics.line(self.x, self.y, self.x + 2 * self.w * math.cos(self.r), self.y + 2 * self.w * math.sin(self.r))

    pushRotate(self.x, self.y, self.r)
    love.graphics.setColor(default_color)
    for _, polygon in ipairs(self.polygons) do
        local points = fn.map(polygon, function(k, v)
            if k % 2 == 1 then
                return self.x + v
                -- return self.x + v + random(-1, 1)
            else
                return self.y + v
                -- return self.y + v + random(-1, 1)
            end
        end)
        love.graphics.polygon('line', points)
    end
    love.graphics.pop()
end

function Player:destroy()
    Player.super.destroy(self)
end

function Player:shoot()
    local d = 1.2 * self.w
    self.area:addGameObject('ShootEffect', self.x + d * math.cos(self.r), self.y + d * math.sin(self.r), { player = self, d = d })

    if self.attack == 'Neutral' then
        self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r), { r = self.r, attack = self.attack })
    elseif self.attack == 'Homing' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.r), self.y + 1.5 * d * math.sin(self.r), { r = self.r, attack = self.attack })
    elseif self.attack == 'Double' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
            { r = self.r + math.pi / 12, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
            { r = self.r - math.pi / 12, attack = self.attack })
    elseif self.attack == 'Triple' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r + math.pi / 12),
            { r = self.r + math.pi / 12, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r - math.pi / 12),
            self.y + 1.5 * d * math.sin(self.r - math.pi / 12),
            { r = self.r - math.pi / 12, attack = self.attack })
    elseif self.attack == 'Rapid' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
    elseif self.attack == 'Spread' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        local dr = random(-math.pi / 8, math.pi / 8)
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + dr),
            self.y + 1.5 * d * math.sin(self.r + dr),
            { r = self.r + dr, attack = self.attack })
    elseif self.attack == 'Back' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + math.pi),
            self.y + 1.5 * d * math.sin(self.r + math.pi),
            { r = self.r + math.pi, attack = self.attack })
    elseif self.attack == 'Side' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r),
            self.y + 1.5 * d * math.sin(self.r),
            { r = self.r, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r + math.pi / 2),
            self.y + 1.5 * d * math.sin(self.r + math.pi / 2),
            { r = self.r + math.pi / 2, attack = self.attack })
        self.area:addGameObject('Projectile',
            self.x + 1.5 * d * math.cos(self.r - math.pi / 2),
            self.y + 1.5 * d * math.sin(self.r - math.pi / 2),
            { r = self.r - math.pi / 2, attack = self.attack })
    end

    -- Fallback to Neutral if out of ammo
    if self.ammo < 0 then
        self:setAttack('Neutral')
        self.ammo = self.max_ammo
    end
end

function Player:die()
    self.dead = true
    flash(4)
    camera:shake(6, 60, 0.4)
    slow(0.15, 1)
    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
    current_room:finish()
end

function Player:tick()
    self.area:addGameObject('TickEffect', self.x, self.y, { parent = self })
    self:onCycle()
end

function Player:addAmmo(amount)
    self.ammo = math.max(math.min(self.ammo + amount, self.max_ammo), 0)
end

function Player:addBoost(amount)
    self.boost = math.max(math.min(self.boost + amount, self.max_boost), 0)
end

function Player:addHP(amount)
    self.hp = math.min(self.hp + amount, self.max_hp)
    if self.hp < 0 then
        self.hp = 0
        self:die()
    end
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo
end

function Player:hit(damage)
    if self.invincible then return end
    damage = damage or 10
    for i = 1, love.math.random(4, 8) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y, { s = 3, color = attacks[self.attack].color })
    end
    self:addHP(-damage)
    if damage >= 30 then
        self.invincible = true
        flash(3)
        camera:shake(6, 60, 0.2)
        slow(0.25, 0.5)
    else
        flash(2)
        camera:shake(6, 60, 0.1)
        slow(0.75, 0.25)
    end
end

function Player:setStats()
    self.max_hp = (self.max_hp + self.flat_hp) * self.hp_multiplier
    self.hp = self.max_hp

    self.max_ammo = (self.max_ammo + self.flat_ammo) * self.ammo_multiplier
    self.ammo = self.max_ammo

    self.max_boost = (self.max_boost + self.flat_boost) * self.boost_multiplier
    self.boost = self.max_boost
end

function Player:generateChances()
    self.chances = {}
    for k, v in pairs(self) do
        if k:find('_chance') and type(v) == 'number' then
            self.chances[k] = chanceList({ true, math.ceil(v) }, { false, 100 - math.ceil(v) })
        end
    end
end

function Player:onAmmoPickup()
    if self.chances.launch_homing_projectile_on_ammo_pickup_chance:next() then
        local d = 1.2 * self.w
        self.area:addGameObject('Projectile',
            self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
            { r = self.r, attack = 'Homing' })
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Homing Projectile!' })
    end
    if self.chances.regain_hp_on_ammo_pickup_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'HP Regain!', color = hp_color })
    end
end

function Player:onBoostPickup()
end

function Player:onHPPickup()
    if self.chances.spawn_haste_area_on_hp_pickup_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Haste Area!', color = ammo_color })
    end
end

function Player:onSPPickup()
    if self.chances.regain_hp_on_sp_pickup_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'HP Regain!', color = hp_color })
    end
    if self.chances.spawn_haste_area_on_sp_pickup_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Haste Area!', color = ammo_color })
    end
end

function Player:onCycle()
    if self.chances.spawn_sp_on_cycle_chance:next() then
        self.area:addGameObject('SP')
        self.area:addGameObject('InfoText', self.x, self.y,
            {text = 'SP Spawn!', color = skill_point_color})
    end
    if self.chances.spawn_hp_on_cycle_chance:next() then
        self.area:addGameObject('HP')
        self.area:addGameObject('InfoText', self.x, self.y,
            {text = 'HP Spawn!', color = hp_color})
    end
    if self.chances.regain_hp_on_cycle_chance:next() then
        self:addHP(25)
        self.area:addGameObject('InfoText', self.x, self.y,
            {text = 'Regain HP!', color = hp_color})
    end
    if self.chances.regain_full_ammo_on_cycle_chance:next() then
        self:addAmmo(self.max_ammo)
        self.area:addGameObject('InfoText', self.x, self.y,
            { text = 'Regain Full Ammo!', color = ammo_color })
    end
    if self.chances.change_attack_on_cycle_chance:next() then
        local attacks_without_neutral = table.shallow_copy(attacks)
        attacks_without_neutral['Neutral'] = nil
        local attack = table.randomp(attacks_without_neutral)
        self:setAttack(attack)
        self.area:addGameObject('InfoText', self.x, self.y,
            { text = 'Change Attack!', color = ammo_color })
    end
    if self.chances.spawn_haste_area_on_cycle_chance:next() then
        self.area:addGameObject('HasteArea', self.x, self.y)
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Haste Area!', color = ammo_color })
    end
    if self.chances.barrage_on_cycle_chance:next() then
        for i = 1, 8 do
            self.timer:after((i - 1) * 0.05, function()
                local random_angle = random(-math.pi / 8, math.pi / 8)
                local d = 2.2 * self.w
                self.area:addGameObject('Projectile',
                    self.x + d * math.cos(self.r + random_angle),
                    self.y + d * math.sin(self.r + random_angle),
                    { r = self.r + random_angle, attack = self.attack })
            end)
        end
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Barrage!!!' })
    end
    if self.chances.launch_homing_projectile_on_cycle_chance:next() then
        local d = 1.2 * self.w
        self.area:addGameObject('Projectile',
            self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
            { r = self.r, attack = 'Homing' })
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Homing Projectile!' })
    end
end

function Player:onKill()
    if self.chances.barrage_on_kill_chance:next() then
        for i = 1, 8 do
            self.timer:after((i-1)*0.05, function()
                local random_angle = random(-math.pi/8, math.pi/8)
                local d = 2.2*self.w
                self.area:addGameObject('Projectile', 
                    self.x + d*math.cos(self.r + random_angle), 
                    self.y + d*math.sin(self.r + random_angle), 
                    {r = self.r + random_angle, attack = self.attack})
            end)
        end
        self.area:addGameObject('InfoText', self.x, self.y, {text = 'Barrage!!!'})
    end
    if self.chances.regain_ammo_on_kill_chance:next() then
        self:addAmmo(20)
        self.area:addGameObject('InfoText', self.x, self.y,
            { text = 'Regain Ammo!', color = ammo_color })
    end
    if self.chances.launch_homing_projectile_on_kill_chance:next() then
        local d = 1.2 * self.w
        self.area:addGameObject('Projectile',
            self.x + d * math.cos(self.r), self.y + d * math.sin(self.r),
            { r = self.r, attack = 'Homing' })
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Homing Projectile!' })
    end
    if self.chances.regain_boost_on_kill_chance:next() then
        self:addBoost(40)
        self.area:addGameObject('InfoText', self.x, self.y, { text = 'Regain Boost!' })
    end
    if self.chances.spawn_boost_on_kill_chance:next() then
        self.area:addGameObject('Boost')
    end
    if self.chances.gain_aspd_boost_on_kill_chance:next() then
        self.aspd_boosting = true
        self.timer:after(4, function() self.aspd_boosting = false end)
        self.area:addGameObject('InfoText', self.x, self.y,
            { text = 'ASPD Boost!', color = ammo_color })
    end
end

return Player