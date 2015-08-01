--- Spell warlock_cluster
Cluster = Spell:new{id='warlock_cluster'}

Cluster.projectile_class = SimpleProjectile
Cluster.projectile_speed = 844
Cluster.projectile_effect = 'cluster_projectile'
Cluster.radius = 22
Cluster.knockback_factor = 0.65

function Cluster:onCast(cast_info)
	-- Calculate dist and angle
	local start = cast_info.caster_actor.location
	local delta = cast_info.target - start
	delta.z = 0
	local dist = delta:Length()
	
	local angle = math.atan2(delta.y, delta.x) - 0.18

	-- Spawn four projectiles, starting at -0.18 and ending at 0.18 angle in rad
	for i = 0, 3 do
		local target = start + dist * Vector(math.cos(angle), math.sin(angle), 0)
		cast_info.target = target
		self:spawnProjectile(cast_info)
		angle = angle + 0.12
	end
end

-- effects
Effect:register('cluster_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf',
	destruction_sound 	= "Cluster.Explode"
	})
