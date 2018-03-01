--- Physics engine
-- @author Krzysztof Lis (Adynathos)


-- VECTOR
-- Cross: function: 0xdcfa0878
-- Dot: function: 0xdcfa0858
-- Length: function: 0xdcfa0818
-- Normalized: function: 0xdcfa0a68
-- __add: function: 0xdcfa06d8
-- __div: function: 0xdcfa0790
-- __eq: function: 0xdcfa07f8
-- __index: function: 0xdcfa0710
-- __len: function: 0xdcfa08c0
-- __mul: function: 0xdcfa0770
-- __newindex: function: 0xdcfa0730
-- __sub: function: 0xdcfa07d8
-- __tostring: function: 0xdcfa0750
-- __unm: function: 0xdcfa07b0

local v_zero = Vector(0, 0, 0)

-------------------------------------------------------------------------------
-- CollisionComponent
-- 	Belongs to an actor, used to detect collisions with other CCs
-------------------------------------------------------------------------------
CollisionComponent = class()

CollisionComponent.CHANNEL_DEFAULT 		= 0
CollisionComponent.CHANNEL_PLAYER 		= 1
CollisionComponent.CHANNEL_PROJECTILE 	= 2
CollisionComponent.CHANNEL_OBSTACLE 	= 3

function CollisionComponent:init(def)
	self.actor 				= def.actor
	self.id 				= def.id or 'default'
	self.channel 			= def.channel or self.CHANNEL_DEFAULT
	self.coll_initiative	= def.coll_initiative or 0
	self.ellastic 			= def.ellastic or false
	self.ellasticity 		= def.ellasticity or 0
	self.coll_mat			= def.coll_mat

	if(def.accept_damage ~= nil) then
		self.accept_damage	= def.accept_damage
	else
		self.accept_damage 	= true
	end
end

---
-- @return minX, maxX
function CollisionComponent:extentX(dt)
	local lx = self.actor.location.x
	local vx = self.actor.velocity.x * dt * self.actor.time_scale

	if vx >= 0 then
		return lx, lx + vx
	else
		return lx + vx, lx
	end
end

function CollisionComponent:collisionFilter(other_cc)
	-- returns notify_self, notify_other, ellastic
	local alliance = self.actor.owner:getAlliance(other_cc.actor.owner)

	if(self.coll_mat[alliance] and self.coll_mat[alliance][other_cc.channel]) then
		return true, true, self.ellastic
	end

	return false, false, false
end

function CollisionComponent:onCollision(coll_info)
	self.actor:onCollision(coll_info, self)
end

-- Helper function for creating the coll matrix with the same channels for set alliances
function CollisionComponent.createCollMatSimple(coll_alliance, coll_channels)
	local coll_mat = { }
	coll_mat[Player.ALLIANCE_SELF] = { }
	coll_mat[Player.ALLIANCE_ALLY] = { }
	coll_mat[Player.ALLIANCE_ENEMY] = { }

	for _, alliance in pairs(coll_alliance) do
		for _, channel in pairs(coll_channels) do
			coll_mat[alliance][channel] = true
		end
	end

	return coll_mat
end

-------------------------------------------------------------------------------
-- CollisionComponentSphere
-- 	A spherical collision component, centered on the actor
-------------------------------------------------------------------------------
CollisionComponentSphere = class(CollisionComponent)

function CollisionComponentSphere:init(def)
	CollisionComponentSphere.super.init(self, def)

	self.radius = def.radius or 1
end

function CollisionComponentSphere:extentX(dt)
	local x1, x2 = CollisionComponentSphere.super.extentX(self, dt)

	return (x1 - self.radius), (x2 + self.radius)
end

-------------------------------------------------------------------------------
-- Collision detection mechanism
-------------------------------------------------------------------------------
local function _timeToCollision(cc1, cc2)
	--[[
	Collision prediction
	p1, p2 - positions
	v1, v2 - velocities
	r1, r2 - coll radius

	((p2 + v2*t) - (p1 + v1*t))^2 = (r1 + r2)^2
	((p2 - p1) + (v2 - v1)*t)^2 = (r1 + r2)^2
	dp = p2 - p1
	dv = v2 - v1
	(dp + dv*t) = (r1+r2)^2
	dp^2 + dv^2 * t^2 + 2*(dp dot dv)*t = (r1+r2)^2

	(t^2)*(dv^2) + (t)*2*(dp dot dv) + ( dp^2 - (r1+r2)^2 ) = 0
	A = dv^2
	B = 2*(dp dot dv)
	C = dp^2 - (r1+r2)^2
	D = B^2 - 4*A*C

	if B == 0 then
		A t^2 = -C
		t = sqrt(-C/A)


	if D < 0 then no collision
	if D >= 0 then
		select the positive solution, the negative reusult is in the past
		t = (-B + sqrt(D))/(2*A)

		if t >= 0 and t <= time_step then
			collision_after_time(t)
	]]

	local relative_location = cc2.actor.location - cc1.actor.location -- dp
	local relative_velocity = cc2.actor.velocity - cc1.actor.velocity -- dv
	local radius_sum = cc2.radius + cc1.radius

	local dst_sq = relative_location:Dot(relative_location)
	local radius_sum_sq = radius_sum*radius_sum

	--already overlapping, time to coll = 0
	if dst_sq < radius_sum_sq then
		return 0
	end

	local eq_A = relative_velocity:Dot(relative_velocity)
	if eq_A <= 0 then
		-- they are further than coll radius but no relative velocity, cannot collide
		return -1
	end

	local eq_B = 2 * relative_location:Dot(relative_velocity)
	local eq_C = dst_sq - radius_sum_sq

	if eq_B == 0 then
		-- B == 0 --> equation is simpler, A t^2 = -C
		local t_squared = -eq_C / eq_A

		-- solve
		if t_squared < 0 then
			return -1
		else
			return math.sqrt(t_squared)
		end
	end

	local eq_D = eq_B*eq_B - 4*eq_A*eq_C

	local coll_time = -1

	if eq_D >= 0 then
		coll_time  = (math.sqrt(eq_D) - eq_B)/(2*eq_A)
	end

	return coll_time
