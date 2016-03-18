--- Spell warlock_windwalk

WindWalk = Spell:new{id='warlock_windwalk'}
WindWalk.hit_sound = "WindWalk.Hit"
WindWalk.cast_sound = "WindWalk.Cast"

function WindWalk:onCast(cast_info)
	local actor = cast_info.caster_actor
	actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	GAME:addModifier(WindWalkModifier:new {
		pawn = actor,
		damage = cast_info:attribute("damage"),
		time = actor:getBuffDuration(cast_info:attribute("duration"), actor),
		speed_bonus_abs = cast_info:attribute("move_bonus"),
		hit_sound = cast_info:attribute("hit_sound"),
		native_mod = "modifier_invisible"
	})
end
