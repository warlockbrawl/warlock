AIController = class()
AIController.think_interval = 0.2

function AIController:init(def)
    self.player = def.player
    self.pawn = self.player.pawn
    self.think_interval = def.think_interval or AIController.think_interval

    -- Find fireball and scourge
    for i = 0, 5 do
        local item = self.pawn.unit:GetItemInSlot(i)
        
        if item then
            local item_name = item:GetAbilityName()

            if item_name == "item_warlock_fireball" then
                log("Found fireball in slot " .. tostring(i))
                self.fireball = item
            end

            if item_name == "item_warlock_scourge" or item_name == "item_warlock_scourge_incarnation1" or item_name == "item_warlock_scourge_incarnation2" then
                log("Found scourge in slot " .. tostring(i))
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
        { "warlock_boomerang", "warlock_lightning", "warlock_homing" },
        { "warlock_cluster", "warlock_bouncer", "warlock_drain" },
        { "warlock_splitter", "warlock_meteor" },
        { "warlock_link", "warlock_grip", "warlock_gravity", "warlock_magnetize", "warlock_rockpillar", "warlock_warpzone" }
    }

    self.purchasable_escape_spells = {
        "warlock_teleport",
        "warlock_swap",
        "warlock_thrust"
    }

    self.escape_spell = nil

    self.projectile_spells = { "warlock_fireball" }

    -- Find existing abilities
    for i = 0, 5 do
        local abil = self.pawn.unit:GetAbilityByIndex(i)

        if abil then
            local abil_name = abil:GetAbilityName()
            local found_abil = false
            log("Checking for ability " .. abil_name)

            -- Special case for windwalk
            if abil_name == "warlock_windwalk" then
                for j = 1, #self.purchasable_target_spells do
                    if self.purchasable_target_spells[j][1] == "warlock_splitter" then
                        table.remove(self.purchasable_target_spells, j)
                        log("Handled windwalk")
                        found_abil = true
                        break
                    end
                end
            end

            
            if not found_abil then
                for j = 1, #self.purchasable_target_spells do
                    local spells = self.purchasable_target_spells[j]
                    for k = 1, #spells do
                        if spells[k] == abil_name then
                            table.insert(self.projectile_spells, abil_name)
                            table.remove(self.purchasable_target_spells, k)
                            found_abil = true
                            log("Found")
                            break
                        end
                    end

                    if found_abil then
                        break
                    end
                end

                if not found_abil then
                    for j = 1, #self.purchasable_escape_spells do
                        if self.purchasable_escape_spells[j] == abil_name then
                            self.escape_spell = abil_name
                            self.purchasable_escape_spells = { }
                            log("Found")
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

-- Finds a random point to move to
function AIController:chooseTargetPoint()
    -- Add delay before randomly choosing the next target point (other ways will still work)
    local time_delay = 0

    -- Chance to move towards target
    if self.target_pawn and self.target_pawn.owner:isAlive() and math.random(0, 10) == 0 then
        local angle = math.random(0, 360)
        self.target = self.target_pawn.location + math.random(0, 200) * Vector(math.cos(angle), math.sin(angle), 0)
        time_delay = math.random(0.4, 0.8)
    -- Dodge closest projectile
    elseif math.random(0, 1) == 0 then
        local projectiles = GAME:actorsOfType(Projectile)
        local closest_proj = nil
        local closest_proj_dst = 99999999

        -- Get closest enemy projectile
        for _, proj in pairs(projectiles) do
            if proj.instigator.owner:getAlliance(self.pawn.owner) == Player.ALLIANCE_ENEMY then
                local dst = (proj.location - self.pawn.location):Length()

                if dst < closest_proj_dst then
                    closest_proj = proj
                    closest_proj_dst = dst
                end
            end
        end

        -- Move perpendicular to its velocity if it exists
        if closest_proj then
            local proj_dir = closest_proj.velocity:Normalized()
            local perp_dir = Vector(-proj_dir[2], proj_dir[1], 0)

            self.target = self.pawn.location + perp_dir * 300
        
            time_delay = math.random(0.4, 0.8)
        -- else just move randomly
        else
            local angle = math.random(0, 360)
            self.target = math.random(0, 0.3 * GAME.arena.current_layer * GAME.arena.ARENA_TILE_SIZE) * Vector(math.cos(angle), math.sin(angle), 0)
            self.target.z = Config.GAME_Z
            time_delay = math.random(0.0, 0.2)
        end
    -- Choose random point on platform
    else
        local angle = math.random(0, 360)
        self.target = math.random(0, 0.3 * GAME.arena.current_layer * GAME.arena.ARENA_TILE_SIZE) * Vector(math.cos(angle), math.sin(angle), 0)
        self.target.z = Config.GAME_Z
        time_delay = math.random(0.0, 0.2)
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

