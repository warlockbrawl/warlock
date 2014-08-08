--- module_loader
-- @author Adynathos

BASE_LOG_PREFIX 	= '[WL] '
BASE_MODULES		= {'util', 'class', 'set', 'base_game', 'base_tasks', 'main'}

function log(msg)
	print(BASE_LOG_PREFIX .. msg)
end

function err(msg)
	print('[X] '..msg)
end


function start_file(name)
	log(' module ' .. mod_name)
end

local function load_module(mod_name)
	-- load the module in a monitored environment
	local status, err_msg = pcall(function()
		require(mod_name)
	end)

	if status then
		log(' module ' .. mod_name .. '- OK')
	else
		log(' module ' .. mod_name .. '- FAILED:')
		log('	' .. err_msg)
	end
end

-- local function reload_modules()
-- 	if g_reloadState == nil then
-- 		g_reloadState = {}
-- 		for k,v in pairs( package.loaded ) do
-- 			g_reloadState[k] = v
-- 		end
-- 	else
-- 		for k,v in pairs( package.loaded ) do
-- 			if g_reloadState[k] == nil then
-- 				package.loaded[k] = nil
-- 			end
-- 		end
-- 	end
-- end

-- Heap must be included specially
heap = require('heap')

-- Load all modules
for i, mod_name in pairs(BASE_MODULES) do
	load_module(mod_name)
end

main()