end

function Game:_physCollectCollisionExtents(dt)
	local cc_heap = self.phys_cc_extent_heap

	cc_heap:clear()

	for cc, _ in pairs(self.phys_active_ccs) do
		-- find the extent in X that this cc may occypy
		local x_start, x_end = cc:extentX(dt)

		-- insert start into heap
		cc_heap:insert(x_start - 0.1, cc)

		-- insert end
		-- 0.1 is added/substracted so that starts are always sorted before ends (at the same x)
		cc_heap:insert(x_end + 0.1, cc)

	end
end

function Game:_physCheckCollision(dt, cc1, cc2)
	if cc1.actor == cc2.actor then
		return
	end

	-- Set that cc1 is the one with earlier initiative or both are equal
	if cc1.coll_initiative > cc2.coll_initiative then
		cc1, cc2 = cc2, cc1
	end

	-- query the collision filters
	local notify_self_1, notify_other_1, b_ellastic_1 = cc1:collisionFilter(cc2)
	local notify_self_2, notify_other_2, b_ellastic_2 = cc2:collisionFilter(cc1)

	-- notify_X = whether ccX should have onCollision
	local notify_1 = notify_self_1
	local notify_2 = notify_self_2

	-- if noone is interested in collision, end it here
	if not (notify_1 or notify_2) then
		return
	end

	-- CC1 may influence cc2 if its initiative is higher/equal
	if cc1.coll_initiative <= cc2.coll_initiative then
		notify_2 = notify_2 and notify_other_1
	end

	-- CC2 may influence cc1 if its initiative is higher/equal
	if cc2.coll_initiative <= cc1.coll_initiative then
		notify_1 = notify_1 and notify_other_2
	end

	-- Ellastic collision requires consent of both
	local ellastic = b_ellastic_1 and b_ellastic_2

	-- only perform further steps when at least one object wants to collide
	if notify_1 or notify_2 then
		time_to_coll = _timeToCollision(cc1, cc2)

		-- physics time to collision
		if time_to_coll >= 0 and time_to_coll <= dt then
			-- filters ok and phys ok, so add collision to later resolution
			self.phys_collisions:insert(time_to_coll, {cc1=cc1, n1=notify_1, cc2=cc2, n2=notify_2, ellastic=ellastic})
		end
	end
end

function Game:_physFindCollisions(dt)
	-- CCs which are considered for collision in this area
	local ccs_here = Set:new()
	local cc_heap = self.phys_cc_extent_heap

	while not cc_heap:empty() do
		local x, cc = cc_heap:pop()

		if not ccs_here:contains(cc) then
			--print('extents ['..x..'] add '..cc.id)

			-- a new CC joins the considered group
			-- check it against all CCs in the group
			for other_cc, _ in pairs(ccs_here) do
				self:_physCheckCollision(dt, cc, other_cc)
			end

			ccs_here:add(cc)
		else
			--print('extents ['..x..'] remove '..cc.id)

			-- this object can no longer reach this X
			ccs_here:remove(cc)
		end
	end
end

