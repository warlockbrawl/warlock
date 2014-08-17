--- Warlock arena, shrink and damage
-- @author Krzysztof Lis (Adynathos)

Arena = class()
Arena.ARENA_TILE_SIZE 	= 192
Arena.ARENA_TILE_Z 		= 71.5
Arena.ARENA_MAX_COORD	= 8
Arena.SHRINK_PERIOD 	= 9
Arena.DAMAGE_PERIOD 	= 0.25
Arena.DAMAGE_PER_SECOND = 100
Arena.DAMAGE_KB_POINT_FACTOR = 0.5
Arena.LAYERS = {
	{{x = 0, y = 0}},
	{{x = 0, y = 1},	{x = 0, y = -1},	{x = 1, y = 0},		{x = -1, y = 0}},
	{{x = -1, y = 1},	{x = 1, y = -1},	{x = 1, y = 1},		{x = -1, y = -1}},
	{{x = 0, y = -2},	{x = 2, y = 0},		{x = -2, y = 0},	{x = 0, y = 2}},
	{{x = 1, y = 2},	{x = -2, y = 1},	{x = -1, y = 2},	{x = 2, y = -1},	{x = -1, y = -2},	{x = 2, y = 1},	{x = -2, y = -1},	{x = 1, y = -2}},
	{{x = 2, y = -2},	{x = -2, y = -2},	{x = -2, y = 2},	{x = 2, y = 2}},
	{{x = 3, y = 0},	{x = 0, y = 3},		{x = 0, y = -3},	{x = -3, y = 0}},
	{{x = 1, y = 3},	{x = -1, y = 3},	{x = 3, y = 1},		{x = -3, y = -1},	{x = -3, y = 1},	{x = -1, y = -3},	{x = 3, y = -1},	{x = 1, y = -3}},
	{{x = 2, y = -3},	{x = -2, y = 3},	{x = 3, y = 2},		{x = 3, y = -2},	{x = -3, y = -2},	{x = 2, y = 3},	{x = -2, y = -3},	{x = -3, y = 2}},
	{{x = -3, y = -3},	{x = 3, y = -3},	{x = 3, y = 3},		{x = -3, y = 3}},
	{{x = 4, y = 0},	{x = 0, y = -4},	{x = -4, y = 0},	{x = 0, y = 4}},
	{{x = -4, y = -1},	{x = 1, y = 4},		{x = -1, y = -4},	{x = -4, y = 1},	{x = 1, y = -4},	{x = -1, y = 4},	{x = 4, y = 1},	{x = 4, y = -1}},
	{{x = 2, y = -4},	{x = -2, y = -4},	{x = 4, y = -2},	{x = -4, y = 2},	{x = 4, y = 2},	{x = -2, y = 4},	{x = 2, y = 4},	{x = -4, y = -2}},
	{{x = 4, y = -3},	{x = -3, y = -4},	{x = -4, y = -3},	{x = -4, y = 3},	{x = 3, y = -4},	{x = 4, y = 3},	{x = -3, y = 4},	{x = 3, y = 4}},
	{{x = 4, y = -4},	{x = -4, y = 4},	{x = -4, y = -4},	{x = 4, y = 4}},
	{{x = -5, y = 0},	{x = 0, y = -5},	{x = 0, y = 5},		{x = 5, y = 0}},
	{{x = -1, y = -5},	{x = 5, y = -1},	{x = -5, y = 1},	{x = -1, y = 5},	{x = 1, y = -5},	{x = 1, y = 5},	{x = -5, y = -1},	{x = 5, y = 1}},
	{{x = -2, y = -5},	{x = 5, y = -2},	{x = -5, y = -2},	{x = 5, y = 2},		{x = -2, y = 5},	{x = 2, y = 5},	{x = 2, y = -5},	{x = -5, y = 2}},
	{{x = -5, y = -3},	{x = -3, y = 5},	{x = 3, y = 5},		{x = -5, y = 3},	{x = 5, y = -3},	{x = 5, y = 3},	{x = 3, y = -5},	{x = -3, y = -5}},
	{{x = -4, y = 5},	{x = 5, y = 4},		{x = 4, y = 5},		{x = 4, y = -5},	{x = -5, y = 4},	{x = -4, y = -5},	{x = 5, y = -4},	{x = -5, y = -4}},
	{{x = -5, y = -5},	{x = 5, y = -5},	{x = 5, y = 5},		{x = -5, y = 5}},
	{{x = 0, y = 6},	{x = 0, y = -6},	{x = 6, y = 0},		{x = -6, y = 0}},
	{{x = -1, y = -6},	{x = -6, y = 1},	{x = 1, y = -6},	{x = 6, y = 1},		{x = 6, y = -1},	{x = -6, y = -1},	{x = 1, y = 6},	{x = -1, y = 6}},
	{{x = -2, y = 6},	{x = -2, y = -6},	{x = 2, y = 6},		{x = 6, y = -2},	{x = 6, y = 2},	{x = -6, y = -2},	{x = -6, y = 2},	{x = 2, y = -6}},
	{{x = -3, y = 6},	{x = 6, y = -3},	{x = -6, y = -3},	{x = -6, y = 3},	{x = 6, y = 3},	{x = 3, y = 6},	{x = 3, y = -6},	{x = -3, y = -6}},
	{{x = 6, y = 4},	{x = 4, y = 6},		{x = 6, y = -4},	{x = -6, y = -4},	{x = 4, y = -6},	{x = -6, y = 4},	{x = -4, y = -6},	{x = -4, y = 6}},
	{{x = -5, y = -6},	{x = -6, y = -5},	{x = 5, y = 6},		{x = -5, y = 6},	{x = -6, y = 5},	{x = 5, y = -6},	{x = 6, y = -5},	{x = 6, y = 5}},
	{{x = -6, y = -6},	{x = -6, y = 6},	{x = 6, y = 6},		{x = 6, y = -6}}
}
Arena.MAX_LAYER 		= #Arena.LAYERS
Arena.TILE_MODELS = {
	"models/tile01.vmdl",
	"models/tile02.vmdl",
	"models/tile03.vmdl"
}

