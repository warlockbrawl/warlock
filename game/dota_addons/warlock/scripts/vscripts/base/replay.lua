ReplayAction = { }

for i = 0, 35 do
    ReplayAction["move" .. tostring(i)] = i
    ReplayAction["cast" .. tostring(i)] = 36 + i
end

ReplayAction.cast_scourge = 71
ReplayAction.stop = 72

ReplayRecorder = class()
ReplayRecorder.recorders = {}

function ReplayRecorder:init(pawn)
    self.pawn = pawn

    self.last_processed_tick = -1

    self.actions = {}
    self.states = {}
    self.state_count = 0

    local rand_str = tostring(math.random(1, 100000000))

    self.log_file = "warlockreplay/replay_" .. pawn.owner.name .. "_" .. rand_str .. ".json"
    self.log_count = 0
    InitLogFile(self.log_file, "")

    GAME.nativeMode:SetExecuteOrderFilter(Dynamic_Wrap(self, "orderExecuted"), self)
    GAME.nativeMode:SetThink("tick", self, "tick" .. rand_str, Config.GAME_TICK_RATE)
end

function ReplayRecorder:save()
    local text = JSON:encode({ actions = self.actions, states = self.states })
    AppendToLogFile(self.log_file, '"' .. tostring(self.log_count) .. '"\n' .. text .. ',\n')
    self.log_count = self.log_count + 1
end

function ReplayRecorder:tick()
    if self.state_count >= 1000 then
        print("Saving states and actions")
        self:save()

        self.actions = {}
        self.states = {}
        self.state_count = 0
    end

    if GAME.tick == self.last_processed_tick or GAME.mode.shop_time then
        self.last_processed_tick = GAME.tick
        return Config.GAME_TICK_RATE
    end

    if self.last_processed_tick >= 0 and GAME.tick > self.last_processed_tick + 1 then
        warning("Replay recorder skipped at least one tick", GAME.tick, self.last_processed_tick)
    end

    local fb_abil = nil
    local scourge_abil = nil

    -- Find fireball and scourge
    for i = 0, 5 do
        local item = self.pawn.unit:GetItemInSlot(i)
        
        if item then
            local item_name = item:GetAbilityName()

            if item_name == "item_warlock_fireball1" then
                fb_abil = item
            end

            if item_name == "item_warlock_scourge1" or item_name == "item_warlock_scourge2" or item_name == "item_warlock_scourge3" then
                scourge_abil = item
            end
        end
    end

    local closest_enemy = nil
    local closest_enemy_dst = 1000000
    for pawn, _ in pairs(GAME.pawns) do
        if pawn.owner:getAlliance(self.pawn.owner) == Player.ALLIANCE_ENEMY then
            if not closest_enemy then
                closest_enemy = pawn
            else
                local dst = (closest_enemy.location - self.pawn.location):Length2D()
                if dst < closest_enemy_dst then
                    closest_enemy = pawn
                    closest_enemy_dst = dst
                end
            end
        end
    end

    local state = {
        location = { x = self.pawn.location.x, y = self.pawn.location.y },
        velocity = { x = self.pawn.velocity.x, y = self.pawn.velocity.y },
        walk_velocity = { x = self.pawn.walk_velocity.x, y = self.pawn.walk_velocity.y },
        health = self.pawn.health,
        kb_points = self.pawn.unit:GetMana(),
        fireball_cd = fb_abil:GetCooldownTimeRemaining(),
        scourge_cd = scourge_abil:GetCooldownTimeRemaining(),
        arena_radius = GAME.arena.current_layer * 100,
        enemy_location = { x = 0, y = 0 },
        enemy_velocity = { x = 0, y = 0 },
        enemy_health = 0,
    }

    if closest_enemy then
        state.enemy_location = { x = closest_enemy.location.x, y = closest_enemy.location.y }
        state.enemy_velocity = { x = closest_enemy.velocity.x, y = closest_enemy.velocity.y }
        state.enemy_health = closest_enemy.health
    end

    self:addState(GAME.tick, state)

    self.last_processed_tick = GAME.tick

    return Config.GAME_TICK_RATE
end

function ReplayRecorder:getAngleIndex(angle)
    local x = angle % 10
    local discrete_angle = 0

    if x > 0 then
        discrete_angle = angle + (10 - x)
    else
        discrete_angle = angle - x
    end

    return math.floor(discrete_angle / 10) % 36
end

function ReplayRecorder:addAction(tick, action)
    self.actions[tostring(tick)] = action
end

function ReplayRecorder:addState(tick, state)
    self.states[tostring(tick)] = state
    self.state_count = self.state_count + 1
end

function ReplayRecorder:orderExecuted(event)
    if GAME.mode.shop_time then
        return true
    end

    if event.units["0"] == self.pawn.unit:entindex() then
        if event.order_type == DOTA_UNIT_ORDER_MOVE_TO_POSITION or event.order_type == DOTA_UNIT_ORDER_MOVE_TO_TARGET then
            local angle = math.deg(math.atan2(self.pawn.location.y - event.position_y, self.pawn.location.x - event.position_x))
            local angle_index = self:getAngleIndex(angle)
            self:addAction(GAME.tick, ReplayAction["move" .. tostring(angle_index)])
        end

        if event.order_type == DOTA_UNIT_ORDER_CAST_POSITION then
            local angle = math.deg(math.atan2(self.pawn.location.y - event.position_y, self.pawn.location.x - event.position_x))
            local angle_index = self:getAngleIndex(angle)
            self:addAction(GAME.tick, ReplayAction["cast" .. tostring(angle_index)])
        end

        if event.order_type == DOTA_UNIT_ORDER_STOP then
            self:addAction(GAME.tick, ReplayAction.stop)
        end

        if event.order_type == DOTA_UNIT_ORDER_CAST_NO_TARGET then
            self:addAction(GAME.tick, ReplayAction.cast_scourge)
        end
    end

    return true
end