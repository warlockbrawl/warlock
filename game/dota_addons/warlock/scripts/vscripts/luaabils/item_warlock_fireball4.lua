item_warlock_fireball4 = class({})

function item_warlock_fireball4:OnSpellStart()
	CastLuaAbility(self)
end

function item_warlock_fireball4:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
