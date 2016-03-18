warlock_link = class({})

function warlock_link:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_link:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
