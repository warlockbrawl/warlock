AIController = class()
AIController.think_interval = 0.2
AIController.danger_scale = 1000
AIController.danger_min_dst = 2000
AIController.danger_min_cos_dst = -0.1
AIController.danger_dodge_thresh = 3
AIController.danger_dodge_delta = 10

function AIController:init(def)
    self.player = def.player
    self.pawn = self.player.pawn
    self.think_interval = def.think_interval or AIController.think_interval

    -- Find fireball and scourge
    for i = 0, 5 do
        local item = self.pawn.unit:GetItemInSlot(i)
        
        if item then
            local item_name = item:GetAbilityName()

            if item_name == "item_warlock_fireball1" then
                print("Found fireball in slot " .. tostring(i))
                self.fireball = item
            end

            if item_name == "item_warlock_scourge1" or item_name == "item_warlock_scourge2" or item_name == "item_warlock_scourge3" then
                print("Found scourge in slot " .. tostring(i))
                self.scourge = item
            end
        end
    end

    self.time = 0
    self.scourge_end_time = 0
    self.spell_end_time = 0
    self.next_buy_time = def.buy_delay or 0
    self.next_target_time = 0

    self:chooseTargetPoint()

    -- Add think task
    self.ai_task = GAME:addTask {
        id = "ai controller " .. tostring(self.player.id),
        period = self.think_interval,
        func = function()
            self:think(self.think_interval)
        end
    }

    self.purchasable_target_spells = {
        { 1, 2, 3, 4 },
        { 8, 9, 10, 11 },
        { 13, 14, 15 },
        { 19, 20, 21, 22, 23, 24 }
    }

    self.purchasable_escape_spells = {
        5, 6, 7
    }

    self.escape_spell = nil

    self.projectile_spells = { { name = "Fireball", ability_name = "item_warlock_fireball1" } }

    -- Find existing abilities
    for i = 0, 5 do
        local abil = self.pawn.unit:GetAbilityByIndex(i)

        if abil then
            local abil_name = abil:GetAbilityName()
            local found_abil = false
            print("Checking for ability " .. abil_name)

            -- Special case for windwalk, remove E column
            if abil_name == "warlock_windwalk" then
                for j = 1, #self.purchasable_target_spells do
                    if Shop.SPELL_DEFS[self.purchasable_target_spells[j][1]].name == "Splitter" then
                        table.remove(self.purchasable_target_spells, j)
                        print("Handled windwalk")
                        found_abil = true
                        break
                    end
                end
            end

            if not found_abil then
                -- Search in target spells
                for j = 1, #self.purchasable_target_spells do
                    local spells = self.purchasable_target_spells[j]
                    for k = 1, #spells do
                        if Shop.SPELL_DEFS[spells[k]].ability_name == abil_name then
                            table.insert(self.projectile_spells, Shop.SPELL_DEFS[spells[k]]) -- Add found spell to available spell list
                            table.remove(self.purchasable_target_spells, j) -- Remove column from purchasable spells
                            found_abil = true
                            print("Found")
                            break
                        end
                    end

                    if found_abil then
                        break
                    end
                end

                -- Search in escape spells if not yet found
                if not found_abil then
                    for j = 1, #self.purchasable_escape_spells do
                        if Shop.SPELL_DEFS[self.purchasable_escape_spells[j]].ability_name == abil_name then
                            self.escape_spell = Shop.SPELL_DEFS[self.purchasable_escape_spells[j]]
                            self.purchasable_escape_spells = { }
                            print("Found")
                            break
                        end
                    end
                end
            end
        end
    end
end

function AIController:destroy()
    self.ai_task:cancel()
    GAME.ai_controllers[self.player] = nil
end

-- Finds a point to move to when nothing important needs to be done
function AIController:chooseTargetPoint()
    -- Add delay before randomly choosing the next target point (other ways will still work)
    local time_delay = 0
    
    -- Chance to move towards target
    if self.target_pawn and self.target_pawn.owner:isAlive() and math.random(0, 10) == 0 then
        local angle = math.random(0, 360)
        self.target = self.target_pawn.location + math.random(0, 200) * Vector(math.cos(angle), math.sin(angle), 0)
        time_delay = math.random(0.4, 0.8)
    -- Choose random point on platform
    else
        local angle = math.random(0, 360)
        self.target = math.random(0, 0.3 * GAME.arena.current_layer * GAME.arena.ARENA_TILE_SIZE) * Vector(math.cos(angle), math.sin(angle), 0)
        self.target.z = Config.GAME_Z
        time_delay = math.random(0.2, 0.4)
    end

    self.next_target_time = self.next_target_time + time_delay
end

-- Gets the closest enemy
function AIController:getClosestEnemyPawn()
    local min_dist_sq = 99999999
	local min_dir
	local min_pawn = nil
	
	-- Get closest enemy or allied pawn
	for pawn, _ in pairs(GAME.pawns) do
		if pawn.owner:getAlliance(self.player) == Player.ALLIANCE_ENEMY then
			local dir = pawn.location - self.pawn.location
			local dist_sq = dir:Dot(dir)
			if dist_sq < min_dist_sq then
				min_dist_sq = dist_sq
				min_dir = dir
				min_pawn = pawn
			end
		end
	end

    return min_pawn
