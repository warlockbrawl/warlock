DrainHealProjectile = class(Projectile)

function DrainHealProjectile:init(def)
	-- extract data
	self.instigator = def.instigator
	self.heal_amount = def.heal_amount or 0
	self.target = def.target
	self.hit_sound = def.hit_sound

	if self.instigator then
		def.owner = self.instigator.owner
	end
	
	-- actor constructor
	Projectile.super.init(self, def)

	-- effect
	if def.projectile_effect then
		self.effect = Effect:create(def.projectile_effect, {location=self.location})
	end
end

function DrainHealProjectile:onPreTick(dt)
	local delta = self.target.location - self.location
	delta.z = 0
	local dist_sq = delta:Dot(delta)
	
	if dist_sq < 4096 then --64
		-- Heal target and destroy
		self.target:heal {
			source = self.instigator,
			amount = self.heal_amount
		}

		-- Play a sound
		-- TODO: maybe not use the effects locust
		if self.hit_sound and self.effect and self.effect.locust then
			self.effect.locust:EmitSound(self.hit_sound)
		end
		
		self:destroy()
	else
		-- Home towards target
		self.velocity = 650 * delta:Normalized()
	end
end