-- Casts a random projectile spell, returns false if nothing was cast
function AIController:castRandomProjectileSpell()
    local spell_name = self.projectile_spells[math.random(1, #self.projectile_spells)]
    local spell_item_name = "item_" .. spell_name

    local spell
    
    -- Special case for fireball since it's an item and not an ability
    if spell_name == "warlock_fireball" then
        spell = self.fireball
        spell_name = "item_" .. spell_name
    else
        spell = self.pawn.unit:FindAbilityByName(spell_name)
    end

    if not spell or spell:IsNull() then
        log("Could not find spell " .. spell_name)
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

function AIController:buyRandomSpell()
    -- 50 percent chance to buy an R spell if not owning one already
    if not self.escape_spell and math.random(0, 1) == 0 then
        local spell_number = math.random(1, #self.purchasable_escape_spells)
        local spell_name = self.purchasable_escape_spells[spell_number]
        local spell_item_name = "item_" .. spell_name

        self.pawn.unit:AddItemByName(spell_item_name)
        self.pawn.unit:SwapItems(2, 6)

        purchase {
            PlayerID = self.player.id,
            itemcost = 15, -- TODO
            itemname = spell_item_name
        }

        self.escape_spell = spell_name

        self.purchasable_escape_spells = { }
    else
        if #self.purchasable_target_spells == 0 then
            return
        end

        local column = math.random(1, #self.purchasable_target_spells)
        local spells = table.remove(self.purchasable_target_spells, column)
    
        local spell_number = math.random(1, #spells)
        local spell_name = spells[spell_number]
        local spell_item_name = "item_" .. spell_name

        self.pawn.unit:AddItemByName(spell_item_name)
        self.pawn.unit:SwapItems(2, 6)

        purchase {
            PlayerID = self.player.id,
            itemcost = 15, -- TODO
            itemname = spell_item_name
        }

        table.insert(self.projectile_spells, spell_name)
    end
    print("Purchased a spell")
end

function AIController:castEscapeSpell()
    local spell = self.pawn.unit:FindAbilityByName(self.escape_spell)

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
        if (self.pawn.location - self.target):Length() < 100 or (self.time > self.next_target_time and math.random(0, 4) == 0) then
            self:chooseTargetPoint()
        end

        -- Do nothing while a spell is being cast
        if self.time < self.spell_end_time then
            self.time = self.time + dt
            return
        end

        -- Do nothing while scourging
        if self.time < self.scourge_end_time then
            local do_nothing = true

            if closest_pawn then
                local dist = (self.pawn.location - closest_pawn.location):Length()

                -- Chance to cancel if enemy is too far away
                if dist > 250 and math.random(0, 2) == 0 then
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

        -- Cast scourge on close pawns
        if try_more and closest_pawn and self.scourge:IsFullyCastable() then
            local dist = (self.pawn.location - closest_pawn.location):Length()
            
            if dist < 300 and math.random(0, 3) == 0 then
                self.pawn.unit:CastAbilityNoTarget(self.scourge, self.player.id)
                try_more = false
                self.scourge_end_time = self.time + 1.0
            end
        end

        -- Cast projectiles randomly
        if try_more and self.target_pawn and math.random(0, 4) == 0 then
            try_more = not self:castRandomProjectileSpell()
        end

        -- Move position
        if try_more then
            -- Move to target point
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
            if player_ent and not GAME.players[i] and PlayerResource:IsFakeClient(i) and not PlayerResource:HasSelectedHero(i) then
                print("Created hero for AI with player id", i)
                player_ent.ai_def = { think_interval = think_interval }
                CreateHeroForPlayer("npc_dota_hero_warlock", player_ent)
            end
        end
    end
end
