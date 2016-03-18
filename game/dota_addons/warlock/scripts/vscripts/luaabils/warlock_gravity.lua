warlock_gravity = class({})

function warlock_gravity:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_gravity:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
