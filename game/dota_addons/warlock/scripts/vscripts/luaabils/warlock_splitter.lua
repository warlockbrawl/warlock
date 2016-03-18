warlock_splitter = class({})

function warlock_splitter:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_splitter:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
