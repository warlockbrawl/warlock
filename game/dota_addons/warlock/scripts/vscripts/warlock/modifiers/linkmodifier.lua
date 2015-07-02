LinkModifier = class(Modifier)

--- Params
-- damage
-- pull_accel
-- link_beam_effect
-- linked (the linked pawn)
-- pull_linked (whether linked should be pulled to pawn)

LinkModifier.damage_period = 0.2

function LinkModifier:init(def)
	LinkModifier.super.init(self, def)

	-- Extract parameters
	self.damage = def.damage
	self.pull_accel = def.pull_accel
    self.link_beam_effect = def.link_beam_effect
    self.linked = def.linked
    self.pull_linked = def.pull_linked

    if self.pull_linked then
        self.pulled_pawn = self.linked
    else
        self.pulled_pawn = self.pawn
    end
	
	-- Set up a seperate task for dealing damage that ticks slower
	if self.damage then
		self.damage_task = GAME:addTask {
			period = LinkModifier.damage_period,
			func = function()
				self.pawn:receiveDamage {
					source = self.linked,
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
    LinkModifier.super.onPreTick(self, dt)

	local delta = self.linked.location - self.pawn.location
	
    -- Check if the link target is close to the linker and end the modifier
    -- Also check that the pulled pawn is still alive
	if (self.pull_linked and not self.linked.enabled) or delta:Length() < 100 then
		GAME:removeModifier(self)
	else
        -- Apply force to move the pulled pawn
		local dir = delta:Normalized()
        
        if self.pull_linked then
            dir = -dir
        end

		self.pulled_pawn.velocity = self.pulled_pawn.velocity + self.pull_accel * dir * dt
	end
end

function LinkModifier:onSpellCast(cast_info)
    LinkModifier.super.onSpellCast(self, cast_info)

    -- Remove if target casts shield or rush
    if cast_info.caster_actor == self.linked then
        if cast_info.spell.id == Shield.id or cast_info.spell.id == Rush.id then
            GAME:removeModifier(self)

            -- Can return early
            return
        end
    end

    -- Remove if linker casts teleport or swap
    if cast_info.caster_actor == self.pawn then
        if cast_info.spell.id == Teleport.id or cast_info.spell.id == Swap.id then
            GAME:removeModifier(self)
        end
    end
end