end

-- Returns the direction needed to hit target
function AIController:getPredictedDir(target, speed)
	local delta = self.pawn.location - target.location
	local a = delta:Dot(target.velocity)
	local b = target.velocity:Length()
	b = b * b - speed * speed
	local c = delta:Length()
	c = c * c

	local d = a * a - b * c

	-- No solution, return direct path
	if(d < 0) then
		return (-delta):Normalized()
	end

	d = math.sqrt(d)

	local t_a = (a + d) / b
	local t_b = (a - d) / b
	local t = 0

	if(t_a < 0 and t_b < 0) then
		-- No solution, return direct path
		return (-delta):Normalized()
	elseif(t_a >= 0) then
		t = t_a
	else
		t = t_b
	end

	return (target.velocity * t - delta) / (speed * t)
end

function AIController:getDanger(loc)
    local danger = 0

    -- Get all enemy projectiles
    local projectiles = GAME:filterActors(function(actor)
        return actor:instanceof(Projectile) and actor.instigator.owner:getAlliance(self.pawn.owner) == Player.ALLIANCE_ENEMY
    end)

    -- Get closest enemy projectile
    for _, proj in pairs(projectiles) do
        local offset = loc - proj.location
        local dst = offset:Length()

        -- Ignore projectiles that are moving away
        -- Ignore projectiles that are too far away
        if proj.velocity:Normalized():Dot((loc - proj.location):Normalized()) >= self.danger_min_cos_dst and 
            dst <= self.danger_min_dst then

            -- Calculate the line distance to the projectile's path
            local proj_new_loc = proj.location + proj.velocity
            local delta = proj_new_loc - proj.location
            local line_dst = math.abs(delta.y * loc.x - delta.x * loc.y + proj_new_loc.x * proj.location.y - proj_new_loc.y * proj.location.x) / delta:Length()

            danger = danger + self.danger_scale / (1.0 + line_dst)
        end
    end

    return danger
end

function AIController:getDodgeDirection()
    -- Do a first order approximation of the danger shape and
    -- walk to where it gets smaller
    local danger_self = self:getDanger(self.pawn.location)
    local danger_right = self:getDanger(self.pawn.location + Vector(1, 0, 0) * self.danger_dodge_delta)
    local danger_up = self:getDanger(self.pawn.location + Vector(0, 1, 0) * self.danger_dodge_delta)

    local dir = Vector(danger_self - danger_right, danger_self - danger_up)

    if dir.x == 0 and dir.y == 0 then
        return Vector(0, 0, 0)
    end

    return dir:Normalized()
end

