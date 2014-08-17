-- UI class, handles updating the UI

UserInterface = class()
UserInterface.update_period = 2.0

function UserInterface:init()
	GAME:addTask {
		id		='ui update',
		period	= UserInterface.update_period,
		func	= function()
			self:update()
		end
	}
end

function UserInterface:update()
	for id, pl in pairs(GAME.players) do
		local score = pl.score
		
		-- Display team score instead of team score if use_team_score is set
		if GAME.mode and GAME.mode.win_condition and GAME.mode.win_condition.use_team_score then
			if pl.team then
				score = pl.team.score
			end
		end
		
		FireGameEvent("w_update_scoreboard", {
			id		= id,
			points	= score,
			dmg		= pl.stats[Player.STATS_DAMAGE]
		})
	end
end

------------------------
-- Game Interface
------------------------

function Game:initUserInterface()
	self.user_interface = UserInterface:new()
end
