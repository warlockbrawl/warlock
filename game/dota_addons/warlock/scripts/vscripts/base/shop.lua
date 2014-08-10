Player.MASTERY_RANGE = 1
Player.MASTERY_DURATION = 2
Player.MASTERY_LIFESTEAL = 3

Abilities = {} -- to detect if player has spell of a specific column
AbilityLevel = {}
MasteryLevel = {}
ItemsPurchased = {} -- to keep track of items
ItemLevel = {}
ItemID = {} -- contains the item hscript (must save, cannot obtain)
WarlockItems = {} -- contains the warlock items


for i = 0, 9 do -- 10 players
	Abilities[i] = {}
	AbilityLevel[i] = {}
	MasteryLevel[i] = {}
	ItemsPurchased[i] = {}
	ItemLevel[i] = {}
	ItemID[i] = {}
	WarlockItems[i] = {}
	Abilities[i][0] = "warlock_emptyslot1" -- 6 columns (D=0,R=1,T=2,E=3,C=4,Y=5)
	Abilities[i][1] = "warlock_emptyslot2"
	Abilities[i][2] = "warlock_emptyslot3"
	Abilities[i][3] = "warlock_emptyslot4"
	Abilities[i][4] = "warlock_emptyslot5"
	Abilities[i][5] = "warlock_emptyslot6"
	AbilityLevel[i][0] = 0
	AbilityLevel[i][1] = 0
	MasteryLevel[i][0] = 0
	MasteryLevel[i][1] = 0
	MasteryLevel[i][2] = 0
	ItemsPurchased[i][0] = "item_warlock_scourge_incarnation" -- these entries correspond to the base item identifier (the icons which appears in shop that are NOT given to players)
	ItemsPurchased[i][1] = "item_warlock_fireball"

	for j = 2, 5 do -- first two items given on pawn init
		ItemsPurchased[i][j] = nil
		AbilityLevel[i][j] = 0
		ItemLevel[i][j] = 0	
		ItemID[i][j] = nil
		WarlockItems[i][j] = nil
	end
end

function createWarlockItem(player_id, slot)
	local item_handle = GAME.players[player_id].pawn.unit:GetItemInSlot(6)
	
	-- Build the mod definition for each level
	local maxlevel = item_handle:GetSpecialValueFor("maxlevel")
	log("Maxlvl:" .. tostring(maxlevel) .. "|" .. ItemsPurchased[player_id][slot])

	local mod_defs = {}
	for i = 1, maxlevel do
		local lvl = i - 1 -- Starts at 0 for GetLevelSpecialValueFor
		mod_defs[i] = {}
		mod_defs[i].dmg_reduction_abs = item_handle:GetLevelSpecialValueFor("dmg_reduction_abs", lvl) or 0
		mod_defs[i].dmg_reduction_rel = item_handle:GetLevelSpecialValueFor("dmg_reduction_rel", lvl) or 0
		mod_defs[i].speed_bonus_abs = item_handle:GetLevelSpecialValueFor("speed_bonus_abs", lvl) or 0
		mod_defs[i].kb_reduction = item_handle:GetLevelSpecialValueFor("kb_reduction", lvl) or 0
		mod_defs[i].hp_bonus = item_handle:GetLevelSpecialValueFor("hp_bonus", lvl) or 0
		mod_defs[i].mass = item_handle:GetLevelSpecialValueFor("mass", lvl) or 0
		mod_defs[i].hp_regen = item_handle:GetLevelSpecialValueFor("hp_regen", lvl) or 0
	end
	
	WarlockItems[player_id][slot] = ModifierItem:new {
		pawn = GAME.players[player_id].pawn,
		maxlevel = maxlevel,
		mod_defs = mod_defs
	}
end

function upgradeWarlockItem(player_id, slot)
	log(tostring(ItemLevel[player_id][slot]))
	if WarlockItems[player_id][slot] ~= nil then
		WarlockItems[player_id][slot]:onUpgrade(ItemLevel[player_id][slot])
	end
end

