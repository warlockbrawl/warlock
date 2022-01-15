Item = class()

ItemClasses = {}
ItemClasses["Item"] = Item
ItemClasses["ModifierItem"] = ModifierItem

--- def Parameters
-- pawn
-- #Optional
-- maxlevel = 1

function Item:init(def)
	if not def.pawn then
		print("def.pawn was nil in Item")
	end
	
	self.pawn = def.pawn

	self.level = 1
	self.maxlevel = def.maxlevel or 1
	
	self:onUpgrade(self.level)
end

function Item:onUpgrade(level)
	if(level > self.maxlevel or level < 1) then
		warning("Item:onUpgrade invalid level")
	end

	self.level = level
end

function Item:onSell()
	
end

---------------------------------
-- Item with a list of modifiers
---------------------------------

ModifierItem = class(Item)

--- def Parameters
-- mod_defs: List of parameters for modifier for each level

function ModifierItem:init(def)
	if not def.mod_defs then
		warning("ModifierInit:init def.mod_defs is nil")
	end
	
	if not def.pawn then
		warning("ModifierInit:init def.pawn is nil")
	end
	
	-- For each modifier definition create a modifier
	self.modifiers = {}
	
	local last_index
	for i, mod_def in pairs(def.mod_defs) do
		mod_def.pawn = def.pawn
		self.modifiers[i] = Modifier:new(mod_def)
		last_index = i
	end
	
	-- Set max level from index (Lua indices start at 1)
	def.maxlevel = def.maxlevel or last_index

	self.active_mod_level = -1 -- indicates no mod active

	-- Needs to be called last because of onUpgrade
	ModifierItem.super.init(self, def)
	
	self.active_mod_level = self.level
end

function ModifierItem:onUpgrade(level)
	-- do nothing if the level is unchanged
	if level == self.active_mod_level then
		return
	end
	
	ModifierItem.super.onUpgrade(self, level)

	if(self.active_mod_level ~= -1) then
		-- Remove old modifier
		GAME:removeModifier(self.modifiers[self.active_mod_level])
	end
	
	-- Add new modifier
	GAME:addModifier(self.modifiers[level])
	
	-- Set the active mod level
	self.active_mod_level = level
end

function ModifierItem:onSell()
	ModifierItem.super.onSell(self)
	
	-- Remove old modifier
	GAME:removeModifier(self.modifiers[self.active_mod_level])
end