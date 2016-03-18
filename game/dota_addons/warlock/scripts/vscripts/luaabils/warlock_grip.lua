warlock_grip = class({})

function warlock_grip:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_grip:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
