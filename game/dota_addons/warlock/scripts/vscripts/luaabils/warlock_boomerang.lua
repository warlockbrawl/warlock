warlock_boomerang = class({})

function warlock_boomerang:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_boomerang:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
