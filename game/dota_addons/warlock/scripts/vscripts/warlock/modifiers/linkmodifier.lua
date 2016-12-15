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
				self.linked:receiveDamage {
					source = self.pawn,
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
    -- Also check if the target has shield or rush

    -- Whether the target is dead
    local stop_link = (self.linked:instanceof(Pawn) and not self.linked.enabled) or not self.linked.exists

    -- Whether the target has shield or rush
    stop_link = stop_link or (self.linked:instanceof(Pawn) and (self.linked:hasModifierOfType(ShieldModifier) or self.linked:hasModifierOfType(RushModifier)))

    -- Whether the target is too close
    local min_range = 100

    -- Bigger for obstacles
    if self.linked:instanceof(Obstacle) then
        min_range = 120
    end

    stop_link = stop_link or delta:Length() < min_range

	if stop_link then
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

    -- Remove if linker casts teleport or swap to lava and target is a pawn
    if self.linked:instanceof(Pawn) then
        if (cast_info.spell.id == Teleport.id or cast_info.spell.id == Swap.id) and not GAME.arena:isLocationSafe(cast_info.target) then
            GAME:removeModifier(self)
        end
    end
end
