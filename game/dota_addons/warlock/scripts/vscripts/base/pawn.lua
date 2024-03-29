--- Pawn - hero actor
-- @author Krzysztof Lis (Adynathos)

Pawn = class(Actor)
Pawn.WALK_SPEED = 1000
Pawn.WALK_SPEED_SQ = Pawn.WALK_SPEED*Pawn.WALK_SPEED

function Pawn:init(def)
	-- initial state
	def.name = "pawn_player_"..def.owner.id
	def.location = def.unit:GetAbsOrigin()
	def.location.z = Config.GAME_Z
	def.mass = 100

	-- actor constructor
	Pawn.super.init(self, def)

	-- coll component
	self:addCollisionComponent{
		id 					= 'pawn',
		channel 			= def.coll_channel or CollisionComponent.CHANNEL_PLAYER,
		coll_mat = CollisionComponent.createCollMatSimple(
			{Player.ALLIANCE_ENEMY, Player.ALLIANCE_ALLY},
			{CollisionComponent.CHANNEL_PLAYER , CollisionComponent.CHANNEL_PROJECTILE, CollisionComponent.CHANNEL_OBSTACLE}),
		radius 				= 30,
		ellastic 			= true,
		ellasticity 		= 0.5
	}

	-- Pawn data structures
	self.walk_velocity = Vector(0, 0, 0)

	-- Prepare unit
	self.unit:SetMinimumGoldBounty(0)
	self.unit:SetMaximumGoldBounty(0)

	-- Set max level
	for i = 1, Config.MAX_LEVEL do
		self.unit:HeroLevelUp(false)
	end

	self.unit:SetAbilityPoints(0)

	-- Stats
	self.kb_factor = 1
	self.dmg_factor = 1
	self.dmg_reduction = 0
	self.max_hp = Config.PAWN_MAX_LIFE
	self.move_speed = Config.PAWN_MOVE_SPEED
	self.hp_regen = Config.PAWN_HEALTH_REG
	self.health = self.max_hp
	self.debuff_factor = 1

	-- Model scale
	self.unit:SetModelScale(Config.HERO_SETTINGS[self.unit:GetName()].SCALE)

	self:respawn()
end

function Pawn:enable()
	if not self.enabled then
        Pawn.super.enable(self)
	    GAME.pawns:add(self)
    end
end

function Pawn:disable()
    if self.enabled then
	    Pawn.super.disable(self)
	    GAME.pawns:remove(self)
    end
end

function Pawn:applyStats()
	local u = self.unit
	u:SetBaseMoveSpeed(math.max(0, self.move_speed))
	u:SetMaxHealth(self.max_hp)
	u:SetBaseHealthRegen(self.hp_regen)
	u:SetHealth(self.health)
end

function Pawn:setHealth(health)
	if(health > self.max_hp) then
		self.health = self.max_hp
	else
		self.health = health
	end

	self.unit:SetHealth(health)
end

-- Gets the scaled duration for a buff
function Pawn:getBuffDuration(dur, buff_pawn)
	-- Self factor
	local scaled_dur = dur * self.owner.mastery_factor[Player.MASTERY_DURATION]
	
	-- Other factor
	if buff_pawn ~= self then
		scaled_dur = scaled_dur * buff_pawn.owner.mastery_factor[Player.MASTERY_DURATION]
	end
	
	return scaled_dur
end

-- Gets the scaled duration for a debuff
function Pawn:getDebuffDuration(dur, debuff_pawn)
	-- Self factor
	local scaled_dur = dur * self.debuff_factor
	
	if debuff_pawn ~= self then
		-- Other factor
		scaled_dur = scaled_dur * debuff_pawn.owner.mastery_factor[Player.MASTERY_DURATION]
	end
	
	return scaled_dur
end

-- Methods for adding and removing native modifiers, stats need to be reapplied after
-- because they get reset by dota
function Pawn:addNativeModifier(mod_name)
	self.unit:AddNewModifier(self.unit, nil, mod_name, nil)
	self:applyStats()
end

function Pawn:removeNativeModifier(mod_name)
	self.unit:RemoveModifierByName(mod_name)
	self:applyStats()
