LinkModifier = class(Modifier)

--- Params
-- target
-- damage
-- link_beam_effect

LinkModifier.damage_period = 0.2

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
					amount = self.damage * LinkModifier.damage_period
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

function LinkModifier:onSpellCast(cast_info)
    -- Remove if target casts shield or rush
    if cast_info.caster_actor == self.target then
        if cast_info.spell:instanceof(Shield) or cast_info.spell:instanceof(Rush) then
            GAME:removeModifier(self)
        end
    end

    -- Remove if linker casts teleport or swap
    if cast_info.caster_actor == self.pawn then
        if cast_info.spell:instanceof(Teleport) or cast_info.spell:instanceof(Swap) then
            GAME:removeModifier(self)
        end
    end
end
