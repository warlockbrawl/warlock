GripModifier = class(Modifier)

--- Params
-- dp_gain
-- grip_mod
-- end_sound

function GripModifier:init(def)
	GripModifier.super.init(self, def)

	-- Extract parameters
	self.dp_gain = def.dp_gain
	self.grip_mod = def.grip_mod
	self.end_sound = def.end_sound
end

-- Called when the modifier is turned on or off
function GripModifier:onToggle(apply)
	if not apply then
		-- Play a sound
		if self.end_sound then
			self.pawn.unit:EmitSound(self.end_sound)
		end
	end
	
	GripModifier.super.onToggle(self, apply)
end

-- Called when the owning pawn casts a spell
function GripModifier:onSpellCast(cast_info)
	self.pawn:increaseKBPoints(self.dp_gain)
end
