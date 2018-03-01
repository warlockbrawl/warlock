warlock_recharge = class({})

function warlock_recharge:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_recharge:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
