warlock_swap = class({})

function warlock_swap:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_swap:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[1]
end
