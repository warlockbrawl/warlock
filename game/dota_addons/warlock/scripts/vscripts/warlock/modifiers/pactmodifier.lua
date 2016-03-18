PactModifier = class(Modifier)

--- Params
-- damage_multiplier
-- enhance_effect

PactModifier.attribute_names = {
	"damage", "damage_min", "damage_max"
}

function PactModifier:init(def)
	PactModifier.super.init(self, def)
	
	self.damage_multiplier = def.damage_multiplier
	self.enhance_effect = def.enhance_effect
	self.enhance_sound = def.enhance_sound
	self.slow_effect = def.slow_effect
	self.slow_duration = def.slow_duration
	self.speed_reduction = def.speed_reduction
end

-- Called when the owning pawn casts a spell
function PactModifier:onSpellCast(cast_info)
	local spell_enhanced = false

	-- Check if any of the attributes exist and modify them if they do
	for _, attr_name in pairs(PactModifier.attribute_names) do
		local attr = cast_info:attribute(attr_name)
		if attr ~= nil and attr ~= 0 then
			cast_info:setAttribute(attr_name, attr * self.damage_multiplier)
			spell_enhanced = true
		end
	end

	if spell_enhanced then
		-- Play sounds and effects
		if self.enhance_sound then
			cast_info.caster_actor.unit:EmitSound(self.enhance_sound)
		end

		if self.enhance_effect then
			Effect:create(self.enhance_effect, { location = cast_info.caster_actor.location })
		end

		-- Add the slow effect
		GAME:addModifier(Modifier:new {
			pawn = cast_info.caster_actor,
			time = cast_info.caster_actor:getDebuffDuration(self.slow_duration, cast_info.caster_actor),
			speed_bonus_abs = -self.speed_reduction,
			effect = self.slow_effect,
		})

		GAME:removeModifier(self)
	end
end
