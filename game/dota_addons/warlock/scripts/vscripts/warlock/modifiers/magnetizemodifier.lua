MagnetizeModifier = class(Modifier)

function MagnetizeModifier:init(def)
	MagnetizeModifier.super.init(self, def)
	
    self.end_sound = def.end_sound
    self.sign = def.sign
end

function MagnetizeModifier:onPreTick(dt)
	for actor, _ in pairs(GAME.actors) do
		local is_proj = actor:instanceof(Projectile) and not actor:instanceof(MeteorProjectile)
		
		if(is_proj) then
			local dir = self.pawn.location - actor.location
			local dist = dir:Length()

			if(is_proj and self.pawn.owner:getAlliance(actor.owner) == Player.ALLIANCE_ENEMY) then
				if(dist <= 300.0) then
					dir = self.sign * dir:Normalized()
                    local f = 0.2 * (1.0 - dist * dist / 90000)
					actor.velocity = (1.0 - f) * actor.velocity + f * actor.velocity:Length() * dir
				end
			end
		end
	end
end

-- Called when the modifier is turned on or off
function MagnetizeModifier:onToggle(apply)
	if not apply then
		-- Play a sound
		if self.end_sound then
			self.pawn.unit:EmitSound(self.end_sound)
		end
	end
	
	MagnetizeModifier.super.onToggle(self, apply)
end
