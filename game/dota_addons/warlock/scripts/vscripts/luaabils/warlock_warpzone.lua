warlock_warpzone = class({})

function warlock_warpzone:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_warpzone:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
