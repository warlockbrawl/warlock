ThrustModifier = class(Modifier)

function ThrustModifier:init(def)
	ThrustModifier.super.init(self, def)
	
	self.radius = def.radius
	self.acceleration = def.acceleration
	self.damage = def.damage
	self.hit_sound = def.hit_sound
	self.hit_effect = def.hit_effect
	self.end_sound = def.end_sound
	
	self.knockback = 1.0
end

function ThrustModifier:onPreTick(dt)
	self.pawn.velocity = self.pawn.velocity + self.acceleration * dt * self.time_scale
end

-- Called when thrust hits a pawn
function ThrustModifier:hitPawn(pawn, normal, vel_dependend)
	local damage = self.damage
	
	-- Damage depends on velocity if true
	if vel_dependend then
		local factor = self.pawn.velocity:Dot(self.pawn.velocity) / 1521
		if factor < 0.8 then
			damage = factor / 0.8 * damage
		end
	end
	
	-- Deal damage
	pawn:receiveDamage {
		source = self.pawn,
		hit_normal = normal,
		amount = damage,
		knockback_factor = self.knockback
	}
	
	-- Spawn effect
	if self.hit_effect then
		Effect:create(self.hit_effect, { location = self.pawn.location })
	end

	self.hit_enemy = true
	
	-- Remove this modifier
	GAME:removeModifier(self)
end

function ThrustModifier:onCollision(coll_info, cc)
	if cc.id == "thrust" then
		local actor = coll_info.actor
		
		-- Dont do anything on shielded pawns
		if actor:hasModifierOfType(ShieldModifier) then
			-- Reflect velocity
			if self.pawn:isMovingTowards(coll_info.hit_normal) then
				self.pawn:reflectVelocity(coll_info.hit_normal)
			end
			return
		end

		-- Play sound
		if self.hit_sound then
			actor.unit:EmitSound(self.hit_sound)
		end
		
		local vel_dependend = true
		
		-- If other pawn also has thrust, remove it too and do its effects
		local mod = actor:getModifierOfType(ThrustModifier)
		if mod then
			vel_dependend = false
			mod:hitPawn(self.pawn, -coll_info.hit_normal, vel_dependend)
		end
		
		-- Dont do anything if theres WW on self (WW will do it)
		if self.pawn:hasModifierOfType(WindWalkModifier) then
			return
		end

		self:hitPawn(actor, coll_info.hit_normal, vel_dependend)
	end
end

-- Called when the modifier is turned on or off
function ThrustModifier:onToggle(apply)
	local pawn_cc = self.pawn.collision_components["pawn"]
	pawn_cc.coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PLAYER] = not apply
	
	-- Add / remove temp cc and effect
	if(apply) then
		self.pawn:addCollisionComponent {
			id = 'thrust',
			channel = CollisionComponent.CHANNEL_PLAYER,
			coll_mat = CollisionComponent.createCollMatSimple(
				{Player.ALLIANCE_ENEMY},
				{CollisionComponent.CHANNEL_PLAYER}),
			radius = self.radius,
			ellastic = false,
			coll_initiative = -3,
			accept_damage = false
		}
	else
		self.pawn:removeCollisionComponent("thrust")
		
		if self.hit_enemy then
			self.pawn.velocity = Vector(0, 0, 0)
		else
			self.pawn.velocity = self.pawn.velocity * 0.2
			
			if self.end_sound then
				self.pawn.unit:EmitSound(self.end_sound)
			end
		end
	end
	
	ThrustModifier.super.onToggle(self, apply)
end
