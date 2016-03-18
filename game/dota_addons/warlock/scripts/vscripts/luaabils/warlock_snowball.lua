warlock_snowball = class({})

function warlock_snowball:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_snowball:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