Arena.tile_model = Arena.TILE_MODELS[1]

function Arena:init()
	-- self.tiles = 2 dimensional array indexed by x and y in the grid
	-- self.tiles[x] = row on that x
	self.tiles = {}

	-- initialize the rows
	for x = -self.ARENA_MAX_COORD, self.ARENA_MAX_COORD do
		self.tiles[x] = {}
	end

	--
	self.current_layer = 0

	GAME:addTask{
		id='arena_damage',
		period=self.DAMAGE_PERIOD,
		func = function()
			local dmg_info = {
				amount = self.DAMAGE_PER_SECOND * self.DAMAGE_PERIOD,
				knockback_vulnerability_factor = self.DAMAGE_KB_POINT_FACTOR
			}

			for pawn, _ in pairs(GAME.pawns) do
				-- Apply or remove a burn effect
				local on_lava = not self:isLocationSafe(pawn.location)
				if(pawn.on_lava and not on_lava) then
					pawn.on_lava = false
					pawn:removeNativeModifier("modifier_jakiro_dual_breath_burn")
				elseif(not pawn.on_lava and on_lava) then
					pawn.on_lava = true
					pawn:addNativeModifier("modifier_jakiro_dual_breath_burn")
				end
				
				if pawn.enabled and on_lava then
					pawn:receiveDamage(dmg_info)
				end
			end
		end
	}
end

function Arena:getTileStatus(grid_x, grid_y)
	if math.abs(grid_x) > self.ARENA_MAX_COORD or math.abs(grid_y) > self.ARENA_MAX_COORD then
		return false
	end

	return (self.tiles[grid_x][grid_y] ~= nil)
end

function Arena:setTileStatus(grid_x, grid_y, status)
	local tile = self.tiles[grid_x][grid_y]

	if tile ~= nil and (not status) then
		-- remove the tile
		tile:Destroy()
		self.tiles[grid_x][grid_y] = nil

	elseif (tile == nil) and status then
		-- create a new tile

		tile = Entities:CreateByClassname("prop_dynamic")
		tile:SetAbsOrigin(Vector(grid_x*self.ARENA_TILE_SIZE, grid_y*self.ARENA_TILE_SIZE, self.ARENA_TILE_Z ))
		tile:SetAngles(0,math.random(0, 3)*90,0)
		tile:SetModel(self.tile_model)

		self.tiles[grid_x][grid_y] = tile
	end
end

function Arena:setLayer(layer_index)
	layer_index = math.min(layer_index, self.MAX_LAYER)
	layer_index = math.max(layer_index, 0)

	-- increase the layer -> create tiles
	while layer_index > self.current_layer do
		self.current_layer = self.current_layer + 1

		local layer_addrs = self.LAYERS[self.current_layer]
		if layer_addrs then
			for i, point in pairs(layer_addrs) do
				self:setTileStatus(point.x, point.y, true)
			end
		end
	end

	-- decrease the layer -> remove tiles
	while layer_index < self.current_layer do
		local layer_addrs = self.LAYERS[self.current_layer]
		if layer_addrs then
			for i, point in pairs(layer_addrs) do
				self:setTileStatus(point.x, point.y, false)
			end
		end

		self.current_layer = self.current_layer - 1
	end
end

function Arena:setAutoShrink(status)
	if self.task_shrink then
		self.task_shrink:cancel()
		self.task_shrink = nil
	end

	if status then
		self.task_shrink = GAME:addTask{id='arena_shrink', period=self.SHRINK_PERIOD, func=function()
			self:setLayer(self.current_layer - 1)
		end}
	end
end


function Arena:isLocationSafe(location)
	local grid_x = math.floor( location.x / self.ARENA_TILE_SIZE + 0.5 )
	local grid_y = math.floor( location.y / self.ARENA_TILE_SIZE + 0.5 )

	return self:getTileStatus(grid_x, grid_y)
end

function Arena:setPlatformType(platform)
	Arena.tile_model = Arena.TILE_MODELS[platform]
end

function Game:initArena()
	self.arena = Arena:new()
end

