NNAI = class()

function NNAI:init(def)
    self.player = def.player
    self.pawn = self.player.pawn

    self.think_interval = def.think_interval

    -- Find fireball and scourge
    for i = 0, 5 do
        local item = self.pawn.unit:GetItemInSlot(i)
        
        if item then
            local item_name = item:GetAbilityName()

            if item_name == "item_warlock_fireball1" then
                log("Found fireball in slot " .. tostring(i))
                self.fireball = item
            end

            if item_name == "item_warlock_scourge1" or item_name == "item_warlock_scourge2" or item_name == "item_warlock_scourge3" then
                log("Found scourge in slot " .. tostring(i))
                self.scourge = item
            end
        end
    end

    self.learner = QLearner:new(17, 11, function(os, ns)
        local r = 0

        local hp_diff = ns[1][7] - os[1][7]
        local enemy_hp_diff = ns[1][16] - os[1][16]
        local enemy_kb_diff = ns[1][17] - os[1][17]

        if hp_diff < 0 then
            r = r + hp_diff
        end

        if enemy_hp_diff < 0 then
            --r = r - 10 * enemy_hp_diff
        end

        if enemy_kb_diff > 0 then
            --r = r + 10 * enemy_kb_diff
        end

        if self.pawn.on_lava then
            local walk_dir = Vector(ns[1][5], ns[1][6], 0):Normalized()
            local center_dir = Vector(ns[1][1], ns[1][2], 0):Normalized()

            r = r - (walk_dir:Dot(center_dir) + 1) * self.think_interval
        end

        r = r + 0.1 * self.think_interval

        return r
    end)

    -- Add think task
    self.ai_task = GAME:addTask {
        id = "nnai controller " .. tostring(self.player.id),
        period = self.think_interval,
        func = function()
            self:think(self.think_interval)
        end
    }

    print("NNAI created")
end

function NNAI:destroy()
    GAME.ai_controllers[self.player] = nil
    self.ai_task:cancel()
end

function NNAI:getState()
    local closest_enemy = nil
    local closest_enemy_dst = 1000000
    for pawn, _ in pairs(GAME.pawns) do
        if pawn.owner:getAlliance(self.player) == Player.ALLIANCE_ENEMY then
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

    state = Matrix:new(1, 16)
    state[1][1] = self.pawn.location.x / 1000.0
    state[1][2] = self.pawn.location.y / 1000.0
    state[1][3] = self.pawn.velocity.x / 1000.0
    state[1][4] = self.pawn.velocity.y / 1000.0
    state[1][5] = self.pawn.walk_velocity.x / 1000.0
    state[1][6] = self.pawn.walk_velocity.y / 1000.0
    state[1][7] = self.pawn.health / 1000.0
    state[1][8] = self.pawn.unit:GetMana() / 1000.0
    state[1][9] = self.fireball:GetCooldownTimeRemaining() / 4.8
    state[1][10] = self.scourge:GetCooldownTimeRemaining() / 3.0
    state[1][11] = GAME.arena.current_layer * 100 / 1000.0
    state[1][12] = closest_enemy and closest_enemy.location.x / 1000.0 or 0
    state[1][13] = closest_enemy and closest_enemy.location.y / 1000.0 or 0
    state[1][14] = closest_enemy and closest_enemy.velocity.x / 1000.0 or 0
    state[1][15] = closest_enemy and closest_enemy.velocity.y / 1000.0 or 0
    state[1][16] = closest_enemy and closest_enemy.health / 1000.0 or 0
    state[1][17] = closest_enemy and closest_enemy.unit:GetMana() / 1000.0 or 0

    return state
end

function NNAI:executeAction(action_id)
    if action_id >= 1 and action_id <= 4 then
        local angle = math.rad((action_id-1) * 90)
        local target = self.pawn.location + 1000 * Vector(math.cos(angle), math.sin(angle), 0)

        self.pawn.unit:MoveToPosition(target)
    elseif action_id >= 5 and action_id <= 8 then
        local angle = math.rad((action_id-5) * 90)
        local target = self.pawn.location + 1000 * Vector(math.cos(angle), math.sin(angle), 0)
        self.cast_time = GAME:time() + 0.3
        self.pawn.unit:CastAbilityOnPosition(target, self.fireball, self.player.id)
    elseif action_id == 9 then
        self.cast_time = GAME:time() + 1.0
        self.pawn.unit:CastAbilityNoTarget(self.scourge, self.player.id)
    elseif action_id == 10 then
        self.pawn.unit:Stop()
    elseif action_id == 11 then
        -- Do nothing
    else
        warning("Unknown action executed: " .. tostring(action_id))
    end
end

function  NNAI:think()
    if not self.pawn or not self.player:isAlive() or not GAME.combat then
        self.initialized = false
        return
    end

    if self.cast_time and self.cast_time > GAME:time() then
        return
    end

    local state = self:getState()

    if self.initialized then
        self.learner:update(state)
    end

    local action = self.learner:getAction(state)
    self:executeAction(action)

    self.initialized = true
end
