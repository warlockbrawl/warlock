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
		FireGameEvent("w_update_scoreboard", {
			id		= id,
			points	= pl.score,
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
