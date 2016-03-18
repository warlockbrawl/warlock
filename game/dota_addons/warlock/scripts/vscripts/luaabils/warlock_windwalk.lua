warlock_windwalk = class({})

function warlock_windwalk:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_windwalk:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[1]
end
