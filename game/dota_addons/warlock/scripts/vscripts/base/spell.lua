--- Spell infrastructure
-- @author Krzysztof Lis (Adynathos)

--[[
Spell attributes:
	in npc config (level dependant):
		* cooldown
		* damage
		* range

	in class definition:
		* radius
		* projectile_class
		* projectile_speed
		* projectile_effect
]]


Spell = class()
Spell.spells = {}

function Spell:init(def)
	self.id = def.id

	if not self.id then
		err("No id for spell")
	end

	Spell.spells[self.id] = self

	if def.alt_ids then
		for _, alt_id in pairs(def.alt_ids) do
			Spell.spells[alt_id] = self
		end
	end
end

--- Override for spell behaviour
function Spell:onCast(cast_info)
end

-- function Game:initSpells()
-- 	self.spells = {}
-- end

-- function Game:_registerSpell(spell)
-- 	self.spells[spell.id] = spell
-- end

--- Attemps to spawn a default projectile
-- using the spell's attributes
function Spell:spawnProjectile(cast_info, target)
	local start = cast_info.caster_actor.location

	-- target is optional
	target = target or cast_info.target

	-- Direction to target
	local dir = target - start
	dir.z = 0
	dir = dir:Normalized()

	local projectile_class = cast_info:attribute('projectile_class') or SimpleProjectile
	local projectile_speed = cast_info:attribute('projectile_speed')
	local damage = cast_info:attribute('damage')
	local range = cast_info:attribute('range')
	local radius = cast_info:attribute('radius')
	local projectile_effect = cast_info:attribute('projectile_effect')

    local knockback_factor = cast_info:attribute('knockback_factor')
    if knockback_factor == 0 then
        knockback_factor = 1
    end

	local proj = projectile_class:new{
		instigator	= cast_info.caster_actor,
		velocity	= dir*projectile_speed,
		coll_radius = radius,
		lifetime	= range / projectile_speed,
		projectile_effect = projectile_effect,
		damage 		= damage,
        knockback_factor = knockback_factor
	}
end

-------------------------------------------------------------------------------
--- Context of a spell cast
-------------------------------------------------------------------------------
CastInfo = class()

function CastInfo:setAttribute(name, value)
	self.attributes[name] = value
end

--- Fetches the value of spell's attribute in context of the current cast
-- the attributes value are first searched in the spell class
-- then using ability:GetSpecialValueFor
function CastInfo:attribute(attr_name)
	-- if found in self
	if self.attributes[attr_name] ~= nil then
		return self.attributes[attr_name]
	end

	-- if found in the class
	if self.spell[attr_name] ~= nil then
		return self.spell[attr_name]
	end

	-- for values in the config file, will return nil if not found
    -- Edit: does return 0, not nil if not found?
	
	return self.ability:GetLevelSpecialValueFor(attr_name, self.ability:GetLevel()-1)
end

--- Takes the data passed by native handler and returns a CastInfo context
-- static
function CastInfo:fromEvent(cast_info)
	cast_info.ability_name 	= cast_info.ability:GetAbilityName()
	cast_info.spell 		= Spell.spells[cast_info.ability_name]
	cast_info.caster_actor 	= GAME.entityActor[cast_info.caster]

	if cast_info.target_points then
		cast_info.target 		= cast_info.target_points[1]
	end

	if not cast_info.spell then
		err("Unknown spell "..cast_info.ability_name)
		return nil
	end

	if not cast_info.caster_actor then
		err("Non actor caster casting "..cast_info.ability_name)
		return nil
	end

	if not cast_info.caster_actor.enabled then
		print("Ignoring spell from disabled actor")
		return nil
	end

	-- give the class to the cast_info without creating a new object
	setmetatable(cast_info, CastInfo)

	cast_info.attributes = {}

	return cast_info
end

function CastInfo:handleAbilityEvent(event)
	local cast_info = CastInfo:fromEvent(event)

	if cast_info then
		GAME:modOnSpellCast(cast_info)
		cast_info.spell:onCast(cast_info)
	end
end
