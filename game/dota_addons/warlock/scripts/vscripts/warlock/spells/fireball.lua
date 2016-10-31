--- Spell warlock_fireball
Fireball = Spell:new{id='item_warlock_fireball1'}

Fireball.projectile_class 	= FireballProjectile
Fireball.projectile_speed 	= 1000
Fireball.projectile_effect 	= 'fireball_projectile'
Fireball.radius 			= 25

function Fireball:onCast(cast_info)
	self:spawnProjectile(cast_info)
end

-- effects
Effect:register('fireball_projectile', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_phoenix/phoenix_base_attack.vpcf',
	destruction_sound 	= "Fireball.Explode"
})
