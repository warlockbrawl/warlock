--- function executed by Warlock spells
function cast(event)
	CastInfo:handleAbilityEvent(event)
end

-- Function executed by Warlock Lua abilities
function CastLuaAbility(abil)
	local event = {}
	event.ability = abil
	event.caster = abil:GetCaster()
	event.target_points = { abil:GetCursorPosition() }

	CastInfo:handleAbilityEvent(event)
end
