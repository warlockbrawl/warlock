--- Spell: warlock_lightning
-- @author Krzysztof Lis (Adynathos)

--- Spell warlock_fireball
Lightning = Spell:new{id='warlock_lightning'}

Lightning.radius 				= 25
Lightning.channel 				= CollisionComponent.CHANNEL_PROJECTILE
Lightning.coll_mat = CollisionComponent.createCollMatSimple(
	{Player.ALLIANCE_ENEMY},
	{CollisionComponent.CHANNEL_PLAYER , CollisionComponent.CHANNEL_PROJECTILE, CollisionComponent.CHANNEL_OBSTACLE})
Lightning.effect = 'lightning'
Lightning.fb_effect = 'lightning_fb_explosion'
Lightning.fb_sound = "Lightning.FBExplosion"

function Lightning:onCast(cast_info)
	local start = cast_info.caster_actor.location
	local diff = (cast_info.target - start)
	diff.z = 0
	local dir  = diff:Normalized()
	local normal_dir = Vector(-dir.y, dir.x, 0)

	local radius = cast_info:attribute('radius')

	local best_target = nil
	local best_dst = cast_info:attribute('range') * cast_info.caster_actor.owner.mastery_factor[Player.MASTERY_RANGE]
	local take_damage
	local best_cc
	local best_is_allied_fb --whether best_target is an allied fireball

	for cc, _ in pairs(GAME.phys_active_ccs) do
		local alliance = cast_info.caster_actor.owner:getAlliance(cc.actor.owner)

		-- collision filters, fireball hardcoded, not hitting warpzone hardcoded
		local is_allied_fb = alliance ~= Player.ALLIANCE_ENEMY and cc.actor:instanceof(FireballProjectile)
		local coll = (Lightning.coll_mat[alliance][cc.channel] and cc.coll_mat[alliance][Lightning.channel]) or is_allied_fb
			and not cc.actor:instanceof(WarpZoneActor)

		if coll then
			local target_actor = cc.actor
			local diff = target_actor.location - start
			diff.z = 0
			local normal_dst = diff:Dot(normal_dir)

			-- lightning width
			if math.abs(normal_dst) <= radius + cc.radius then
				local dst = diff:Dot(dir)

				-- distance filter
				if dst > 0 and dst < best_dst then
					best_target = target_actor
					best_dst = dst
					take_damage = cc.accept_damage
					best_cc = cc
					best_is_allied_fb = is_allied_fb
				end
			end
		end
	end

	if best_target then
		if best_is_allied_fb then
			self:explodeFireball(best_target, cast_info)
		elseif take_damage then
			best_target:receiveDamage{
				amount=cast_info:attribute('damage'),
				source=cast_info.caster_actor,
				hit_normal=dir,
				knockback_factor=0.92
			}
		end
	end

	Effect:create(cast_info:attribute("effect"), {
		start_location=start,
		end_location=start+dir*best_dst,
		lifetime=2
	})
end

function Lightning:explodeFireball(fb, cast_info)
	local dmg_max = 2.0 / 3.0 * (cast_info:attribute('damage') + 70)

	cast_info.caster_actor:damageArea(fb.location, 225, {
		amount_min = 0,
		amount_max = dmg_max,
		knockback_factor = 1.35 --=1.5 * 1.5 * 0.6
	})

	fb.effect.locust:EmitSound(cast_info:attribute("fb_sound"))

	Effect:create(cast_info:attribute("fb_effect"), {
		location = fb.location
	})

	fb:destroy()
end

-- effects

Effect:register('lightning', {
	class 				= LightningEffect,
	effect_name 		= "particles/units/heroes/hero_lina/lina_spell_laguna_blade.vpcf",
	sound 				= "Lightning.Cast"
})

Effect:register('lightning_fb_explosion', {
	class				= ParticleEffect,
	effect_name			= "particles/units/heroes/hero_phoenix/phoenix_supernova_reborn_star_sphere.vpcf"
})
