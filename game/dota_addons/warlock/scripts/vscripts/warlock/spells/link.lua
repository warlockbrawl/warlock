--- Spell warlock_link
Link = Spell:new{id='warlock_link'}

Link.projectile_class = LinkProjectile
Link.projectile_effect = 'link_projectile'
Link.radius = 35
Link.speed = 950
Link.range = 860
Link.pull_accel = 1550
Link.hit_sound = "Link.Hit"
Link.cast_sound = "Link.Cast"
Link.loop_sound = "Link.Loop"
Link.loop_duration = 100000 -- Already loops by default
Link.beam_effect = "link_beam"

function Link:onCast(cast_info)
	local actor = cast_info.caster_actor

	local damage = cast_info:attribute('damage')
	local range = cast_info:attribute('range') * actor.owner.mastery_factor[Player.MASTERY_RANGE]
	local radius = cast_info:attribute('radius')
	local projectile_effect = cast_info:attribute('projectile_effect')
	local speed = cast_info:attribute('speed')
	local hit_sound = cast_info:attribute('hit_sound')
	local loop_sound = cast_info:attribute('loop_sound')
	local loop_duration = cast_info:attribute('loop_duration')
	local pull_accel = cast_info:attribute('pull_accel')
	local beam_effect = cast_info:attribute('beam_effect')
	local cast_sound = cast_info:attribute('cast_sound')
	
    if cast_sound then
	    actor.unit:EmitSound(cast_sound)
    end
	
	-- Direction to target
	local start = cast_info.caster_actor.location
	local dir = cast_info.target - start
	dir.z = 0
	dir = dir:Normalized()
	
	LinkProjectile:new {
		instigator	= actor,
		coll_radius = radius,
		projectile_effect = projectile_effect,
		location = start,
		damage = damage,
		velocity = speed * dir,
		speed = speed,
		pull_accel = pull_accel,
		hit_sound = hit_sound,
		loop_sound = loop_sound,
		loop_duration = loop_duration,
		retract_time = range / speed,
		beam_effect = beam_effect
	}
end

-- effects
Effect:register('link_projectile', {
	class = ProjectileParticleEffect,
	effect_name = "" -- "particles/units/heroes/hero_disruptor/disruptor_base_attack.vpcf"
})

Effect:register('link_beam', {
	class 				= FollowLightningEffect,
	effect_name 		= "particles/units/heroes/hero_stormspirit/stormspirit_electric_vortex.vpcf"
})