function AIController:buyRandomSpell()
    -- 50 percent chance to buy an R spell if not owning one already
    if not self.escape_spell and math.random(0, 1) == 0 then
        local spell_number = math.random(1, #self.purchasable_escape_spells)
        local spell_index = self.purchasable_escape_spells[spell_number]
        local spell_def = Shop.SPELL_DEFS[spell_index]

        if GAME.shop:buySpell(self.pawn.owner, spell_index) then
            self.escape_spell = spell_def
            self.purchasable_escape_spells = { }
        end
    else
        if #self.purchasable_target_spells == 0 then
            return
        end

        local column = math.random(1, #self.purchasable_target_spells)
        local spells = table.remove(self.purchasable_target_spells, column)
    
        local spell_number = math.random(1, #spells)
        local spell_index = spells[spell_number]
        local spell_def = Shop.SPELL_DEFS[spell_index]

        if GAME.shop:buySpell(self.pawn.owner, spell_index) then
            table.insert(self.projectile_spells, spell_def)
        end
    end
    print("Purchased a spell")
end

-- Casts a random projectile spell, returns false if nothing was cast
function AIController:castRandomProjectileSpell()
    local spell_def = self.projectile_spells[math.random(1, #self.projectile_spells)]

    local spell_name = spell_def.ability_name

    -- Special case for fireball since it's an item and not an ability
    if spell_def.name == "Fireball" then
        spell = self.fireball
    else
        spell = self.pawn.unit:FindAbilityByName(spell_name)
    end

    if not spell or spell:IsNull() then
        print("Could not find spell " .. spell_name)
        return false
    end

    local spell_class = Spell.spells[spell_name]

    if not spell:IsFullyCastable() then
        return false
    end

    local target_mode = math.random(0, 2) -- 33 percent chance to have prediction
    local spell_loc
    
    if target_mode == 0 and spell_class.projectile_speed then
        spell_loc = self.pawn.location + 500 * self:getPredictedDir(self.target_pawn, spell_class.projectile_speed)
    else
        spell_loc = self.target_pawn.location
    end

    self.pawn.unit:CastAbilityOnPosition(spell_loc, spell, self.player.id)

    self.spell_end_time = self.time + 0.3

    return true
end

function AIController:castEscapeSpell()
    local spell = self.pawn.unit:FindAbilityByName(self.escape_spell.ability_name)

    if spell and not spell:IsNull() and spell:IsFullyCastable() then
        self.pawn.unit:CastAbilityOnPosition(self.target, spell, self.pawn.owner.id)
    end
end

function AIController:think(dt)
    if self.time > self.next_buy_time and self.pawn.unit and (not GAME.combat or not self.pawn.owner:isAlive()) and self.player.cash >= 15 then
        self.next_buy_time = self.next_buy_time + 40
        self:buyRandomSpell()
        return
    end

    if self.pawn.unit and self.pawn.unit:IsAlive() then
        local closest_pawn = self:getClosestEnemyPawn()

        -- Use escape spell when in lava and choose new target point
        if self.escape_spell and not GAME.arena:isLocationSafe(self.pawn.location) and math.random(0, 2) == 0 then
            self:castEscapeSpell()
            self:chooseTargetPoint()
        end

        -- Choose new target pawn if target is nil or target is dead or target is allied or randomly
        if not self.target_pawn or not self.target_pawn.owner:isAlive() or self.target_pawn.owner:getAlliance(self.pawn.owner) ~= Player.ALLIANCE_ENEMY or math.random(0, 4) == 0 then
            self.target_pawn = closest_pawn
        end

        -- Choose new target point
        if (self.pawn.location - self.target):Length() < 100 or self.time > self.next_target_time then
            self:chooseTargetPoint()
        end

        -- Do nothing while a spell is being cast
        if self.time < self.spell_end_time then
            self.time = self.time + dt
            return
        end

        local danger = self:getDanger(self.pawn.location)

        -- Do nothing while scourging
        if self.time < self.scourge_end_time then
            local do_nothing = true

            if closest_pawn then
                local dist = (self.pawn.location - closest_pawn.location):Length()

                -- Chance to cancel if enemy is too far away
                -- Always cancel if the danger is too high to try to dodge
                if danger >= self.danger_dodge_thresh or (dist > 250 and math.random(0, 2) == 0) then
                    self.pawn.unit:Stop()
                    self.scourge_end_time = 0
                    do_nothing = false
                end
            end

            -- Exit if scourge was not cancelled
            if do_nothing then
                self.time = self.time + dt
                return
            end
        end

        local try_more = true

        -- Dodge if danger is over threshold
        if try_more and danger >= self.danger_dodge_thresh then
            local dodge_loc = self.pawn.location + 5000 * self:getDodgeDirection()
            self.pawn.unit:MoveToPosition(dodge_loc)
            try_more = false
        end

        -- Cast scourge on close pawns
        if try_more and closest_pawn and self.scourge:IsFullyCastable() then
            local dist = (self.pawn.location - closest_pawn.location):Length()
            
            if dist < 300 and math.random(0, 5) == 0 then
                self.pawn.unit:CastAbilityNoTarget(self.scourge, self.player.id)
                try_more = false
                self.scourge_end_time = self.time + 1.0
            end
        end

        -- Cast projectiles randomly
        if try_more and self.target_pawn and math.random(0, 4) == 0 then
            try_more = not self:castRandomProjectileSpell()
        end

        -- Move to target point
        if try_more then
            self.pawn.unit:MoveToPosition(self.target)
            try_more = false
        end
    end

    -- Increment time
    self.time = self.time + dt
end


--[[-------------------------------

          Game Interface

-------------------------------]]--

-- Adds an AI to an existing player
function Game:addPlayerAI(player, def)
    def = def or {}
    def.player = player

    if player == nil then
        err("Player was nil in addPlayerAI")
        return
    end

    if self.ai_controllers[player] then
        err("AI for player already existed in addPlayerAI")
        return
    end

    local ai_controller = AIController:new(def)

    self.ai_controllers[player] = ai_controller
end

-- Removes an AI from a player if any
function Game:removePlayerAI(player)
    if self.ai_controllers[player] then
        self.ai_controllers[player]:destroy()
    end
end

-- Adds a new player bot
function Game:addBot(think_interval)
    local player_count = PlayerResource:GetPlayerCount()

    print("Player count:", player_count)

    if GAME.player_count < 10 and player_count < 10 then
        Tutorial:AddBot("npc_dota_hero_warlock", "npc_dota_hero_warlock", "npc_dota_hero_warlock", false)

        -- Find newly created player
        for i = 0, DOTA_MAX_PLAYERS do
            local player_ent = PlayerResource:GetPlayer(i)

            -- Check if the player is a bot and doesnt have a hero yet (sometimes they automatically get a hero while still in selection)
            if player_ent and not GAME.players[i] and PlayerResource:IsFakeClient(i) then
                print("Set AI Def for AI with player id", i)
                player_ent.ai_def = { think_interval = think_interval }

                if not PlayerResource:HasSelectedHero(i) then
                    print("Created hero for AI with player id", i)
                    CreateHeroForPlayer("npc_dota_hero_warlock", player_ent)
                end
            end
        end
    end
end
