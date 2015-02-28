ShieldModifier = class(Modifier)

--- Params
-- reflect_sound
-- reflect_effect
-- radius

function ShieldModifier:init(def)
	ShieldModifier.super.init(self, def)

	self.reflect_sound = def.reflect_sound
	self.reflect_effect = def.reflect_effect
    self.radius = def.radius
end

-- Called when the modifier is turned on or off
function ShieldModifier:onToggle(apply)
	local pawn_cc = self.pawn.collision_components["pawn"]
	pawn_cc.coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PROJECTILE] = not apply
	
	-- Add / remove temp cc and effect
	if(apply) then
		self.pawn:addCollisionComponent {
			id = 'shield',
			channel = CollisionComponent.CHANNEL_PLAYER,
			coll_mat = CollisionComponent.createCollMatSimple(
				{Player.ALLIANCE_ENEMY},
				{CollisionComponent.CHANNEL_PROJECTILE}),
			radius = self.radius,
			ellastic = false,
			class = ShieldCollisionComponent,
			coll_initiative = -3,
			accept_damage = false
		}
	else
		self.pawn:removeCollisionComponent("shield")
	end
	
	ShieldModifier.super.onToggle(self, apply)
end

-- Called when the owning pawn collides
function ShieldModifier:onCollision(coll_info, cc)
	if(cc.id == 'shield') then
		-- Reflect the actor
		local actor = coll_info.actor
		
		-- Hardcode actors which dont get reflected
		local reflect = not actor:instanceof(SwapProjectile) and 
			not actor:instanceof(GravityProjectile) and
			not actor:instanceof(WarpZoneActor)
			
		-- Hardcode actors which dont get their owner changed
		local change_owner = reflect and not actor:instanceof(BoomerangProjectile)
		
		-- Hardcode boomerang stop acceleration
		if(actor:instanceof(BoomerangProjectile)) then
			actor:stopAcceleration()
		end
		
		-- Change owner
		if change_owner then
			actor.instigator = self.pawn
			actor.owner = self.pawn.owner
		end
		
		-- Reflect
		if reflect then
			-- Only reflect if its moving towards the actor
			if actor:isMovingTowards(-coll_info.hit_normal) then
				actor:reflectVelocity(-coll_info.hit_normal)
			end
			
			-- Play a sound
			if self.reflect_sound then
				self.pawn.unit:EmitSound(self.reflect_sound)
			end
			
			-- Create a particle effect
			if self.reflect_effect then
				Effect:create(self.reflect_effect, { location = coll_info.hit_location })
			end
		end
	end
end

-----------------------------------------------------
-- Custom CC for not calling projectile's coll func
-----------------------------------------------------

ShieldCollisionComponent = class(CollisionComponentSphere)

function ShieldCollisionComponent:collisionFilter(other_cc)
	-- returns notify_self, notify_other, ellastic
	local alliance = self.actor.owner:getAlliance(other_cc.actor.owner)

	if(self.coll_mat[alliance][other_cc.channel]) then
		return true, false, self.ellastic
	end

	return false, false, false
end
