--- base_commands.lua
-- @author Krzysztof Lis (Adynathos)

function Game:initCommands()
	--Convars:RegisterCommand( "command_example", Dynamic_Wrap(WarlockGameMode, 'cmdExample'), "A console command example", self )

	self.commands = {}
	
	self:registerCommand("respawnarena", function()
		local arena = GAME.arena
		arena:setLayer(0)
		arena:setLayer(20)
	end)
	
	self:registerCommand("spawnproj", function()
		local actor = GAME.pawns:toList()[1]
	
		for i = 1, 200 do
			local dir = Vector(1, 0, 0)

			local projectile_class = SimpleProjectile
			local projectile_speed = 1000
			local damage = 10
			local range = 300
			local radius = 25
			local projectile_effect = "fireball_projectile"

			local proj = projectile_class:new{
				instigator	= actor,
				velocity	= dir*projectile_speed,
				coll_radius = radius,
				lifetime	= range / projectile_speed,
				projectile_effect = projectile_effect,
				damage 		= damage
			}
		end
	end)

    self:registerCommand("actorlist", function()
        local total_actors = 0
        for actor, _ in pairs(GAME.actors) do
            print(actor.name)
            total_actors = total_actors + 1
        end
        print("Total actors:", total_actors)
        print("Actor counter:", ActorCount)
    end)

    self:registerCommand("tasklist", function()
        local tasks = self.taskSet:toList()

        for idx, task in pairs(tasks) do
            print("Task", idx, ":", task.id)
        end

        print("Task heap:", self.taskHeap:getSize())
        print("Task set:", #tasks)
    end)

    self:registerCommand("teamlist", function()
        print("#START TEAM REPORT")
        print("#Teams")
        for team_id, team in pairs(self.teams) do
            print("##Team", team_id, team.id)
            print("##Alive count:", team.alive_count)
            print("##Size:", team.size)
            print("## Players")

            for _, player in pairs(team.players) do
                print("###ID:", player.id)
                print("###IsAlive:", player:isAlive())
            end
        end

        print("#Active Teams")

        for i, team in pairs(self.active_teams) do
            print("##Team ID:", team.id)
        end

        print("#Active team count:", self.active_team_count)
        print("#AliveTeamCount:", #self:getAliveTeams())
        print("#END TEAM REPORT")
    end)

	-- Development only commands
	if Config.DEVELOPMENT then
		self:registerCommand('f', function()
			SendToServerConsole("dota_create_fake_clients")
		end)

		self:registerCommand('s', function()
			-- dont wait and start now
			if GAME.task_start then
				GAME.task_start:cancel()
				GAME:start()
			end
		end)

		self:registerCommand('players', function()
			print("Players:")
			for uid, pl in pairs(GAME.playersByUserid) do
				print("	", pl.name, "	id = ", pl.id, " 	userid = ", pl.userid, " index = ", pl.index)
			end
		end)

		self:registerCommand('projcount', function()
				local actors = GAME:actorsOfType(Projectile)

				local count = 0
				for _ in pairs(actors) do
					count = count + 1
				end

				log("Projectile Count: " .. count)
		end)

		self:registerCommand('resetcd', function()
			GAME.pawns:foreach(function(pawn)
				pawn:resetCooldowns()
			end)
		end)

		self:registerCommand('cam', function(name, dist)
			if(arg[1]) then
				GAME.nativeMode:SetCameraDistanceOverride(tonumber(dist))
			end
		end)

		self:registerCommand('d', function()
			SendToServerConsole("disconnect")
		end)
	
		self:registerCommand('gold', function()
			for uid, pl in pairs(GAME.playersByUserid) do
				pl:addCash(1000)
			end
		end)
	
		self:registerCommand('shield', function()
			for pawn, _ in pairs(GAME.pawns) do
				GAME:addModifier(ShieldModifier:new {
					pawn = pawn,
					time = 10,
					reflect_sound = Shield.reflect_sound,
					reflect_effect = Shield.reflect_name,
					native_mod = Shield.modifier_name
				})
			end
		end)

        self:registerCommand('magnetize', function()
			for pawn, _ in pairs(GAME.pawns) do
		        GAME:addModifier(MagnetizeModifier:new {
			        pawn = pawn,
			        time = 20,
			        sign = -1,
			        end_sound = Magnetize.end_sound,
                    native_mod = Magnetize.native_mod
		        })
			end
		end)

        self:registerCommand('magnetize2', function()
			for pawn, _ in pairs(GAME.pawns) do
				GAME:addModifier(MagnetizeModifier:new {
			        pawn = pawn,
			        time = 20,
			        sign = 1,
			        end_sound = Magnetize.end_sound,
                    native_mod = Magnetize.native_mod
		        })
			end
		end)
	
		self:registerCommand('rush', function()
			for pawn, _ in pairs(GAME.pawns) do
				GAME:addModifier(RushModifier:new {
					pawn = pawn,
					time = 10,
					native_mod = Rush.mod_name,
					absorb_max = 10,
					initial_speed_bonus = Rush.initial_speed_bonus
				})
			end
		end)
	
		self:registerCommand('kill', function()
			for pawn, _ in pairs(GAME.pawns) do
				pawn:die({})
			end
		end)
	
		self:registerCommand('respawn', function()
			for i, player in pairs(GAME.players) do
				if player.pawn then
					player.pawn:respawn()
				end
			end
		end)
	
		self:registerCommand("stats", function()
			for i, player in pairs(GAME.players) do
				if player.pawn then
					local p = player.pawn
					log("-- Stats for player " .. player.name .. " --")
					log("move_speed: " .. tostring(p.move_speed))
					log("max_hp: " .. tostring(p.max_hp))
					log("hp_regen: " .. tostring(p.hp_regen))
					log("mass: " .. tostring(p.mass))
					log("dmg_factor: " .. tostring(p.dmg_factor))
					log("kb_factor: " .. tostring(p.kb_factor))
					log("dmg_reduction: " .. tostring(p.dmg_reduction))
					log("debuff_factor: " .. tostring(p.debuff_factor))
					log("--------------------------")
				end
			end
		end)
	end
end

function Game:registerCommand(cmd, func)
	Convars:RegisterCommand("wl_" .. cmd, func, cmd, 0)
end

