LinkModifier = class(Modifier)

--- Params
-- target
-- damage

LinkModifier.damage_period = 0.2

function LinkModifier:init(def)
	LinkModifier.super.init(self, def)

	-- Extract parameters
	self.target = def.target
	self.damage = def.damage
	self.pull_accel = def.pull_accel
	
	-- Set up a seperate task for dealing damage that ticks slower
	if self.damage then
		self.damage_task = GAME:addTask {
			period = LinkModifier.damage_period,
			func = function()
				self.pawn:receiveDamage {
					source = self.target,
					amount = self.damage * dt
				}
			end
		}
	end
end

-- Called when the modifier is turned on or off
function LinkModifier:onToggle(apply)
	LinkModifier.super.onToggle(self, apply)

	if not apply and self.damage_task then
		self.damage_task:cancel()
	end
end

function LinkModifier:onPreTick(dt)
	local delta = self.target.location - self.pawn.location
	
	if delta:Length() < 100 then
		GAME:removeModifier(self)
	else
		local dir = delta:Normalized()
		self.pawn.velocity = self.pawn.velocity + self.pull_accel * dir * dt
	end
end
