
--- function executed by Warlock spells
function cast(event)
	CastInfo:handleAbilityEvent(event)
end
function resetcooldown(event)
  event.ability:EndCooldown()
end