SplitterChildProjectile = class(SimpleProjectile)

function SplitterChildProjectile:init(def)
    SplitterChildProjectile.super.init(self, def)

    self.hit_sound = def.hit_sound
end

function SplitterChildProjectile:onCollision(coll_info, cc)
    SplitterChildProjectile.super.onCollision(self, coll_info, cc)

    -- Play a hit sound
    if self.hit_sound and self.effect and self.effect.locust then
        self.effect.locust:EmitSound(self.hit_sound)
    end
end