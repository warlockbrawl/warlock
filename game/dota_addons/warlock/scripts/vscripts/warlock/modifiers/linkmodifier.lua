LinkModifier = class(Modifier)

--- Params
-- target
-- damage

function LinkModifier:init(def)
	LinkModifier.super.init(self, def)

	-- Extract parameters
	self.target = def.target
	self.damage = def.damage
end

function LinkModifier:onPreTick(dt)
	local dir = (self.target.location - self.pawn.location):Normalized()
	
	self.pawn.velocity += 300 * dir * dt
end
