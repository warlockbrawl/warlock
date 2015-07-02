RushModifier = class(Modifier)

--- Params
-- mod_name
-- absorb_max

function RushModifier:init(def)
	RushModifier.super.init(self, def)

	-- Extract parameters
	self.mod_name = def.mod_name
	self.absorb_remaining = def.absorb_max
	self.bonus_ms = def.initial_speed_bonus
	self.pawn.move_speed = self.pawn.move_speed + self.bonus_ms
	self.pawn:applyStats()
end

-- Called when the modifier is turned on or off
function RushModifier:onToggle(apply)
    if apply then
        -- Remove all link modifiers that have this pawn as target
        LinkModifier.removeFrom(self.pawn)
	else	
		-- Remove the bonus ms
		self.pawn.move_speed = self.pawn.move_speed - self.bonus_ms
		self.bonus_ms = 0
	end
	
	RushModifier.super.onToggle(self, apply)
end

-- Called after all dmg modifiers are applied and kb was dealt, returns dmg change
function RushModifier:modifyDamagePostKB(dmg_info)
	-- Lava and self dmg dont get reduced
	if(dmg_info.source and dmg_info.source ~= self.pawn and self.absorb_remaining > 0) then
		-- Absorb damage
		local absorbed = math.min(self.absorb_remaining, dmg_info.amount * 0.5)
		self.absorb_remaining = self.absorb_remaining - absorbed
		
		-- Turn absorbed damage into move speed
		local added_ms = 1.5 * absorbed
		self.bonus_ms = self.bonus_ms + added_ms
		self.pawn.move_speed = self.pawn.move_speed + added_ms
		self.pawn:applyStats()
		
		-- Change damage text color if absorbing
		if absorbed > 0 then
			dmg_info.text_color = Vector(255, 200, 0)
		end

		return -absorbed
	end
	
	return 0
end
