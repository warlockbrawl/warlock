--- Spell warlock_fireball
Fireball = Spell:new{
	id='item_warlock_fireball1',
	alt_ids={
		"item_warlock_fireball2",
		"item_warlock_fireball3",
		"item_warlock_fireball4",
		"item_warlock_fireball5",
		"item_warlock_fireball6",
		"item_warlock_fireball7",
	}
}

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
