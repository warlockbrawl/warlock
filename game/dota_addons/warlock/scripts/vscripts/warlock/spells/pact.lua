Pact = Spell:new{id='item_warlock_pact1'}

Pact.effect = "pact_effect"
Pact.enhance_effect = "pact_enhance"
Pact.enhance_sound = "Pact.Enhance"
Pact.slow_effect = "pact_slow_effect"

function Pact:onCast(cast_info)
	GAME:addModifier(PactModifier:new {
		pawn = cast_info.caster_actor,		
		time = cast_info.caster_actor:getBuffDuration(cast_info:attribute("duration"), cast_info.caster_actor),
		
		speed_reduction = cast_info:attribute("speed_reduction"),
		damage_multiplier = cast_info:attribute("damage_multiplier"),
		enhance_effect = Pact.enhance_effect,
		enhance_sound = Pact.enhance_sound,
		effect = Pact.effect,
		slow_effect = Pact.slow_effect,
		slow_duration = cast_info:attribute("slow_duration"), cast_info.caster_actor,
	})
end

Effect:register(Pact.effect, {
	class = ParticleEffect,
	effect_name = "particles/generic_gameplay/rune_doubledamage.vpcf"
})

Effect:register(Pact.enhance_effect, {
	class 				= ParticleEffect,
	effect_name 		= 'particles/econ/items/abaddon/abaddon_alliance/abaddon_aphotic_shield_alliance_explosion.vpcf'
})

Effect:register(Pact.slow_effect, {
	class 				= ParticleEffect,
	effect_name 		= 'particles/econ/courier/courier_oculopus/courier_oculopus_ambient.vpcf'
})
