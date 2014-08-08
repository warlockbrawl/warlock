BoomerangProjectile = class(Projectile)

function BoomerangProjectile:init(def)
	self.damage = def.damage or 0
	self.iter = false
	self.hit_sound = def.hit_sound
	self.hit_effect = def.hit_effect

	BoomerangProjectile.super.init(self, def)

	-- Set the correct coll matrix
	local coll_mat = { }
	coll_mat[Player.ALLIANCE_SELF] = {}
	coll_mat[Player.ALLIANCE_ALLY] = {}
	coll_mat[Player.ALLIANCE_ENEMY] = {}

	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PLAYER] = true
	coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_OBSTACLE] = true

	self.collision_components["projectile"].coll_mat = coll_mat

	--Calculate initial acceleration and velocity and the time for the timers

	-- perp_dir = perpendicular to the cast vector
	local perp_dir = Vector(-def.direction.y, def.direction.x, 0)

	local par_acc = -(1500 * 1500) / (2 * def.distance)
	local perp_acc = 2 * par_acc * 300 / 1500

	-- Set the initial velocity and acceleration
	self.velocity = 1500 * def.direction + 300 * perp_dir
	self.acceleration = par_acc * def.direction + perp_acc * perp_dir

	-- Calculate the time for changing and stopping acceleration
	self.change_acc_time = -1500 / par_acc
	self.stop_acc_time = self.change_acc_time - 0.15

	-- Calculate the changed acceleration when the timer fires
	self.changed_acc = par_acc * def.direction - perp_acc * perp_dir

	-- Start the timer for changing acceleration
	GAME:addTask {
		time = self.change_acc_time,
		func = function()
			self:changeAcceleration()
		end
	}
end

-- Changes the acceleration and starts the stopAcceleration timer
function BoomerangProjectile:changeAcceleration()
	-- The main iteration might have already been activated when a warlock was hit before
	if(not self.iter) then
		-- Change the acceleration and add a task to stop the acceleration later
		self.acceleration = self.changed_acc
		GAME:addTask {
			time = self.stop_acc_time,
			func = function()
				self:stopAcceleration()
			end
		}
	end
end

-- Stops acceleration and activates the main movement function
function BoomerangProjectile:stopAcceleration()
	-- Stop the acceleration and activate main movement iteration
	self.acceleration = Vector(0, 0, 0)
	self.iter = true
end

function BoomerangProjectile:onCollision(coll_info, cc)
	coll_info.actor:receiveDamage{
		source		= self.instigator or self,
		hit_normal	= coll_info.hit_normal,
		amount = self.damage or 0,
		knockback_factor = 0.95
	}

	if coll_info.actor:instanceof(Pawn) then
		-- Spawn an effect
		Effect:create(self.hit_effect, { location=coll_info.actor.location })

		-- Play a sound
		-- TODO: maybe not use the effects locust
		if self.hit_sound and self.effect and self.effect.locust then
			self.effect.locust:EmitSound(self.hit_sound)
		end
	end

	--Bounce the projectile when it hits a warlock or obstacle
	local vel_dir = self.velocity:Normalized()

	if self:isMovingTowards(coll_info.hit_normal) then
		self:reflectVelocity(coll_info.hit_normal)
		self.velocity = 500 * self.velocity:Normalized()
	end
	
	--Move the projectile out of the hit warlock
	-- distance_deficit = desired distance - actual distance
	local distance_deficit = (coll_info.other_cc.radius + cc.radius + 10) - coll_info.hit_distance

	if distance_deficit > 0 then
		self.location = self.location - distance_deficit * coll_info.hit_normal
	end

	self:stopAcceleration()
end

function BoomerangProjectile:onPreTick(dt)
	local delta = self.instigator.location - self.location
	local dist = delta:Length()

	-- Add Acceleration
	self.velocity = self.velocity + self.acceleration * dt

	-- Skip rest if the main iteration isnt activated yet
	if(not self.iter) then
		return
	end

	-- Destroy the boomerang if its close to the caster
	if(dist < 75) then
		self:destroy()
		return
	end

	-- Movement calculations
	local vel_change = 1000 * delta:Normalized() - self.velocity;
	vel_change = 1000 * vel_change:Normalized() * dt
	self.velocity = self.velocity + vel_change
end
