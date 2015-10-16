SnowballModifier = class(Modifier)

function SnowballModifier:init(def)
	SnowballModifier.super.init(self, def)

    self.instigator = def.instigator
    self.end_damage = def.end_damage
    self.end_sound = def.end_sound
end

-- Called when the modifier is turned on or off
function SnowballModifier:onToggle(apply)
	if not apply then
		-- Play a sound
		if self.end_sound then
			self.pawn.unit:EmitSound(self.end_sound)
		end

        self.pawn:receiveDamage {
            source = self.instigator,
            amount = self.end_damage
        }
	end
	
	GripModifier.super.onToggle(self, apply)
end

-- Called when the owning pawn casts a spell
function GripModifier:onSpellCast(cast_info)
	self.pawn:increaseKBPoints(self.dp_gain)
end
