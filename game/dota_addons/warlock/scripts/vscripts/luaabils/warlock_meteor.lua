warlock_meteor = class({})

function warlock_meteor:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_meteor:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[4]
end
