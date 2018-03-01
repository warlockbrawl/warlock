item_warlock_fireball2 = class({})

function item_warlock_fireball2:OnSpellStart()
	CastLuaAbility(self)
end

function item_warlock_fireball2:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
