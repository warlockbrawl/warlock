warlock_cluster = class({})

function warlock_cluster:OnSpellStart()
	CastLuaAbility(self)
end

function warlock_cluster:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
