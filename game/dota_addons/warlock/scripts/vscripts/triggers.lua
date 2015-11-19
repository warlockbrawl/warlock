--- function executed by Warlock spells
function cast(event)
	CastInfo:handleAbilityEvent(event)
end

-- Function executed by Warlock Lua abilities
function CastLuaAbility(abil)
	local event = {}
	event.ability = self
	event.caster = self:GetCaster()
	event.target_points = { self:GetCursorPosition() }

	CastInfo:handleAbilityEvent(event)
end