function purchase(event)
	local func
	local id = event.PlayerID
	local buying_player = GAME.players[id]
	local hero = buying_player.pawn.unit
		
	PrintTable(event)
	if hero == nil then
		log("FATAL ERROR: Nil hero in shop!")
		print("FATAL ERROR: Nil hero in shop!")
	end
		
	local gold = buying_player:getCash()
	local item_handle = GAME.players[id].pawn.unit:GetItemInSlot(6)
	
	func = item_handle:GetSpecialValueFor("type")
	if (func == nil) or (event.itemcost > gold) then
		print(event.itemname)
		print("Error in shop: Undefined item OR fake money purchase")
		local item = hero:GetItemInSlot(6)
		item:RemoveSelf()
		buying_player:updateCash()
		buying_player.pawn:applyStats() -- Stats are reset by dota when items change
		return
	end
	
	if (func == 0) then ----- ITEMS -----
		local index
		for i = 0, 5 do
			if ItemsPurchased[id][i] == event.itemname then -- player wants to upgrade the item
				index = i
			end
		end
		print(event.itemname)
		if index == nil then -- player bought new item
			for i = 0, 5 do
				if ItemsPurchased[id][i] == nil then  -- find first nil (available slot)
					ItemsPurchased[id][i] = event.itemname
					ItemLevel[id][i] = 1
					
					-- Create the item and give it to the hero
					ItemID[id][i] = CreateItem( event.itemname .. "1", hero, hero)
					hero:AddItem(ItemID[id][i])		
					
					-- Remove the gold
					buying_player:addCash(-event.itemcost)
					
					-- Create the WL item with modifiers etc.
					createWarlockItem(id, i)
					
					break -- if it doesn't break, player hasn't got inventory
				end
			end
		elseif ItemLevel[id][index] < item_handle:GetSpecialValueFor("maxlevel") then -- upgrade
			
			-- Increase item level
			ItemLevel[id][index] = ItemLevel[id][index]+1
			
			-- Remove the existing item and add the next level item
			ItemID[id][index]:RemoveSelf()
			ItemID[id][index] = CreateItem( event.itemname .. tostring (ItemLevel[id][index]), hero, hero)
			hero:AddItem(ItemID[id][index])
			
			-- Remove the gold
			buying_player:addCash(-event.itemcost)
			
			-- Upgrade the WL item
			upgradeWarlockItem(id, index)
		else
			print("Warning: Max item level exceeded")
		end
	elseif (func == 1) then ----- ABILITIES -----
		local col = item_handle:GetSpecialValueFor("column")
		if AbilityLevel[id][col] == 0 then
			hero:RemoveAbility(Abilities[id][0])
			hero:RemoveAbility(Abilities[id][1])
			hero:RemoveAbility(Abilities[id][2])
			hero:RemoveAbility(Abilities[id][3])
			hero:RemoveAbility(Abilities[id][4])
			hero:RemoveAbility(Abilities[id][5])
			Abilities[id][col] = string.sub(event.itemname,6) -- define the ability in the global ability column
			AbilityLevel[id][col] = 1
			hero:AddAbility(Abilities[id][0])
			hero:AddAbility(Abilities[id][1])
			hero:AddAbility(Abilities[id][2])
			hero:AddAbility(Abilities[id][3])
			hero:AddAbility(Abilities[id][4])
			hero:AddAbility(Abilities[id][5])
			local abil
			abil = hero:FindAbilityByName(Abilities[id][0])
			abil:SetLevel(AbilityLevel[id][0])
			abil = hero:FindAbilityByName(Abilities[id][1])
			abil:SetLevel(AbilityLevel[id][1])
			abil = hero:FindAbilityByName(Abilities[id][2])
			abil:SetLevel(AbilityLevel[id][2])
			abil = hero:FindAbilityByName(Abilities[id][3])
			abil:SetLevel(AbilityLevel[id][3])
			abil = hero:FindAbilityByName(Abilities[id][4])
			abil:SetLevel(AbilityLevel[id][4])
			abil = hero:FindAbilityByName(Abilities[id][5])
			abil:SetLevel(AbilityLevel[id][5])
			buying_player:addCash( -event.itemcost)
		end
	elseif (func == 2) then ----- MASTERIES -----
		local maxlevel = item_handle:GetSpecialValueFor("maxlevel")
		local index = item_handle:GetSpecialValueFor("index") -- 0=duration 1=range 2=lifesteal

		if MasteryLevel[id][index] < maxlevel then -- upgrade
			buying_player.mastery_factor[buying_player.index] = buying_player.mastery_factor[buying_player.index] + (item_handle:GetLevelSpecialValueFor('stats', MasteryLevel[id][index]))/100.0
			MasteryLevel[id][index] = MasteryLevel[id][index]+1
			print("upgraded mastery")
			print(buying_player.mastery_factor[buying_player.MASTERY_DURATION])
			print(buying_player.mastery_factor[buying_player.MASTERY_RANGE])
			print(buying_player.mastery_factor[buying_player.MASTERY_LIFESTEAL])
			buying_player:addCash( -event.itemcost)
		end
	else
		print("Error: Shop type not found")
	end
	
	local item = hero:GetItemInSlot(6)
	item:RemoveSelf()

	if buying_player then
		buying_player:updateCash() -- update gold cost (needed if the purchase is not allowed or fails)
		buying_player.pawn:applyStats() -- Stats are reset by dota when items change
	end
	
end

function Game:EventShop(event)
	PrintTable(event)
	purchase(event)
end

--- Find the player that performed a skill upgrade
local function find_upgrading_player(upgrade_event)
	for id, player in pairs(GAME.players) do
		for slot = 0, 5 do
			local abil_name = Abilities[player.id][slot]
			-- the upgraded ability must match the one from event
			if abil_name == upgrade_event.abilityname then
				local abil = player.pawn.unit:FindAbilityByName(abil_name)

				if abil ~= nil then
					local level = abil:GetLevel()
					if level ~= AbilityLevel[player.id][slot] then
						return player
					end
				end
			end
		end
	end
end

function Game:EventUpgrade(event)
	print('Upgraded ability')
	local buying_player =  find_upgrading_player(event)
	local id = buying_player.id
	local hero = buying_player.pawn.unit
	local abil = hero:FindAbilityByName(event.abilityname)
	local cost
	PrintTable(event)

	for i = 0, 5 do
		if event.abilityname == Abilities[id][i] then
			cost = abil:GetLevelSpecialValueFor('upgrade_cost',AbilityLevel[id][i]-1)
			gold = buying_player:getCash()

			if gold >= cost then
				AbilityLevel[id][i] = AbilityLevel[id][i]+1
				buying_player:addCash(-cost)
			else
				print("Not enough gold")
				print(cost)
			end
			abil:SetLevel(AbilityLevel[id][i])
			hero:SetAbilityPoints(1) -- used ability point. Get one more
			break
		end
	end

	if buying_player then
		-- just to be sure
		buying_player:updateCash()
	end
end
