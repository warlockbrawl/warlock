warlock_twin = class({})

function warlock_twin:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_twin:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
