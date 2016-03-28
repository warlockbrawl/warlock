RechargeRefreshProjectile = class(Projectile)

function RechargeRefreshProjectile:init(def)
	-- extract data
	self.instigator = def.instigator
	self.target = def.target
	self.hit_sound = def.hit_sound

	if self.instigator then
		def.owner = self.instigator.owner
	end
	
	-- actor constructor
	Projectile.super.init(self, def)

	-- effect
	if def.projectile_effect then
		self.effect = Effect:create(def.projectile_effect, { location = self.location, duration = -1})
	end
end

function RechargeRefreshProjectile:onPreTick(dt)
	local delta = self.target.location - self.location
	delta.z = 0
	local dist_sq = delta:Dot(delta)
	
	if dist_sq < 4096 then --64
		-- Refresh recharge cooldown and destroy
		local recharge_abil = self.target.unit:FindAbilityByName("warlock_recharge")

		if recharge_abil then
			recharge_abil:EndCooldown()
		else
			log("Could not find recharge abil when trying to refresh its cooldown")
		end

		-- Play a sound
		-- TODO: maybe not use the effects locust
		if self.hit_sound and self.effect and self.effect.locust then
			self.effect.locust:EmitSound(self.hit_sound)
		end
		
		self:destroy()
	else
		-- Home towards target
		self.velocity = 400 * delta:Normalized()
	end
end
