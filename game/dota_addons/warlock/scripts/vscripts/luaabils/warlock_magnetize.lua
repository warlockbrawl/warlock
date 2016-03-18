warlock_magnetize = class({})

function warlock_magnetize:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_magnetize:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
