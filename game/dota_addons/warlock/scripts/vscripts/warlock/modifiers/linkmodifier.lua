LinkModifier = class(Modifier)

--- Params
-- target
-- damage
-- link_beam_effect

LinkModifier.damage_period = 0.2

-- Removes all link modifiers that have a pawn as target (used in rush and shield)
function LinkModifier.removeFrom(pawn)
    local link_mods = GAME:getModifiersOfType(LinkModifier)
    for link_mod, _ in pairs(link_mods) do
        if link_mod.target == pawn then
            GAME:removeModifier(link_mod)
        end
    end
end

function LinkModifier:init(def)
	LinkModifier.super.init(self, def)

	-- Extract parameters
	self.target = def.target
	self.damage = def.damage
	self.pull_accel = def.pull_accel
    self.link_beam_effect = def.link_beam_effect
	
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

	if not apply then
        -- Destroy the beam effect
        if self.link_beam_effect then
            self.link_beam_effect:destroy()
        end

        -- Cancel the damage task if any
        if self.damage_task then
		    self.damage_task:cancel()
        end
	end
end

function LinkModifier:onPreTick(dt)
	local delta = self.target.location - self.pawn.location
	
    -- Check if the link target is close to the linker and end the modifier
	if delta:Length() < 100 then
		GAME:removeModifier(self)
	else
        -- Apply force to move the two together
		local dir = delta:Normalized()
		self.pawn.velocity = self.pawn.velocity + self.pull_accel * dir * dt
	end
end
