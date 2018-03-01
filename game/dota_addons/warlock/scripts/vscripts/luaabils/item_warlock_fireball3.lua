item_warlock_fireball3 = class({})

function item_warlock_fireball3:OnSpellStart()
	CastLuaAbility(self)
end

function item_warlock_fireball3:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
