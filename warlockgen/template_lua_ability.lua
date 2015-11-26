%(spell_name)s = class({})

function %(spell_name)s:OnSpellStart()
	CastLuaAbility(self)
end

function %(spell_name)s:GetCastAnimation()
	local caster_name = self:GetCaster():GetName()
	return Config.HERO_SETTINGS[caster_name].CAST_ANIMS[%(cast_anim)s]
end
