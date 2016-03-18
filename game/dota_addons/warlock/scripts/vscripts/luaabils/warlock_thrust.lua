warlock_thrust = class({})

function warlock_thrust:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_thrust:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
