-- Redirector item spell

Redirect = Spell:new{id='item_warlock_redirector1'}
Redirect.cast_effect = "redirect_cast" -- Redirect cast effect
Redirect.effect = "redirect" -- Debuff effect
Redirect.cast_sound = "Redirector.Cast"

function Redirect:onCast(cast_info)
    local kb_penalty = cast_info:attribute("kb_penalty")
    local kb_penalty_duration = cast_info:attribute("kb_penalty_duration")

    local closest_proj = nil
    local closest_delta = nil
    local closest_dst_sq = nil

    -- Find the owned projectile that is closest to the target location
    for actor, _ in pairs(GAME.actors) do
        if actor:instanceof(Projectile) and actor.instigator.owner:getAlliance(cast_info.caster_actor.owner) == Player.ALLIANCE_SELF
            and not actor:instanceof(MeteorProjectile) then -- Hardcoded exception for meteor

            local delta = cast_info.target - actor.location
            delta.z = 0
            local dst_sq = delta:Dot(delta)

            if not closest_proj or dst_sq < closest_dst_sq then
                closest_proj = actor
                closest_delta = delta
                closest_dst_sq = dst_sq
            end
        end
    end

    -- Redirect the projectile if one was found
    if closest_proj then
        local dir = closest_delta:Normalized()
        closest_proj.velocity = closest_proj.velocity:Length() * dir

        -- Create the effect with the correct angle
        local angle = math.deg(math.atan2(dir.y, dir.x))
        Effect:create(cast_info:attribute("cast_effect"), { location = closest_proj.location, angles = Vector(0, angle, 0) })

        -- Create the sound effect
        if closest_proj.effect and closest_proj.effect.locust then
            closest_proj.effect.locust:EmitSound(cast_info:attribute("cast_sound"))
        end

        -- Increase lifetime by 0.5 if applicable
        local lifetime = closest_proj:getLifetime()
        if lifetime then
            closest_proj:setLifetime(lifetime + 0.5)
        end
    end

    -- Add KB penalty to the caster while on cd
    GAME:addModifier(Modifier:new {
        pawn = cast_info.caster_actor,
        kb_reduction = kb_penalty,
        time = kb_penalty_duration,
        effect = cast_info:attribute("effect")
    })
end

-- Effects
Effect:register('redirect', {
	class 		= ParticleEffect,
	effect_name = 'particles/econ/courier/courier_faceless_rex/cour_rex_flying.vpcf'
})

Effect:register('redirect_cast', {
    class       = ParticleEffect,
    effect_name = "particles/econ/items/ursa/ursa_swift_claw/ursa_swift_fury_sweep_dim_b_blue.vpcf"
})