end

function Pawn:respawn()
	self.velocity = Vector(0, 0, 0)
	self.walk_velocity = Vector(0, 0, 0)
	self.location = GAME:getRespawnLocation(self)
	self.last_hitter = nil

	self:enable()

	if not self.unit:IsAlive() then
		print("Respawning hero")
		self.unit:RespawnHero(false, false)
	end

	self.unit:SetMana(0)
	self:resetCooldowns()
	self.health = self.max_hp
	self:applyStats()
	
    -- Already done in mode on kill
	-- self.owner.team:updateAliveCount()

	-- TODO / HARDCODED: Recharge reset consecutive count
	Recharge.resetConsecutiveCount(self)
end

function Pawn:die(dmg_info)
	local source_actor = nil
	local source_unit = nil

	print("Pawn:die()")

	if dmg_info.source then
		source_actor = dmg_info.source
	elseif self.last_hitter then
		-- lava damage - becasue it has not source
		source_actor = self.last_hitter
	else
		source_actor = self
	end

	source_unit = source_actor.unit
	
	-- Set health to 0
	self.health = 0

	-- Kill unit
	self.unit:Kill(nil, source_unit)

	-- disable the actor
	self:disable()
	
    -- Already done in mode on kill
	-- Update team alive count
	--self.owner.team:updateAliveCount()
	
	-- Notify game
	GAME:PawnKilled{victim=self, killer=source_actor}
end

function Pawn:resetCooldowns()
	-- Reset spell cds
	for spell_name, _ in pairs(Spell.spells) do
		local abil = self.unit:FindAbilityByName(spell_name)

		if abil then
			abil:EndCooldown()
		end
	end
	
	-- Reset item cds
	for slot = 0, 5 do
		local item = self.unit:GetItemInSlot(slot)
		if item then
			item:EndCooldown()
		end
	end
end

function Pawn:_updateLocation()
	local loc = GetGroundPosition(self.location, self.unit)
	self.unit:SetAbsOrigin(loc)
end

function Pawn:increaseKBPoints(amount)
	local kb_points = self.unit:GetMana()
	kb_points = max(kb_points + amount, 0)
	self.unit:SetMana(kb_points)
end

function Pawn:heal(info)
	if not self.enabled then
		return
	end
	
	self:setHealth(self.health + info.amount)
	self:increaseKBPoints(-(info.dp_factor or 0.5) * info.amount)
	
	-- Display heal text
	GAME:showFloatingNum {
		num = info.amount,
		location = self.location,
		duration = 1,
		color = Vector(50, 255, 50)
	}
	
	-- Increase healing statistics
	if info.source and info.source.owner then
		info.source.owner:changeStat(Player.STATS_HEALING, info.amount)
	end
end

function Pawn:receiveDamage(dmg_info)
	if not GAME.combat then
		return
	end
	
	if not self.enabled then
		return
	end
	
	if self.invulnerable then
		return
	end

    -- Global damage multiplier
    dmg_info.amount = Config.dmg_multiplier * dmg_info.amount

	-- Modifier damage change
	dmg_info.amount = dmg_info.amount * self.dmg_factor
	dmg_info.amount = dmg_info.amount - self.dmg_reduction
	if(dmg_info.amount <= 0) then
		return
	end

	-- Allow modifiers to have a final decision on damage
	dmg_info.amount = dmg_info.amount + GAME:modDamageTaken(self, dmg_info)
	if(dmg_info.amount <= 0) then
		return
	end

	-- kb points
	self:increaseKBPoints(dmg_info.amount * (dmg_info.knockback_vulnerability_factor or 1))

	if dmg_info.hit_normal then
		-- Knockback
		local kb_points = self.unit:GetMana()

        local dmg_kb_factor = dmg_info.amount

        -- Smaller slope when damage is over 100
        if dmg_kb_factor > 100 then
            dmg_kb_factor = math.sqrt(100 * dmg_kb_factor)
        end

		local kb_amount = math.max(0, self.kb_factor) * dmg_kb_factor * Config.KB_DMG_TO_VELOCITY * (1 + kb_points/1000) * (dmg_info.knockback_factor or 1)

        -- Global kb multiplier
        kb_amount = Config.kb_multiplier * kb_amount

		self:applyMomentum(kb_amount*dmg_info.hit_normal*self.mass)
	end

	dmg_info.amount = dmg_info.amount + GAME:modDamagePostKB(self, dmg_info)

	if dmg_info.source and dmg_info.source.owner and not is_neutral then
		-- Increase damage statistics
		dmg_info.source.owner:changeStat(Player.STATS_DAMAGE, dmg_info.amount)
		
		-- Lifesteal
		local lifesteal_factor = dmg_info.source.owner.mastery_factor[Player.MASTERY_LIFESTEAL]
		if lifesteal_factor ~= 0 then
			dmg_info.source:heal {
				source = dmg_info.source,
				amount = dmg_info.amount * lifesteal_factor
			}
		end
	end
	
	if dmg_info.source then
		self.last_hitter = dmg_info.source

		-- Display damage text
		GAME:showFloatingNum {
			num = dmg_info.amount,
			location = self.location,
			duration = 1,
			color = dmg_info.text_color or Vector(255, 50, 50)
		}
	end

	-- Set life
	local life = self.health - dmg_info.amount

	if life > 1 then
		self.health = life
		self.unit:SetHealth(life)
	else
		self.health = 0
		self:die(dmg_info)
	end
