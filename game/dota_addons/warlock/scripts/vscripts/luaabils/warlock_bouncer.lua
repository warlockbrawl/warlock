warlock_bouncer = class({})

function warlock_bouncer:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_bouncer:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
