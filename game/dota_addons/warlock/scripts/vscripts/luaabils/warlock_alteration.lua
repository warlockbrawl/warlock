warlock_alteration = class({})

function warlock_alteration:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_alteration:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[1]
end
