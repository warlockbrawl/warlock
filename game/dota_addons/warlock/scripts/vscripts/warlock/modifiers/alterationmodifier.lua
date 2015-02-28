AlterationModifier = class(Modifier)

--- Params
-- swap_sound
-- swap_effect
-- radius

function AlterationModifier:init(def)
	AlterationModifier.super.init(self, def)

	self.swap_sound = def.swap_sound
	self.swap_effect = def.swap_effect
    self.radius = def.radius
end

-- Called when the modifier is turned on or off
function AlterationModifier:onToggle(apply)
	-- Add / remove temp cc and effect
	if(apply) then
		self.pawn:addCollisionComponent {
			id = 'alteration',
			channel = CollisionComponent.CHANNEL_PLAYER,
			coll_mat = CollisionComponent.createCollMatSimple(
				{Player.ALLIANCE_ENEMY},
				{CollisionComponent.CHANNEL_PROJECTILE}),
			radius = self.radius,
			ellastic = false,
			class = AlterationCollisionComponent,
			coll_initiative = -3,
			accept_damage = false
		}
	else
		self.pawn:removeCollisionComponent("alteration")
	end
	
	AlterationModifier.super.onToggle(self, apply)
end

-- Called when the owning pawn collides
function AlterationModifier:onCollision(coll_info, cc)
	if(cc.id == 'alteration') then
		-- Reflect the actor
		local actor = coll_info.actor
		
		-- Hardcode actors which dont get swapped
		local swap = not actor:instanceof(GravityProjectile) and not actor:instanceof(WarpZoneActor)

        -- Only swap projectiles that are moving towards the caster
		swap = swap and actor:isMovingTowards(-coll_info.hit_normal)

		-- Swap location
		if swap then        		
			-- Play a sound
			if self.swap_sound then
				self.pawn.unit:EmitSound(self.swap_sound)
			end
			
			-- Create a particle effect
			if self.swap_effect then
				Effect:create(self.swap_effect, { location = actor.location })
                Effect:create(self.swap_effect, { location = self.pawn.location })
			end

            -- Swap the locations
            local new_proj_loc = self.pawn.location
            self.pawn.location = actor.location
            actor.location = new_proj_loc

            -- Remove the modifier
            GAME:removeModifier(self)
		end
	end
end

-----------------------------------------------------
-- Custom CC for not calling projectile's coll func
-----------------------------------------------------

AlterationCollisionComponent = class(CollisionComponentSphere)

function AlterationCollisionComponent:collisionFilter(other_cc)
	-- returns notify_self, notify_other, ellastic
	local alliance = self.actor.owner:getAlliance(other_cc.actor.owner)

	if(self.coll_mat[alliance][other_cc.channel]) then
		return true, false, self.ellastic
	end

	return false, false, false
end
