warlock_teleport = class({})

function warlock_teleport:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_teleport:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[1]
end
