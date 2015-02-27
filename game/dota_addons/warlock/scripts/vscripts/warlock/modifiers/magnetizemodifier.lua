MagnetizeModifier = class(Modifier)

function MagnetizeModifier:init(def)
	MagnetizeModifier.super.init(self, def)
	
    self.force = def.sign * 1000.0
end

function MagnetizeModifier:onPreTick(dt)
	for actor, _ in pairs(GAME.actors) do
		local is_proj = actor:instanceof(Projectile) and not actor:instanceof(MeteorProjectile)
		
		if(is_proj) then
			local dir = self.location - actor.location
			local dist = dir:Length()

			if(is_proj and self.instigator.owner:getAlliance(actor.owner) == Player.ALLIANCE_ENEMY) then
				-- Apply velocity for projectiles that are close
				if(dist <= 600) then
					dir = dir:Normalized()
					actor.velocity = actor.velocity + self.force * (1.5 - dist * dist / 360000) * dir * dt / actor.time_scale
				end
			end
		end
	end
end
