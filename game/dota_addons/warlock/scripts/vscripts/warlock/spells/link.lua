--- Spell warlock_fireball
Link = Spell:new{id='warlock_link'}

Link.projectile_class = LinkProjectile
Link.projectile_effect = 'link_projectile'
Link.radius = 38
Link.ttl = 1.0 -- Time to live
Link.speed = 900
Link.hit_sound = "Link.Hit"

function Link:onCast(cast_info)
	local damage = cast_info:attribute('damage')
	local range = cast_info:attribute('range')
	local radius = cast_info:attribute('radius')
	local projectile_effect = cast_info:attribute('projectile_effect')
	local ttl = cast_info:attribute('ttl')
	local speed = cast_info:attribute('speed')
	local hit_sound = cast_info:attribute('hit_sound')

	-- Direction to target
	local start = cast_info.caster_actor.location
	local dir = cast_info.target - start
	dir.z = 0
	dir = dir:Normalized()
	
	LinkProjectile:new {
		instigator	= cast_info.caster_actor,
		coll_radius = radius,
		projectile_effect = projectile_effect,
		location = start,
		damage = damage,
		range = range,
		ttl = ttl,
		velocity = speed * dir,
		speed = speed,
		hit_sound = hit_sound
	}
end

-- effects
Effect:register('link_projectile', {
	class = ProjectileParticleEffect,
	effect_name = "particles/units/heroes/hero_visage/visage_soul_assumption_bolt.vpcf",
	destruction_sound = "Link.Explode"
})

Effect:register('link_beam', {
	class 				= LightningEffect,
	effect_name 		= "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf"
})