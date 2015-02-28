--- Spell warlock_shield

Shield = Spell:new{id='warlock_shield'}
Shield.cast_sound = "Shield.Cast"
Shield.reflect_sound = "Shield.Reflect"
Shield.modifier_name = "modifier_omniknight_repel"
Shield.reflect_effect = "shield_reflect"

function Shield:onCast(cast_info)
	local actor = cast_info.caster_actor
	actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	GAME:addModifier(ShieldModifier:new {
		pawn = cast_info.caster_actor,
		time = actor:getBuffDuration(cast_info:attribute("duration"), actor),
		reflect_sound = cast_info:attribute("reflect_sound"),
		reflect_effect = cast_info:attribute("reflect_effect"),
		native_mod = cast_info:attribute("modifier_name"),
        radius = cast_info:attribute("radius")
	})
end

Effect:register('shield_reflect', {
	class 				= ParticleEffect,
	effect_name 		= 'particles/units/heroes/hero_weaver/weaver_shukuchi_damage.vpcf'
})
