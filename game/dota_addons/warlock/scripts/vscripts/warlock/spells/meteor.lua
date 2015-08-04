--- Spell warlock_fireball
Meteor = Spell:new{id='warlock_meteor'}

Meteor.projectile_class 	= MeteorProjectile
Meteor.projectile_effect 	= 'meteor_projectile'
Meteor.explode_effect = 'meteor_explode'
Meteor.cast_sound = "Meteor.Cast"

function Meteor:onCast(cast_info)
	cast_info.caster_actor.unit:EmitSound(cast_info:attribute("cast_sound"))
	
	local start = cast_info.caster_actor.location

	local target = cast_info.target
	local damage_min = cast_info:attribute('damage_min')
	local damage_max = cast_info:attribute('damage_max')
	local range = cast_info:attribute('range')
	local projectile_effect = cast_info:attribute('projectile_effect')
	local radius = cast_info:attribute('radius') --Impact radius
	local hover_time = cast_info:attribute('hover_time') --How long the meteor hovers
	local fall_time = cast_info:attribute('fall_time') --How long the meteor takes to fall after hovering

	local proj = MeteorProjectile:new {
		instigator = cast_info.caster_actor,
		projectile_effect = projectile_effect,
		damage_min = damage_min,
		damage_max = damage_max,
		target = target,
		range = range,
		radius = radius,
		hover_time = hover_time,
		fall_time = fall_time,
		explode_effect = cast_info:attribute('explode_effect')
	}
end

-- effects
Effect:register('meteor_projectile', {
	class = ProjectileParticleEffect,
	effect_name = "particles/meteor/meteor_fly.vpcf",
	destruction_sound = "Meteor.Explode"
})

Effect:register('meteor_explode', {
	class = ParticleEffect,
	effect_name = 'particles/units/heroes/hero_techies/techies_remote_mines_detonate.vpcf'
})