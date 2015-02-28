--- Spell warlock_alteration

Alteration = Spell:new{id='warlock_alteration'}
Alteration.cast_sound = "Alteration.Cast"
Alteration.swap_sound = "Alteration.Swap"
Alteration.modifier_name = "modifier_treant_living_armor"
Alteration.swap_effect = "alteration_swap"

function Alteration:onCast(cast_info)
	local actor = cast_info.caster_actor
	actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	GAME:addModifier(AlterationModifier:new {
		pawn = cast_info.caster_actor,
		time = actor:getBuffDuration(cast_info:attribute("duration"), actor),
		swap_sound = cast_info:attribute("swap_sound"),
		swap_effect = cast_info:attribute("swap_effect"),
		native_mod = cast_info:attribute("modifier_name"),
        radius = cast_info:attribute("radius")
	})
end

Effect:register('alteration_swap', {
	class 				= ParticleEffect,
	effect_name 		= 'particles/prototype_fx/item_linkens_buff_explosion.vpcf'
})
