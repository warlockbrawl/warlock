--- Spell warlock_rush

Rush = Spell:new{id='warlock_rush'}
Rush.cast_sound = "Rush.Cast"
Rush.mod_name = "modifier_ember_spirit_flame_guard"
Rush.initial_speed_bonus = 35

function Rush:onCast(cast_info)
	local actor = cast_info.caster_actor
	actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	GAME:addModifier(RushModifier:new {
		pawn = cast_info.caster_actor,
		time = actor:getBuffDuration(cast_info:attribute("duration"), actor),
		native_mod = cast_info:attribute("mod_name"),
		absorb_max = cast_info:attribute("absorb_max"),
		initial_speed_bonus = cast_info:attribute("initial_speed_bonus")
	})
end