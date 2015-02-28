RockPillar = Spell:new{id='warlock_rockpillar'}
RockPillar.spawn_effect = 'rockpillar_spawn'
RockPillar.death_effect = 'rockpillar_death'
RockPillar.spawn_sound = 'RockPillar.Spawn'
RockPillar.death_sound = 'RockPillar.Death'
RockPillar.obstacle_def = { model = "models/props_rock/riveredge_rock006a.vmdl", elasticity = 0.5, radius = 90 }

function RockPillar:onCast(cast_info)
    local target = cast_info.target
    local range = cast_info:attribute('range')
    local caster_loc = cast_info.caster_actor.location
	local dir = target - caster_loc
	dir.z = 0
	local dist = dir:Length()
	dir = dir:Normalized()
	
	-- Restrict the range
	if(dist > range) then
		dist = range
		target = caster_loc + dir * dist
	end

    -- Spawn the obstacle

	local obstacle = GAME:addObstacleByDef{ location = target, obstacle_def = RockPillar.obstacle_def }

    -- Create spawn sound and effect

    if RockPillar.spawn_effect then
	    Effect:create(RockPillar.spawn_effect, { location=obstacle.location })
    end

    if RockPillar.spawn_sound then
        obstacle.model_unit:EmitSound(RockPillar.spawn_sound)
    end

    -- Add obstacle to temp actors so it gets destroyed on new rounds
    GAME:addTempActor(obstacle)

    -- Add a timer to destroy the obstacle
    GAME:addTask {
        time = cast_info:attribute('duration'),
        func = function()
            GAME:removeObstacle(obstacle)

            -- Obstacle might have already been destroyed by players or on new rounds
            if obstacle.exists then
                if RockPillar.death_effect then
		            Effect:create(RockPillar.death_effect, { location=obstacle.location })
	            end

                if RockPillar.death_sound then
                    obstacle.model_unit:EmitSound(RockPillar.death_sound)
                end
            end
        end
    }
end

-- effects

Effect:register('rockpillar_spawn', {
	class				= ParticleEffect,
    effect_name         = "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_dust.vpcf"
})

Effect:register('rockpillar_death', {
	class				= ParticleEffect,
	effect_name			= "particles/econ/items/undying/undying_manyone/undying_pale_tower_destruction_dust_hit.vpcf"
})
