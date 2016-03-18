warlock_rush = class({})

function warlock_rush:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_rush:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[1]
end
