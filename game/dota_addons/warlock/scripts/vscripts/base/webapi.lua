WebAPI = class()

function WebAPI:init(base_url, mod_id, mod_version)
    self.base_url = base_url
    self.mod_id = mod_id
    self.mod_version = mod_version
    self.match_token = nil
end

-- Sends a GET request for a path and optionally calls a callback with the received data
-- Handles the JSON status
function WebAPI:send(path, callback)
    local request = CreateHTTPRequest("GET", self.base_url .. path)

    log("WebAPI sending request, path: " .. path)

    request:Send(function(result)
        if not result or result.StatusCode ~= 200 then
            log("WebAPI receive failed")
            return
        end

        log("WebAPI received response for path " .. path)
        PrintTable(result)

        result_data = JSON:decode(result.Body)

        if result_data["status"] ~= "Success" then
            log("WebAPI receive failed, reason: " .. result_data["reason"])
            return
        end

        if callback then
            callback(result_data)
        end
    end)
end

function WebAPI:matchSend(func, path, callback)
    if not self.match_token then
        log("WebAPI tried to call matchSend but no match token was set")
        return
    end

    self:send("/" .. func .. "/" .. self.match_token .. path, callback)
end

-- Requests a new match id
function WebAPI:startMatch()
    self:send("/startmatch/" .. self.mod_id .. "/" .. self.mod_version, function(result)
        self.match_token = result.data.match_token
        log("WebAPI match successfully created, match token: " .. self.match_token)
    end)
end

-- Adds players to the current match id
function WebAPI:addPlayer(steam_id)
    self:matchSend("addplayer", "/" .. steam_id, function(result)
        log("WebAPI successfully added player with steam id " .. steam_id)
    end)
end

-- Ends the current match
function WebAPI:finishMatch()
    self:matchSend("finishmatch", "")
end

function WebAPI:setMatchProperty(key, value)
    self:matchSend("setmatchproperty", "/" .. key .. "/" .. value, function(result)
        log("WebAPI successfully set match property with key " .. key .. " to " .. value)
    end)
end

function WebAPI:setMatchPlayerProperty(steam_id, key, value)
    self:matchSend("setmatchplayerproperty", "/" .. steam_id .. "/" .. key .. "/" .. value, function(result)
        log("WebAPI successfully set match player for " .. steam_id .. "'s property with key " .. key .. " to " .. value)
    end)
end

function WebAPI:setPlayerProperty(steam_id, key, value)
    self:send("/setplayerproperty/" .. self.mod_id .. "/" .. steam_id .. "/" .. key .. "/" .. value, function(result)
        log("WebAPI successfully set player for " .. steam_id .. "'s property with key " .. key .. " to " .. value)
    end)
end

function WebAPI:getPlayerProperty(steam_id, key, callback)
    self:send("/getplayerproperty/" .. self.mod_id .. "/" .. steam_id .. "/" .. key, function(result)
        local property_value = result.data.property_value
        log("WebAPI successfully got player property with steam id " .. steam_id .. " and key " .. key .. ": " .. property_value)
        callback(steam_id, key, result.data.property_value)
    end)
end

--[[-------------------------
        Game Interface
-------------------------]]--

function Game:initWebAPI()
    self.web_api = WebAPI:new(Config.WEB_API_BASE_URL, Config.WEB_API_MOD_ID, Config.WEB_API_MOD_VERSION)
    self.web_api:startMatch()
end
