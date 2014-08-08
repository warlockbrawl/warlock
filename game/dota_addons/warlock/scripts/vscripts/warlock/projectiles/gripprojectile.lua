GripProjectile = class(Projectile)

--- Params
-- grip_mod
-- hit_sound
-- end_sound
-- dp_gain
-- duration

function GripProjectile:init(def)
	GripProjectile.super.init(self, def)

	-- Extract
	self.grip_mod = def.grip_mod
	self.hit_sound = def.hit_sound
	self.end_sound = def.end_sound
	self.dp_gain = def.dp_gain
	self.duration = def.duration
end

function GripProjectile:onCollision(coll_info, cc)
	local actor = coll_info.actor

	if actor:instanceof(Pawn) then
		-- Play a hit sound
		if self.hit_sound then
			actor.unit:EmitSound(self.hit_sound)
		end
		
		-- Set walk velocity to zero
		actor.walk_velocity.x = 0
		actor.walk_velocity.y = 0

		-- Add the grip modifier
		GAME:addModifier(GripModifier:new {
			pawn = actor,
			dp_gain = self.dp_gain,
			time = self.duration,
			native_mod = self.grip_mod,
			end_sound = self.end_sound,
			speed_bonus_abs = -10000,
			kb_reduction = 0.67
		})
	end

	-- destroy
	if not self.scheduled_destruction then
		self.scheduled_destruction = true
		self:setLifetime(0)
	end
end
