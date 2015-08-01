--- Spell warlock_scourge

Scourge = Spell:new{id='item_warlock_scourge1'}

function Scourge:onCast(cast_info)
	local caster_actor = cast_info.caster_actor
	local damage = cast_info:attribute('damage')

	-- AOE dmg
	caster_actor:damageArea(caster_actor.location, cast_info:attribute('radius'), {
		amount = damage,
		kb_factor_min = 0.75,
		kb_factor_max = 1.00
	})
	caster_actor:setHealth(math.max(1, caster_actor.health - damage)) -- self damage
end

Scourge_incarnation1 = Spell:new{id='item_warlock_scourge2'}
Scourge_incarnation2 = Spell:new{id='item_warlock_scourge3'}


function Scourge_incarnation1:onCast(cast_info)
	local caster_actor = cast_info.caster_actor
	local damage = cast_info:attribute('damage')

	-- AOE dmg
	local count = caster_actor:damageArea(caster_actor.location, cast_info:attribute('radius'), {
		amount = damage,
		kb_factor_min = 0.75,
		kb_factor_max = 1.00
	})
	caster_actor:setHealth(math.max(1, caster_actor.health - 100))
	caster_actor.unit:SetMana(math.max(0, caster_actor.unit:GetMana() - cast_info:attribute('dp_reduce')*count))
end


function Scourge_incarnation2:onCast(cast_info) -- exactly identical to incarnation1
	local caster_actor = cast_info.caster_actor
	local damage = cast_info:attribute('damage')

	-- AOE dmg
	local count = caster_actor:damageArea(caster_actor.location, cast_info:attribute('radius'), {
		amount = damage,
		kb_factor_min = 0.75,
		kb_factor_max = 1.00
	})
	caster_actor:setHealth(math.max(1, caster_actor.health - 100))
	caster_actor.unit:SetMana(math.max(0, caster_actor.unit:GetMana() - cast_info:attribute('dp_reduce')*count))
end