end

function Pawn:onPreTick(dt)
	-- remove previous walk vel
	self.velocity = self.velocity - self.walk_velocity

	-- apply friction
	self.velocity = self.velocity * Config.FRICTION

	-- get new walk velocity
	self.walk_velocity = (self.unit:GetAbsOrigin() - self.location)/dt
	self.walk_velocity.z = 0

	if self.walk_velocity:Dot(self.walk_velocity) > self.WALK_SPEED_SQ then
		self.walk_velocity = self.walk_velocity:Normalized() * self.WALK_SPEED
	end

	-- add new walk vel
	self.velocity = self.velocity + self.walk_velocity
	
	-- pretick for modifiers
	GAME:modOnPreTick(self, dt)
end

function Pawn:onPostTick(dt)
	Pawn.super.onPostTick(self, dt)
	
	if self.enabled and self.unit:IsAlive() then
		self.health = math.min(self.max_hp, self.health + self.hp_regen * dt)
	end
end

--- utility damage
-- requires: radius and dmg_info.amount or dmg_info.amount_min and dmg_info.amount_max
function Pawn:damageArea(target, radius, dmg_info)
	dmg_info.source = self

	local b_scaled = (dmg_info.amount_min ~= nil and dmg_info.amount_max ~= nil)
	local kb_scaled = (dmg_info.kb_factor_min ~= nil and dmg_info.kb_factor_max ~= nil)

	local dmg_base = dmg_info.amount_min
	local dmg_gain = nil

	if b_scaled then
		dmg_gain = (dmg_info.amount_max - dmg_base) / radius
	end
	
	local count = 0
	
	for pawn, _ in pairs(GAME.pawns) do
		if pawn.enabled and self.owner:getAlliance(pawn.owner) == Player.ALLIANCE_ENEMY then
			local diff = pawn.location - target
			diff.z = 0

			local dst = diff:Length()

			if dst < radius then
				dmg_info.hit_normal = diff:Normalized()
				
				count = count + 1
				
				if b_scaled then
					dmg_info.amount = dmg_base + dmg_gain * (radius - dst)
				end

				-- Linearly interpolate knockback factor between min and max
				if kb_scaled then
					local t = 1 - dst / radius
					dmg_info.knockback_factor = (1 - t) * dmg_info.kb_factor_min + t * dmg_info.kb_factor_max
				end
				
				pawn:receiveDamage(dmg_info)
			end
		end
	end
	
	return count 
end

function Game:filterPawns(filter)
	local pawns = {}

	if(not filter) then
		warning("filter in filterPawns was nil, returning empty list")
		return pawns
	end

	for pawn, _ in pairs(GAME.pawns) do
		if(filter(pawn)) then
			table.insert(pawns, pawn)
		end
	end

	return pawns
end
