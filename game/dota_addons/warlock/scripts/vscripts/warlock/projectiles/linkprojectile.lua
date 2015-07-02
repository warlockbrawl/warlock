LinkProjectile = class(Projectile)

--- Params
-- speed
-- damage
-- retract_time
-- pull_accel
-- beam_effect

function LinkProjectile:init(def)
	self.speed = def.speed
	self.damage = def.damage
	self.retract_time = def.retract_time
	self.hit_sound = def.hit_sound
	self.loop_sound = def.loop_sound
	self.loop_duration = def.loop_duration
	self.pull_accel = def.pull_accel
	self.beam_effect = def.beam_effect

	LinkProjectile.super.init(self, def)

	-- Set the correct coll matrix
	local coll_mat = { }
	coll_mat[Player.ALLIANCE_SELF] = {}
	coll_mat[Player.ALLIANCE_ALLY] = {}
	coll_mat[Player.ALLIANCE_ENEMY] = {}

	coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_OBSTACLE] = true

	self.collision_components["projectile"].coll_mat = coll_mat
	self.collision_components["projectile"].coll_initiative = -1

	self.link_beam_effect = Effect:create(self.beam_effect, {
		start_ent = self.instigator.unit,
		end_ent = self.effect.locust,
		duration = -1
	})
	
	-- Start the retract timer
	self:addTimer
	{
		time = self.retract_time,
		func = function()
			self:retract()
		end
	}
	
	self.retracting = false
end

function LinkProjectile:onCollision(coll_info, cc)
	local actor = coll_info.actor

	-- Play a sound
	-- TODO: maybe not use the effects locust
	if self.hit_sound and self.effect and self.effect.locust then
		self.effect.locust:EmitSound(self.hit_sound)
	end
	
	if(actor:instanceof(Pawn)) then
        if self.link_beam_effect then
            -- Set the effects target
            self.link_beam_effect:setEndEntity(actor.unit)
        end

		-- Add the link modifier that pushes the pawn towards the target
		GAME:addModifier(LinkModifier:new {
			pawn = actor,
			target = self.instigator,
			loop_sound = self.loop_sound,
			loop_duration = self.loop_duration,
			pull_accel = self.pull_accel,
			link_beam_effect = self.link_beam_effect,
			damage = self.damage
		})
	elseif(coll_info.actor:instanceof(Obstacle)) then
        if self.link_beam_effect then
            -- Set the effects target
            self.link_beam_effect:setEndEntity(actor.locust)
        end

		-- Add the link modifier that pushes the pawn towards the target
		GAME:addModifier(LinkModifier:new {
			pawn = self.instigator,
			target = actor,
			loop_sound = self.loop_sound,
			loop_duration = self.loop_duration,
			pull_accel = self.pull_accel,
            link_beam_effect = self.link_beam_effect,
			beam_effect = self.beam_effect
		})
	end
	
	-- Destroy the projectile, the target is now linked
	self:destroy()
end

function LinkProjectile:retract()
	self.retracting = true
end

function LinkProjectile:onPreTick(dt)
	if self.retracting then
		local delta = self.instigator.location - self.location
		local dst = delta:Length()
		
		if dst < 75 then
            -- Destroy the link if nobody was linked
            if self.link_beam_effect then
		        self.link_beam_effect:destroy()
	        end

			self:destroy()
		else
			local dir = delta:Normalized()
			self.velocity = self.speed * dir
		end
	end
end
