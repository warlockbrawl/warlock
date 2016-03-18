warlock_homing = class({})

function warlock_homing:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_homing:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
