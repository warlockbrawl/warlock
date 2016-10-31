Awards = class()
Awards.KEY_PARTICLES = "particles"

function Awards:applyPlayerAwards(player)
	-- Particles
	GAME.web_api:getPlayerProperty(player.steam_id, Awards.KEY_PARTICLES, function(steam_id, key, value)
		local particle_id = ParticleManager:CreateParticle(value, PATTACH_CUSTOMORIGIN , nil)
		ParticleManager:SetParticleControlEnt(particle_id, 0, player.pawn.unit, PATTACH_ABSORIGIN_FOLLOW, nil, Vector(0, 0, 0), true)
		print("Added player particle award", value)
	end)
end

function Game:initAwards()
	self.awards = Awards:new()
end
