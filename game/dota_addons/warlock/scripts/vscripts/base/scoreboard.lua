-- Handles scoreboard UI

Scoreboard = class()

function Scoreboard:init()
    self.net_name = "wl_scoreboard"
end

function Scoreboard:update()
    local score_table = { }
    local damage_table = { }

    for _, player in pairs(GAME.players) do
        score_table[player.id] = player.score
        damage_table[player.id] = player.stats[Player.STATS_DAMAGE]
    end

    CustomNetTables:SetTableValue(self.net_name, "Score", score_table)
    CustomNetTables:SetTableValue(self.net_name, "Damage", damage_table)
end

------------------------
-- Game Interface
------------------------

function Game:initScoreboard()
    self.scoreboard = Scoreboard:new()

    self:addTask {
        id = "update scoreboard",
        period = 1,
        func = function()
            self.scoreboard:update()
        end
    }
end