WebAPI = class()

-- API base url
WebAPI.BASE_URL = "http://api.warlockbrawl.com"

-- API mod id
WebAPI.MOD_ID = "warlock"

-- API function paths
WebAPI.PATH_NEW_MATCH = "/newmatch/"
WebAPI.PATH_ADD_PLAYERS = "/addplayers/" -- <matchid>/repeated <steamid>
WebAPI.PATH_SET_PLAYER_PROPERTY = "/setplayerproperty/" -- /<matchid>/<steamid>/<key>/<value>
WebAPI.PATH_SET_MATCH_PROPERTY = "/setmatchproperty/" -- /<matchid>/<key>/<value>
WebAPI.PATH_END_MATCH = "/endmatch/" -- <matchid>/repeated <steamid> of winners

function WebAPI:init()
    self.match_id = nil
end

-- Sends a GET request for a path and optionally calls a callback with the received data
function WebAPI.send(path, callback)
    local request = CreateHTTPRequest("GET", WebAPI.BASE_URL .. path)

    log("Sending request, path: " .. path)

    request:Send(function(result)
        if not result or result.StatusCode ~= 200 or result.Body == "error" then
            warning("Web API receive failed")
            return
        end

        log("Web API received")
        PrintTable(result)

        if callback then
            callback(result.Body)
        end
    end)
end

-- Sends per-match data
function WebAPI:sendMatchData(func, data, callback)
    if not self.match_id then
        warning("WebAPI tried to send match data but no match id was set")
    end

    WebAPI.send(func .. self.match_id .. "/" .. data, callback)
end

-- Requests a new match id
function WebAPI:newMatch()
    WebAPI.send(WebAPI.PATH_NEW_MATCH .. WebAPI.MOD_ID, function(result)
        if result:len() ~= 32 then
            warning("Web API received invalid match id at new match")
            return
        end

        self.match_id = result
    end)
end

-- Adds players to the current match id
function WebAPI:addPlayers(steam_ids)
    local data = ""

    for _, steam_id in pairs(steam_ids) do
        data = data .. steam_id .. "/"
    end

    self:sendMatchData(WebAPI.PATH_ADD_PLAYERS, data)
end

-- Sets a players property for the current match id
function WebAPI:setPlayerProperty(steam_id, key, value)
    self:sendMatchData(WebAPI.PATH_SET_PLAYER_PROPERTY, steam_id .. "/" .. key .. "/" .. value)
end

-- Sets a property for the current match
function WebAPI:setMatchProperty(key, value)
    self:sendMatchData(WebAPI.PATH_SET_MATCH_PROPERTY, key .. "/" .. value)
end

-- Ends the current match and declares the winners
function WebAPI:endMatch(winner_steam_ids)
    local data = ""

    for _, steam_id in pairs(steam_ids) do
        data = data .. steam_id .. "/"
    end

    self:sendMatchData(WebAPI.PATH_END_MATCH, data)
end

--[[-------------------------
        Game Interface
-------------------------]]--

function Game:initWebAPI()
    self.web_api = WebAPI:new()
    self.web_api:newMatch()
end
