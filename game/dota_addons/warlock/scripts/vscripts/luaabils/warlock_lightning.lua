warlock_lightning = class({})

function warlock_lightning:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_lightning:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[3]
end
