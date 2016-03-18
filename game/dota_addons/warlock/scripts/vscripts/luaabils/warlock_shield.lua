warlock_shield = class({})

function warlock_shield:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_shield:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[1]
end
