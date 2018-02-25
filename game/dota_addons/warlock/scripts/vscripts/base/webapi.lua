WebAPI = class()

function WebAPI:init(base_url, mod_id, mod_version)
    self.base_url = base_url
    self.mod_id = mod_id
    self.mod_version = mod_version
    self.match_token = nil
end

-- Sends a POST request for a path and optionally calls a callback with the received data
-- Handles the JSON status
function WebAPI:send(path, params, callback)
    local request = CreateHTTPRequestScriptVM("POST", self.base_url .. "/" .. path)

    log("WebAPI sending request, path: " .. path .. " and params:")
    PrintTable(params)

    for k, v in pairs(params) do
        request:SetHTTPRequestGetOrPostParameter(tostring(k), tostring(v))
    end

    request:Send(function(result)
        if not result or result.StatusCode ~= 200 then
            local log_msg = "WebAPI receive failed"
            if result then
                log_msg = log_msg .. " with code " .. tostring(result.StatusCode)
            end
            log(log_msg)
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

function WebAPI:matchSend(func, params, callback)
    if not self.match_token then
        log("WebAPI tried to call matchSend but no match token was set")
        return
    end

    params.match_token = self.match_token

    self:send(func, params, callback)
end

-- Requests a new match id
function WebAPI:startMatch()
    self:send("startmatch", {
        mod_name = self.mod_id,
        mod_version = self.mod_version,
        dedicated_server_key = GetDedicatedServerKey(Config.DEDICATED_SERVER_VERSION),
    }, function(result)
        self.match_token = result.data.match_token
        log("WebAPI match successfully created, match token: " .. self.match_token)
    end)
end

-- Adds players to the current match id
function WebAPI:addPlayer(steam_id)
    self:matchSend("addplayer", {
        steam_id = steam_id,
    }, function(result)
        log("WebAPI successfully added player with steam id " .. steam_id)
    end)
end

-- Ends the current match
function WebAPI:finishMatch(winners)
    local winner_str = ""
    for _, player in pairs(winners) do
        winner_str = winner_str .. tostring(player.steam_id) .. ","
    end

    self:matchSend("finishmatch", {winners=winner_str}, nil)
end

function WebAPI:setMatchProperty(key, value)
    self:matchSend("setmatchproperty", {
        property_name = key,
        property_value = value,
    }, function(result)
        log("WebAPI successfully set match property with key " .. key .. " to " .. value)
    end)
end

function WebAPI:setMatchPlayerProperty(steam_id, key, value)
    self:matchSend("setmatchplayerproperty", {
        steam_id = steam_id,
        property_name = key,
        property_value = value,
    }, function(result)
        log("WebAPI successfully set match player for " .. steam_id .. "'s property with key " .. key .. " to " .. value)
    end)
end

function WebAPI:setPlayerProperty(steam_id, key, value)
    self:send("setplayerproperty", {
        mod_name = self.mod_id,
        steam_id = steam_id,
        property_name = key,
        property_value = value,    
    }, function(result)
        log("WebAPI successfully set player for " .. steam_id .. "'s property with key " .. key .. " to " .. value)
    end)
end

function WebAPI:getPlayerProperty(steam_id, key, callback)
    self:send("getplayerproperty", {
        mod_name = self.mod_id,
        steam_id = steam_id,
        property_name = key
    }, function(result)
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
