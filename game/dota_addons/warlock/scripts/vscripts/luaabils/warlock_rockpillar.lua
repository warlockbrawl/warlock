warlock_rockpillar = class({})

function warlock_rockpillar:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_rockpillar:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
