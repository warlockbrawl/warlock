--- Spell warlock_shield

Shield = Spell:new{id='warlock_shield'}
Shield.cast_sound = "Shield.Cast"
Shield.reflect_sound = "Shield.Reflect"
Shield.modifier_name = "modifier_omniknight_repel"
Shield.reflect_effect = "shield_reflect"

function Shield:onCast(cast_info)
	cast_info.caster_actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	GAME:addModifier(ShieldModifier:new {
		pawn = cast_info.caster_actor,
		time = cast_info:attribute("duration"),
		reflect_sound = cast_info:attribute("reflect_sound"),
		reflect_effect = cast_info:attribute("reflect_effect"),
		native_mod = cast_info:attribute("modifier_name")
	})
end

Effect:register('shield_reflect', {
	class 				= ParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_weaver/weaver_shukuchi_damage.vpcf'
})
