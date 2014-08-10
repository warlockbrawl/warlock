--- base_commands.lua
-- @author Krzysztof Lis (Adynathos)

function Game:initCommands()
	--Convars:RegisterCommand( "command_example", Dynamic_Wrap(WarlockGameMode, 'cmdExample'), "A console command example", self )

	self.commands = {}

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

		self:registerCommand('resetcd', function(words, pl)
			GAME.pawns:foreach(function(pawn)
				pawn:resetCooldowns()
			end)
		end)

		self:registerCommand('cam', function(words, pl)
			if(words[2]) then
				GAME.nativeMode:SetCameraDistanceOverride(tonumber(words[2]))
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
	
		self:registerCommand('team', function()
			for i, player in pairs(GAME.players) do
				local new_team
				
				if player.team == DOTA_TEAM_GOODGUYS then
					new_team = DOTA_TEAM_BADGUYS
				else
					new_team = DOTA_TEAM_GOODGUYS
				end
				
				player:setTeam(new_team)
				
				log("New team: " .. tostring(player.playerEntity:GetTeam()))
			end
		end)
	end
end

function Game:_command(cmd, pl)
	local words = {}
	for word in cmd:gmatch("%S+") do
		table.insert(words, word)
	end

	if self.commands[words[1]] then
		self.commands[words[1]](words, pl)
	end
end

-- Called when a player says sth in chat
function Game:onChat(pl, text)
	if text:len() > 1 then
		local cmd = text:sub(2)
		-- host can use console commands from here with prefix /
		if text:sub(1,1) == '/' and pl.index == 0 then
			SendToServerConsole(cmd)
		-- standard commands start with -
		elseif text:sub(1,1) == '-' then
			self:_command(cmd, pl)
		end
	end
end

function Game:EventPlayerChat(event)
	-- print('EventPlayerChat ')
	-- PrintTable(event)

	-- Find the player who said that
	local pl =  self.playersByUserid[event.userid]

	if pl ~= nil then
		self:onChat(pl, event.text)
	end
end

function Game:registerCommand(cmd, func)
	self.commands[cmd] = func
	
	if Config.DEVELOPMENT then
		Convars:RegisterCommand("wl_" .. cmd, func, cmd, 0)
	end
end

