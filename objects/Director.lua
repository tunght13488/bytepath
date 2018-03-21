local Director = Object:extend()

function Director:new(stage)
    self.stage = stage

    self.timer = Timer()

    self.difficulty = 1
    self.round_duration = 22
    self.round_timer = 0

    self.difficulty_to_points = {}
    self.difficulty_to_points[1] = 16
    for i = 2, 1024, 4 do
        self.difficulty_to_points[i] = self.difficulty_to_points[i - 1] + 8
        self.difficulty_to_points[i + 1] = self.difficulty_to_points[i]
        self.difficulty_to_points[i + 2] = math.floor(self.difficulty_to_points[i + 1] / 1.5)
        self.difficulty_to_points[i + 3] = math.floor(self.difficulty_to_points[i + 2] * 2)
    end

    self.enemy_to_points = {
        ['Rock'] = 1,
        ['Shooter'] = 2,
    }

    self.enemy_spawn_chances = {
        [1] = chanceList({ 'Rock', 1 }),
        [2] = chanceList({ 'Rock', 8 }, { 'Shooter', 4 }),
        [3] = chanceList({ 'Rock', 8 }, { 'Shooter', 8 }),
        [4] = chanceList({ 'Rock', 4 }, { 'Shooter', 8 }),
    }

    for i = 5, 1024 do
        self.enemy_spawn_chances[i] = chanceList({ 'Rock', love.math.random(2, 12) },
            { 'Shooter', love.math.random(2, 12) })
    end

    self.resource_spawn_chances = chanceList({ 'Boost', 28 * self.stage.player.spawn_boost_chance_multiplier },
        { 'HP', 14 * self.stage.player.spawn_hp_chance_multiplier },
        { 'SP', 58 * self.stage.player.spawn_sp_chance_multiplier })
    self.resource_duration = 16
    self.resource_timer = 0

    self.attack_duration = 30
    self.attack_timer = 0

    self:setEnemySpawnsForThisRound()
    self:spawnResource()
    self:spawnAttack()
end

function Director:update(dt)
    self.timer:update(dt)
    self.round_timer = self.round_timer + dt
    if self.round_timer > self.round_duration / self.stage.player.enemy_spawn_rate_multiplier then
        self.round_timer = 0
        self.difficulty = self.difficulty + 1
        self:setEnemySpawnsForThisRound()
    end
    self.resource_timer = self.resource_timer + dt
    if self.resource_timer > self.resource_duration then
        self.resource_timer = 0
        self:spawnResource()
    end
    self.attack_timer = self.attack_timer + dt
    if self.attack_timer > self.attack_duration then
        self.attack_timer = 0
        self:spawnAttack()
    end
end

function Director:setEnemySpawnsForThisRound()
    local points = self.difficulty_to_points[self.difficulty]

    -- Find enemies
    local enemy_list = {}
    while points > 0 do
        local enemy = self.enemy_spawn_chances[self.difficulty]:next()
        points = points - self.enemy_to_points[enemy]
        table.insert(enemy_list, enemy)
    end

    -- Find enemies spawn times
    local enemy_spawn_times = {}
    for i = 1, #enemy_list do
        enemy_spawn_times[i] = random(0, self.round_duration)
    end
    table.sort(enemy_spawn_times, function(a, b) return a < b end)

    -- Set spawn enemy timer
    for i = 1, #enemy_spawn_times do
        self.timer:after(enemy_spawn_times[i], function()
            self.stage.area:addGameObject(enemy_list[i])
        end)
    end
end

function Director:spawnResource()
    local resource = self.resource_spawn_chances:next()
    self.stage.area:addGameObject(resource)
    if resource == 'HP' and self.stage.player.chances.spawn_double_hp_chance:next() then
        self.stage.area:addGameObject(resource)
    elseif resource == 'SP' and self.stage.player.chances.spawn_double_sp_chance:next() then
        self.stage.area:addGameObject(resource)
    end
end

function Director:spawnAttack()
    self.stage.area:addGameObject('Attack')
end

return Director
