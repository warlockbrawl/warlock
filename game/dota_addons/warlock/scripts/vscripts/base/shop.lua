-- Handles shop

Shop = class()

-- Masteries

Shop.MASTERY_MAX_LEVEL = 6

-- How much each mastery increases its respective factor
Shop.MASTERY_GAIN = {
    { 0.10, 0.08, 0.07, 0.06, 0.05, 0.04 },
    { 0.12, 0.10, 0.09, 0.08, 0.07, 0.06 },
    { 0.09, 0.08, 0.07, 0.06, 0.05, 0.04 }
}

Shop.MASTERY_COST = 5 -- The cost of upgrading a mastery
Shop.MASTERY_ALL_COST = 13 -- The cost of upgrading all masteries at once

-- Spells

Shop.SPELL_MAX_LEVEL = 7

Shop.SPELL_DEFS = {
    -- D
    { name = "Boomerang", column = 1, ability_name = "warlock_boomerang", buy_cost = 11, upgrade_cost = { 7, 8, 9, 10, 11, 12 } },
    { name = "Lightning", column = 1, ability_name = "warlock_lightning", buy_cost = 11, upgrade_cost = { 8, 9, 10, 11, 12, 13 } },
    { name = "Homing", column = 1, ability_name = "warlock_homing", buy_cost = 11, upgrade_cost = { 8, 9, 10, 11, 12, 13 } },

    -- R
    { name = "Teleport", column = 2, ability_name = "warlock_teleport", buy_cost = 12, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Thrust", column = 2, ability_name = "warlock_thrust", buy_cost = 11, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Swap", column = 2, ability_name = "warlock_swap", buy_cost = 11, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },

    -- T
    { name = "Cluster", column = 3, ability_name = "warlock_cluster", buy_cost = 14, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Drain", column = 3, ability_name = "warlock_drain", buy_cost = 14, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Bouncer", column = 3, ability_name = "warlock_bouncer", buy_cost = 14, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },

    -- E
    { name = "Windwalk", column = 4, ability_name = "warlock_windwalk", buy_cost = 14, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Meteor", column = 4, ability_name = "warlock_meteor", buy_cost = 14, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Splitter", column = 4, ability_name = "warlock_splitter", buy_cost = 15, upgrade_cost = { 7, 8, 9, 10, 11, 12 } },
    
    -- C
    { name = "Shield", column = 5, ability_name = "warlock_shield", buy_cost = 12, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Rush", column = 5, ability_name = "warlock_rush", buy_cost = 12, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Alteration", column = 5, ability_name = "warlock_alteration", buy_cost = 11, upgrade_cost = { 5, 6, 7, 8, 9, 10 } },

    -- Y
    { name = "Gravity", column = 6, ability_name = "warlock_gravity", buy_cost = 12, upgrade_cost = { 7, 8, 9, 10, 11, 12 } },
    { name = "Grip", column = 6, ability_name = "warlock_grip", buy_cost = 12, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Warpzone", column = 6, ability_name = "warlock_warpzone", buy_cost = 12, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
    { name = "Magnetize", column = 6, ability_name = "warlock_magnetize", buy_cost = 14, upgrade_cost = { 5, 6, 7, 8, 9, 10 } },
    { name = "Rockpillar", column = 6, ability_name = "warlock_rockpillar", buy_cost = 13, upgrade_cost = { 5, 6, 7, 8, 9, 10 } },
    { name = "Link", column = 6, ability_name = "warlock_link", buy_cost = 12, upgrade_cost = { 6, 7, 8, 9, 10, 11 } },
}

-- Items

Shop.MAX_ITEMS = 6

Shop.ITEM_DEFS = {
    { name = "Scourge", item_name = "item_warlock_scourge", buy_cost = 7, max_level = 3, mod_defs = { {}, {}, {} } },
    { name = "Fireball", item_name = "item_warlock_fireball", buy_cost = 0, max_level = 1, mod_defs = { {} } },
    { name = "Ring of Health", item_name = "item_warlock_ring_of_health", buy_cost = 4, max_level = 5, mod_defs = { { hp_bonus = 100 }, { hp_bonus = 190 }, { hp_bonus = 270 }, { hp_bonus = 340 }, { hp_bonus = 400 } } },
    { name = "Cursed Ring", item_name = "item_warlock_cursed_ring", buy_cost = 4, max_level = 2, mod_defs = { { hp_bonus = 100, kb_reduction = 0.15, debuff_factor = 0.25 }, { hp_bonus = 200, kb_reduction = 0.15, debuff_factor = 0.30 } } },
    { name = "Cape", item_name = "item_warlock_cape", buy_cost = 3, max_level = 3, mod_defs = { { hp_regen = 2 }, { hp_regen = 3.5 }, { hp_regen = 4.5 } } },
    { name = "Armor", item_name = "item_warlock_armor", buy_cost = 6, max_level = 3, mod_defs = { { kb_reduction = 0.12 }, { kb_reduction = 0.18 }, { kb_reduction = 0.22 } } },
    { name = "Boots", item_name = "item_warlock_boots", buy_cost = 5, max_level = 3, mod_defs = { { speed_bonus_abs = 18 }, { speed_bonus_abs = 29 }, { speed_bonus_abs = 40 } } },
    { name = "Pocket Watch", item_name = "item_warlock_pocket_watch", buy_cost = 2, max_level = 2, mod_defs = { { debuff_factor = -0.35 }, { debuff_factor = -0.45 } } },
}

function Shop:init()
    self.mastery_level = {}
    self.spell_level = {}
    self.spells = {}
    self.item_level = {}
    self.items = {}
    self.wl_items = {} -- Items of the item class
end

function Shop:addPlayer(player)
    log("Added player to shop with id", player.player_id)
    self.mastery_level[player] = { 0, 0, 0 }
    self.spell_level[player] = { 0, 0, 0, 0, 0, 0 }
    self.spells[player] = { nil, nil, nil, nil, nil, nil }
    self.item_level[player] = { 0, 0, 0, 0, 0, 0 }
    self.items[player] = { nil, nil, nil, nil, nil, nil }
    self.wl_items[player] = { nil, nil, nil, nil, nil, nil }
end

-- Actually perform the mastery upgrade (without removing money)
function Shop:doUpgradeMastery(player, mastery_index)
    -- Get the level after the upgrade
    local next_level = self.mastery_level[player][mastery_index] + 1

    -- Get the gain for the level to upgrade to
	local gain = Shop.MASTERY_GAIN[mastery_index][next_level]

    -- Add the mastery gain
	player.mastery_factor[mastery_index] = player.mastery_factor[mastery_index] + gain

    -- Set the level
	self.mastery_level[player][mastery_index] = next_level

    print("Upgraded mastery", mastery_index)
    print(player.mastery_factor[Player.MASTERY_DURATION])
    print(player.mastery_factor[Player.MASTERY_RANGE])
    print(player.mastery_factor[Player.MASTERY_LIFESTEAL])
end

-- Upgrade a mastery for a player and removes money for it
-- Returns true if a mastery was upgraded, otherwise false
function Shop:upgradeMastery(player, mastery_index)
    if not player then
        warning("Player was nil in upgradeMastery, ignoring")
        return false
    end

    -- Check if player has enough money
    if player.cash < Shop.MASTERY_COST then
        return false
    end

    -- Check if the mastery index is valid
    if mastery_index < 1 or mastery_index > Player.MASTERY_MAX_INDEX then
        warning("Invalid mastery index in upgrade mastery")
        return false
    end

    -- Check if the mastery is already fully upgraded
    if self.mastery_level[player][mastery_index] >= Shop.MASTERY_MAX_LEVEL then
        return false
    end

    -- Upgrade the mastery
	self:doUpgradeMastery(player, mastery_index)

    -- Remove money
	player:addCash(-Shop.MASTERY_COST)

    -- Update the pawns stats
    player.pawn:applyStats()

    return true
end

-- Upgrades all masteries at once at a gold discount
-- Returns true if upgraded, otherwise false
function Shop:upgradeAllMasteries(player)
    if not player then
        warning("Player was nil in upgradeAllMasteries, ignoring")
        return false
    end

    -- Check if player has enough money
    if player.cash < Shop.MASTERY_ALL_COST then
        return false
    end

	-- If a mastery level is >= max level then you cant upgrade
	for i = 1, Player.MASTERY_MAX_INDEX do
		if self.mastery_level[player][i] >= Shop.MASTERY_MAX_LEVEL then
			return false
		end
	end
			
	-- Upgrade all masteries
	for i = 1, Player.MASTERY_MAX_INDEX do
        self:doUpgradeMastery(player, i)
	end

    -- Remove money
	player:addCash(-Shop.MASTERY_ALL_COST)

    -- Update the pawns stats
    player.pawn:applyStats()

    return true
end

function Shop:buySpell(player, spell_index)
    if not player or not spell_index then
        warning("Player or spell_index was nil in buySpell, ignoring")
        return false
    end

    if spell_index < 1 or spell_index > #Shop.SPELL_DEFS then
        warning("Invalid spell index in buySpell")
        return false
    end

    -- Get the spell definition for the spell with id spell_index
    local spell_def = self.SPELL_DEFS[spell_index]

    -- Check if player already has a spell in this column
    if self.spells[player][spell_def.column] then
        log("Player tried to buy spell but already has a spell in that column")
        return false
    end

    -- Check if the player can afford the spell
    if player.cash < spell_def.buy_cost then
        return false
    end

    -- Add the ability to the list and set the level to 1
    self.spells[player][spell_def.column] = spell_def
	self.spell_level[player][spell_def.column] = 1

    local hero_entity = player.pawn.unit

    -- Remove the empty slot ability
    hero_entity:RemoveAbility(hero_entity:GetAbilityByIndex(spell_def.column - 1):GetAbilityName())

    -- Add the ability at the correct index
    hero_entity:AddAbility(spell_def.ability_name)
    local ability = hero_entity:FindAbilityByName(spell_def.ability_name)
    ability:SetAbilityIndex(spell_def.column - 1) -- Zero indexed as opposed to columns which are one indexed
    ability:SetLevel(1)

    -- Remove the money
	player:addCash(-spell_def.buy_cost)

    -- Update the pawns stats
    player.pawn:applyStats()

    return true
end

function Shop:upgradeSpell(player, column)
    if not player or not column then
        warning("Player or column was nil in upgradeSpell, ignoring")
        return false
    end

    -- Check if the column is valid
    if column < 1 or column > 6 then
        warning("Invalid column in upgradeSpell", column)
        return false
    end

    local spell = self.spells[player][column]

    -- Check if the player has a spell in that column
    if not spell then
        return false
    end

    -- Get the current level for the spell
    local level = self.spell_level[player][column]
    
    if level == 0 then
        warning("Level of upgraded spell was 0")
        return false
    end

    -- Check if the spell is already at max level
    if level >= Shop.SPELL_MAX_LEVEL then
        return false
    end

    -- Check if the player can afford the upgrade
    if player.cash < spell.upgrade_cost[level] then
        return false
    end

    local hero_entity = player.pawn.unit
    local ability = hero_entity:FindAbilityByName(spell.ability_name)

    -- Check if the ability was found on the hero
    if not ability then
        warning("Could not find ability when upgrading, name:", spell.ability_name)
        return false
    end

    -- Increase the level in the list and on the ability
    self.spell_level[player][column] = level + 1
    ability:SetLevel(self.spell_level[player][column])

    -- Remove the money
    player:addCash(-spell.upgrade_cost[level])

    -- Update the pawns stats
    player.pawn:applyStats()

    return true
end

function Shop:giveItem(player, item_index)
    if not player or not item_index then
        warning("Player or item_index was nil in giveItem, ignoring")
        return false
    end

    -- Check if the item_index is valid
    if item_index < 1 or item_index > #self.ITEM_DEFS then
        warning("Invalid item_index in giveItem")
        return false
    end

    local first_free_index = nil -- The first free slot index

    -- Check if the player already has the item
    for i = 1, Shop.MAX_ITEMS do
        -- Set the first free index if its not set yet
        if not first_free_index and not self.items[player][i] then
            first_free_index = i
        end
    end

    if not first_free_index then
        warning("Tried to give item to player but no free index")
        return false
    end

    local hero_entity = player.pawn.unit
    local item_def = self.ITEM_DEFS[item_index]

    -- Add the item level 1
    self.items[player][first_free_index] = item_def
    self.item_level[player][first_free_index] = 1

    local new_item = CreateItem(item_def.item_name .. "1", hero_entity, hero_entity)
    hero_entity:AddItem(new_item)

    -- Create the warlock item
    self.wl_items[player][first_free_index] = ModifierItem:new {
        pawn = player.pawn,
        maxlevel = item_def.max_level,
        mod_defs = item_def.mod_defs
    }

    return true
end

-- Buys an item for a player
-- Returns true if an item was bought or upgraded, otherwise false
function Shop:buyItem(player, item_index)
    if not player or not item_index then
        warning("Player or item_index was nil in buyItem, ignoring")
        return false
    end

    -- Check if the item_index is valid
    if item_index < 1 or item_index > #self.ITEM_DEFS then
        warning("Invalid item_index in buyItem")
        return false
    end

    local item_def = self.ITEM_DEFS[item_index]

    -- Check if the player has enough money to buy or upgrade the item
    if player.cash < item_def.buy_cost then
        log("Player tried to buy item but had not enough cash")
        return false
    end

    local hero_entity = player.pawn.unit
    
    local index = nil
    local first_free_index = nil -- The first free slot index

    -- Check if the player already has the item
    for i = 1, Shop.MAX_ITEMS do
        -- Check if the item in the slot matches the searched item
        if self.items[player][i] == item_def then
            index = i
            break
        end

        -- Set the first free index if its not set yet
        if not first_free_index and not self.items[player][i] then
            first_free_index = i
        end
    end

    -- If he already has the item, upgrade it, otherwise buy it
    if index then
        -- Determine the current item level
        local level = self.item_level[player][index]

        -- Check if the item is already maxed
        if level >= item_def.max_level then
            log("Player tried upgrading maxed item")
            return false
        end

        -- Find the old item
        local old_item_name = item_def.item_name .. tostring(level)
        local old_item_handle = nil

        for i = 0, 5 do
            local item = hero_entity:GetItemInSlot(i)
            if item and item:GetAbilityName() == old_item_name then
                old_item_handle = item
            end
        end

        if not old_item_handle then
            warning("Old item was not found in buyItem when upgrading")
            return false
        end

        -- Remove the old item
        old_item_handle:RemoveSelf()

        -- Increase the level
        level = level + 1

        -- Add the new item and set the level
        self.item_level[player][index] = level

        local new_item = CreateItem(item_def.item_name .. tostring(level), hero_entity, hero_entity)
        hero_entity:AddItem(new_item)

        -- Upgrade the warlock item
        self.wl_items[player][index]:onUpgrade(level)
    else -- Add new item
        -- If theres no free index it means theres no slot left
        if not first_free_index then
            log("Player tried buying item but has no free slot")
            return false
        end

        -- Add the item level 1
        self.items[player][first_free_index] = item_def
        self.item_level[player][first_free_index] = 1

        local new_item = CreateItem(item_def.item_name .. "1", hero_entity, hero_entity)
        hero_entity:AddItem(new_item)

        -- Create the warlock item
        self.wl_items[player][first_free_index] = ModifierItem:new {
            pawn = player.pawn,
            maxlevel = item_def.max_level,
            mod_defs = item_def.mod_defs
        }
    end

    -- Remove the money
    player:addCash(-item_def.buy_cost)

    -- Update the pawns stats
    player.pawn:applyStats()

    return true
end

------------------------
-- Shop interface to UI
------------------------

ShopUI = class()

ShopUI.MASTERY_NAMES = {
    "Duration", "Range", "Lifesteal"
}

function ShopUI:init()
    CustomGameEventManager:RegisterListener("shop_upgrade_mastery", Dynamic_Wrap(self, "onUpgradeMastery"))
    CustomGameEventManager:RegisterListener("shop_upgrade_all_masteries", Dynamic_Wrap(self, "onUpgradeAllMasteries"))
    CustomGameEventManager:RegisterListener("shop_mastery_info_request", Dynamic_Wrap(self, "onMasteryInfoRequest"))
    CustomGameEventManager:RegisterListener("shop_buy_spell", Dynamic_Wrap(self, "onBuySpell"))
    CustomGameEventManager:RegisterListener("shop_upgrade_spell", Dynamic_Wrap(self, "onUpgradeSpell"))
    CustomGameEventManager:RegisterListener("shop_spell_info_request", Dynamic_Wrap(self, "onSpellInfoRequest"))
    CustomGameEventManager:RegisterListener("shop_buy_item", Dynamic_Wrap(self, "onBuyItem"))
end

-------------
-- Masteries
-------------

-- Returns the index of a mastery given its name
function ShopUI:masteryNameToIndex(mastery_name)
    for index, name in pairs(ShopUI.MASTERY_NAMES) do
        if name:lower() == mastery_name:lower() then
            return index
        end
    end

    return -1
end

-- Called when shop_upgrade_mastery was received
function ShopUI:onUpgradeMastery(args)
    local player_id = args.PlayerID
    local player = GAME.players[player_id]
    local mastery_index = GAME.shop_ui:masteryNameToIndex(args.name)

    -- Check if the player exists and the mastery name was valid
    if not player or mastery_index == -1 then
        warning("Upgrade mastery message received but no player found or invalid mastery name")
        DeepPrintTable(args)
        return
    end

    -- Try to upgrade the mastery
    local upgraded = GAME.shop:upgradeMastery(player, mastery_index)

    -- Send the player the new level to update his UI if it was upgraded
    if upgraded then
        GAME.shop_ui:sendMasteryInfo(player, GAME.shop.mastery_level[player])
    end
end

-- Called when shop_upgrade_all_masteries was received
function ShopUI:onUpgradeAllMasteries(args)
    local player_id = args.PlayerID
    local player = GAME.players[player_id]

    -- Check if the player exists
    if not player then
        warning("Upgrade all masteries message received but no player found")
        DeepPrintTable(args)
        return
    end

    local upgraded = GAME.shop:upgradeAllMasteries(player)

    if upgraded then
        GAME.shop_ui:sendMasteryInfo(player, GAME.shop.mastery_level[player])
    end
end

-- Called when shop_mastery_info_request was received
function ShopUI:onMasteryInfoRequest(args)
    local player_id = args.PlayerID
    local player = GAME.players[player_id]

    -- Check if the player exists
    if not player then
        warning("Mastery info request message received but no player found")
        DeepPrintTable(args)
        return
    end

    GAME.shop_ui:sendMasteryInfo(player, GAME.shop.mastery_level[player])
end

-- Sends a game event that notifies the player that a mastery of him was changed
function ShopUI:sendMasteryInfo(player, levels)
    local event_data = {
        levels = levels
    }

    log("Sending mastery info")

    CustomGameEventManager:Send_ServerToPlayer(player.playerEntity, "shop_mastery_info", event_data)
end

-------------
-- Spells
-------------

-- Returns the index of a spell given its name
function ShopUI:getSpellDef(spell_name)
    for index, spell_def in pairs(Shop.SPELL_DEFS) do
        if spell_def.name:lower() == spell_name:lower() then
            return index, spell_def
        end
    end

    return -1, nil
end

-- Called when shop_buy_spell was received
function ShopUI:onBuySpell(args)
    local player_id = args.PlayerID
    local player = GAME.players[player_id]
    local spell_index, spell_def = GAME.shop_ui:getSpellDef(args.name)

     -- Check if the player exists and the spell name was valid
    if not player or spell_index == -1 or not spell_def then
        warning("Buy spell message received but no player found or invalid spell name")
        DeepPrintTable(args)
        return
    end

    -- Try to buy the spell
    local acquired = GAME.shop:buySpell(player, spell_index)

    -- Send the player the new level to update his UI if it was upgraded
    if acquired then
        GAME.shop_ui:sendSpellColumnInfo(player, spell_def.column)
    end
end

-- Called when shop_upgrade_spell was received
function ShopUI:onUpgradeSpell(args)
    local player_id = args.PlayerID
    local player = GAME.players[player_id]

     -- Check if the player exists and the spell name was valid
    if not player or not args.column then
        warning("On upgrade spell received but no player found or column was nil")
        DeepPrintTable(args)
        return
    end

    -- Try to upgrade the spell
    local upgraded = GAME.shop:upgradeSpell(player, args.column)

    if upgraded then
        GAME.shop_ui:sendSpellColumnInfo(player, args.column)
    end
end

-- Called when shop_spell_info_request was received
function ShopUI:onSpellInfoRequest(args)
    local player_id = args.PlayerID
    local player = GAME.players[player_id]

     -- Check if the player exists and the spell name was valid
    if not player then
        warning("On spell info request received but no player found")
        DeepPrintTable(args)
        return
    end

    -- Send the spell column info for each column
    for i = 1, 6 do
        GAME.shop_ui:sendSpellColumnInfo(player, i)
    end
end

-- Sends the spell info for a column to a player
function ShopUI:sendSpellColumnInfo(player, column)
    local spell_def = GAME.shop.spells[player][column]

    local event_data = {
        column = column
    }

    -- If the spell def exists, get the spell name and the level
    if spell_def then
        event_data.spell_name = spell_def.name
        event_data.level = GAME.shop.spell_level[player][column]
    end

    log("Sending spell column info: " .. tostring(event_data))

    CustomGameEventManager:Send_ServerToPlayer(player.playerEntity, "shop_spell_column_info", event_data)
end

-------------
-- Items
-------------

-- Returns the index of a spell given its name
function ShopUI:getItemIndex(item_name)
    for index, item_def in pairs(Shop.ITEM_DEFS) do
        if item_def.name:lower() == item_name:lower() then
            return index
        end
    end

    return -1
end

function ShopUI:onBuyItem(args)
    local player_id = args.PlayerID
    local player = GAME.players[player_id]
    local item_index = GAME.shop_ui:getItemIndex(args.name)

     -- Check if the player exists and the spell name was valid
    if not player or item_index == -1 then
        warning("Buy item message received but no player found or invalid item name")
        DeepPrintTable(args)
        return
    end

    -- Try to buy the item
    GAME.shop:buyItem(player, item_index)
end

------------------------
-- Game Interface
------------------------

function Game:initShop()
    self.shop = Shop:new()
    self.shop_ui = ShopUI:new()
end