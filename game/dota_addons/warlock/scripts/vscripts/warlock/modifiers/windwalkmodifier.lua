WindWalkModifier = class(Modifier)

--- Params
-- damage
-- hit_sound

function WindWalkModifier:init(def)
	WindWalkModifier.super.init(self, def)
	
	self.damage = def.damage
	self.hit_sound = def.hit_sound
end

-- Called when the modifier is turned on or off
function WindWalkModifier:onToggle(apply)
	-- Enable/Disable collision with other warlocks
	local cc = self.pawn.collision_components["pawn"]
	if cc then
		cc.coll_mat[Player.ALLIANCE_ENEMY][CollisionComponent.CHANNEL_PLAYER] = not apply
		cc.coll_mat[Player.ALLIANCE_ALLY][CollisionComponent.CHANNEL_PLAYER] = not apply
	end
	
	-- Add / remove temp cc
	if(apply) then
		self.pawn:addCollisionComponent {
			id = 'windwalk',
			channel = CollisionComponent.CHANNEL_PLAYER,
			coll_mat = CollisionComponent.createCollMatSimple(
				{Player.ALLIANCE_ENEMY},
				{CollisionComponent.CHANNEL_PLAYER}),
			radius = 60,
			ellastic = false
		}
	else
		self.pawn:removeCollisionComponent("windwalk")
	end
	
	WindWalkModifier.super.onToggle(self, apply)
end

-- Called when the owning pawn collides
function WindWalkModifier:onCollision(coll_info, cc)
	if(cc.id == 'windwalk') then
		local knockback = 1.0
		
		-- Check if self has thrust
		local thrust_mod = self.pawn:getModifierOfType(ThrustModifier)
		if thrust_mod then
			-- reduce kb if theres both WW and thrust
			knockback = 0.7
			thrust_mod.knockback = knockback
			
			-- Execute thrust hit which also removes its modifier
			thrust_mod:hitPawn(coll_info.actor, coll_info.hit_normal)
		end
		
		-- Deal damage to the hit pawn
		coll_info.actor:receiveDamage {
			source = self.pawn,
			hit_normal = coll_info.hit_normal,
			amount = self.damage,
			knockback_factor = knockback
		}
		
		-- Play a sound
		if self.hit_sound then
			self.pawn.unit:EmitSound(self.hit_sound)
		end
		
		GAME:removeModifier(self)
	end
end

-- Called when the owning pawn casts a spell
function WindWalkModifier:onSpellCast(cast_info)
	GAME:removeModifier(self)
end
