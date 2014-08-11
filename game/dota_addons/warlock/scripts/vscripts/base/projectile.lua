--- Simple projectiles
-- @author Krzysztof Lis (Adynathos)

Projectile = class(Actor)

function Projectile:init(def)
	-- extract data
	self.instigator = def.instigator

	if self.instigator then
		def.owner = self.instigator.owner
	end

	if (not def.location) and self.instigator then
		def.location = self.instigator.location
	end

	-- actor constructor
	Projectile.super.init(self, def)

	-- effect
	if def.projectile_effect then
		self.effect = Effect:create(def.projectile_effect, {location=self.location})
	end

	-- coll component
	self:addCollisionComponent{
		id 					= 'projectile',
		channel 			= def.coll_channel or CollisionComponent.CHANNEL_PROJECTILE,
		coll_mat = CollisionComponent.createCollMatSimple(
			{Player.ALLIANCE_ENEMY},
			{CollisionComponent.CHANNEL_PLAYER , CollisionComponent.CHANNEL_PROJECTILE, CollisionComponent.CHANNEL_OBSTACLE}),
		radius 				= (def.coll_radius or 1)
	}
end

function Projectile:_updateLocation()
	if self.effect ~= nil then
		self.effect:setLocation(self.location, self.time_scale * self.velocity:Length())
	end
end

-- by default projectiles are destroyed when they receive damage
function Projectile:receiveDamage(dmg_info)
	if not self.scheduled_destruction then
		self.scheduled_destruction = true
		self:setLifetime(0)
	end
end

function Projectile:onDestroy()
	if self.effect then
		self.effect:destroy()
	end

	Projectile.super.onDestroy(self)
end

-------------------------------------------------------------------------------
--- Simple projectile that just deals damage
-------------------------------------------------------------------------------
SimpleProjectile = class(Projectile)

function SimpleProjectile:init(def)
	self.damage 	= def.damage or 0
	self.knockback_factor = def.knockback_factor or 1

	SimpleProjectile.super.init(self, def)
end

function SimpleProjectile:onCollision(coll_info, cc)
	coll_info.actor:receiveDamage{
		source		= self.instigator or self,
		hit_normal	= coll_info.hit_normal,
		amount		= self.damage or 0,
		knockback_factor = self.knockback_factor or 1
	}

	if not self.scheduled_destruction then
		self.scheduled_destruction = true
		self:setLifetime(0)
	end
end

