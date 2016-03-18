item_warlock_fireball1 = class({})

function item_warlock_fireball1:OnSpellStart()
	CastLuaAbility(self)
end

function item_warlock_fireball1:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[2]
end
