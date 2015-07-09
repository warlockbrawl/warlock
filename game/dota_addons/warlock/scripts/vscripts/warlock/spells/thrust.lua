--- Spell warlock_Thrust
Thrust = Spell:new{id='warlock_thrust'}

Thrust.velocity 	= 1300
Thrust.acceleration = Thrust.velocity * (1 - Config.FRICTION) / 0.03
Thrust.radius 		= 60
Thrust.range		= 900
Thrust.extra_time	= 0.09
Thrust.cast_sound	= "Thrust.Cast"
Thrust.hit_effect	= "thrust_hit"
Thrust.hit_sound	= "Thrust.Hit"
Thrust.end_sound	= "Thrust.End"	
Thrust.native_mod	= "modifier_dark_seer_ion_shell"

function Thrust:onCast(cast_info)
	local actor = cast_info.caster_actor
	local start = actor.location
	local target = cast_info.target

	actor.unit:EmitSound(cast_info:attribute("cast_sound"))

	-- Direction to target
	local dir = target - start
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()
	
	local range = cast_info:attribute('range')
	local velocity = cast_info:attribute('velocity')
	
	if dist > range then
		dist = range
	end

	-- Stop movement, set facing angle
	actor.unit:Stop()
	actor.unit:SetAngles(0, math.deg(math.atan2(dir.y, dir.x)), 0)
	
	actor.velocity = 0.77 * dir * velocity
	
	GAME:addModifier(ThrustModifier:new {
		pawn = actor,
		acceleration = dir * cast_info:attribute('acceleration'),
		radius = cast_info:attribute('radius'),
		damage = cast_info:attribute('damage'),
		time = cast_info:attribute('extra_time') + dist / velocity,
		hit_effect = cast_info:attribute('hit_effect'),
		hit_sound = cast_info:attribute('hit_sound'),
		native_mod = cast_info:attribute('native_mod'),
		end_sound = cast_info:attribute('end_sound')
	})
end

-- effects
Effect:register('thrust_hit', {
	class 				= ParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_stormspirit/stormspirit_overload_discharge.vpcf'
})
