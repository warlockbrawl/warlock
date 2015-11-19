%(spell_name)s = class({})

function %(spell_name)s:OnSpellStart()
	CastLuaAbility(self)
end
