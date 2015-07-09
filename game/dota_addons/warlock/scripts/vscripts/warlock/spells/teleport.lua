--- Spell warlock_fireball
Teleport = Spell:new{id='warlock_teleport'}
Teleport.source_effect = "teleport_source"
Teleport.target_effect = "teleport_target"

function Teleport:onCast(cast_info)
	local actor = cast_info.caster_actor
	local range = cast_info:attribute('range')
	
	local start = actor.location
	local target = cast_info.target
	local dir = target - start
	
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()
	
	if(dist > range) then
		target = start + dir * range
	end
	
	target.z = start.z
	
	actor.location = target
	actor.velocity = actor.velocity * 0.8 --reduce vel by 20 percent

	-- Stop movement
	actor.unit:Stop()
	
	Effect:create(cast_info:attribute('source_effect'), { location=start })
	Effect:create(cast_info:attribute('target_effect'), { location=target })
end

-- effects
Effect:register('teleport_source', {
	class 				= ProjectileParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_vengeful/vengeful_nether_swap.vpcf'
})

Effect:register('teleport_target', {
	class 				= ParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_vengeful/vengeful_nether_swap_blue.vpcf'
})