function Game:_physResolveCollisions(dt)
	local coll_heap = self.phys_collisions

	while not coll_heap:empty() do
		local tm, coll_spec = coll_heap:pop()

		local a1 = coll_spec.cc1.actor
		local a2 = coll_spec.cc2.actor

		if not a1:isDestroyedNextFrame() and not a2:isDestroyedNextFrame() then
			-- move them to collision time
			if tm > 0 then
				a1:moveInTime(tm)
				a2:moveInTime(tm)
			end

			-- prepare collision info for the handlers
			local coll_info = {}

			local diff = a2.location - a1.location
			coll_info.hit_location = (a1.location + a2.location)*0.5
			coll_info.hit_distance = diff:Length()

			-- get normal, if applicable
			if coll_info.hit_distance > 0 then
				coll_info.hit_normal = diff / coll_info.hit_distance
			else
				coll_info.hit_normal = Vector(1, 0, 0)
			end

			-- overlapping when time to collision was 0
			coll_info.overlapping = (tm == 0)

			-- notify the objects
			if coll_spec.n1 then
				coll_info.other_cc = coll_spec.cc2
				coll_info.actor = a2
				coll_spec.cc1:onCollision(coll_info)
			end

			if coll_spec.n2 then
				coll_info.hit_normal = -coll_info.hit_normal

				coll_info.other_cc = coll_spec.cc1
				coll_info.actor = a1
				coll_spec.cc2:onCollision(coll_info)

				coll_info.hit_normal = -coll_info.hit_normal
			end

			-- perform ellastic if needed
			if coll_spec.ellastic then
				if coll_spec.cc1.channel == 2 or coll_spec.cc2.channel == 2 then
					self:_physEllasticCollision(coll_spec.cc1, coll_spec.cc2, coll_info)
				else
					a1:moveInTime(-Config.GAME_TICK_RATE)
					a2:moveInTime(-Config.GAME_TICK_RATE) -- revert time to check if player was previously colliding
					
					local dif = a2.location - a1.location
					local dist = dif:Length() -- previous distance
					local real r2 = coll_spec.cc1.radius + coll_spec.cc2.radius
					local real s = dist*dist
					local real r = s - r2*r2
					
					a1:moveInTime(Config.GAME_TICK_RATE)
					a2:moveInTime(Config.GAME_TICK_RATE) -- players can still walk while standing on each other
					--coll_info.hit_distance = diff:Length()
				
					--print(r)
					if r < 0 then
						s = math.sqrt(-r)
						if s < 30 then
							s = 30
						end
						if coll_spec.cc1.channel == coll_spec.cc2.channel then -- warlock-warlock collision
							a1.location = a1.location - dif/s -- Warlock-Warlock push away
							a2.location = a2.location + dif/s
						elseif coll_spec.cc1.channel + coll_spec.cc2.channel == 4 then -- 3+1 = 1+3 = 4 = warlock pillar collision
							if coll_spec.cc1.channel == 1 then
								a1.location = a2.location - coll_info.hit_normal*r2	
							else
								a2.location = a1.location + coll_info.hit_normal*r2
							end
						end
					else
						self:_physEllasticCollision(coll_spec.cc1, coll_spec.cc2, coll_info)
					end
				end
				--PrintTable(coll_spec.cc2)			
			end

			-- revert the time
			if tm > 0 then
				a1:moveInTime(-tm)
				a2:moveInTime(-tm)
			end


			if a1.static then
				a1.velocity = v_zero
			end

			if a2.static then
				a2.velocity = v_zero
			end
		end
	end
end

--- Moves the actor in time (forward or backward)
function Actor:moveInTime(dt)
	-- moving only non-static actors
	if not self.static then
		self.location = self.location + self.velocity * dt * self.time_scale
	end
end

function Game:_physEllasticCollision(cc1, cc2, coll_info)
	local a1 = cc1.actor
	local a2 = cc2.actor

	--coll_info.hit_normal is from a1 to a2
	--
	local mom_toward = a1.mass * a1.velocity:Dot(coll_info.hit_normal) - a2.mass * a2.velocity:Dot(coll_info.hit_normal)

	if mom_toward > 0 then
		-- apply ellasticity
		local mom_per_actor = 0.5 * mom_toward * (1 + 0.5*(cc1.ellasticity + cc2.ellasticity))

		a1:applyMomentum( (-mom_per_actor) * coll_info.hit_normal)
		a2:applyMomentum( mom_per_actor * coll_info.hit_normal)
	end
end

function Game:initPhysics()
	self.actors = Set:new()
	self.pawns = Set:new()
	self.phys_active_ccs = Set:new()	-- active collision components
	self.phys_collisions = heap()		-- collisions, ordered by time
	self.phys_cc_extent_heap = heap()	-- CC extent starts and ends ordered by X
end

function Game:removeProjectiles()
	for actor, _ in pairs(self.actors) do
		if actor:instanceof(Projectile) then
			actor:destroy()
		end
	end
end

function Game:tickPhysics(dt)
	-- pre tick
	for actor, _ in pairs(self.actors) do
		actor:onPreTick(dt * actor.time_scale)
	end

	-- collision detection
	self:_physCollectCollisionExtents(dt)

	--print("Phys: coll extents = "..self.phys_cc_extent_heap:getSize())

	self:_physFindCollisions(dt)

	--print("Phys: collisions = "..self.phys_collisions:getSize())

	self:_physResolveCollisions(dt)

	-- move units
	for actor, _ in pairs(self.actors) do
		if not actor.static then
			actor:moveInTime(dt)
			actor:_arenaBoundsCheck()
			actor:_updateLocation()
		end

		actor:onPostTick(dt * actor.time_scale)
	end
end
