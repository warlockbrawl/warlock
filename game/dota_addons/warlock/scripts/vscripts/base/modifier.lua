Modifier = class()
modifiers = {}
modifiers_by_type = {}

--- Params
-- pawn
--- (Optional)
-- temporary (destroy on new round etc)
-- time (lifetime)
-- id
-- dmg_reduction_abs
-- dmg_reduction_rel
-- speed_bonus_abs
-- kb_reduction
-- hp_bonus
-- mass
-- hp_regen

function Modifier:init(def)
	self.enabled = false

	self.pawn = def.pawn

	if def.id then
		self.id = def.id
	else
		self.id = ""
	end

	if def.temporary then
		self.temporary = def.temporary
	else
		self.temporary = false
	end

	if def.time then
		self.temporary = true -- force temporary
		self.time = def.time

		GAME:addTask {
			time = self.time,
			func = function()
				GAME:removeModifier( self)
			end
		}
	end

    if def.loop_sound then
        self.loop_sound = def.loop_sound
        local loop_duration = def.loop_duration or 1.0

        -- Play the sound
        if self.pawn.unit then
            self.pawn.unit:EmitSound(self.loop_sound)
        end

        self.sound_loop_task = GAME:addTask {
            period = loop_duration,
            func = function()
                log("In loop")

                if self.pawn.unit then
                    self.pawn.unit:EmitSound(self.loop_sound)
                end
            end
        }
    end


	self.dmg_reduction_rel = def.dmg_reduction_rel or 0
	self.dmg_reduction_abs = def.dmg_reduction_abs or 0
	self.speed_bonus_abs = def.speed_bonus_abs or 0
	self.hp_bonus = def.hp_bonus or 0
	self.hp_regen = def.hp_regen or 0
	self.kb_reduction = def.kb_reduction or 0
	self.mass = def.mass or 0
	self.debuff_factor = def.debuff_factor or 0
	
	self.native_mod = def.native_mod
end

function Modifier:toggle(apply)
	-- Do nothing if state is unchanged
	if self.enabled ~= apply then
		self:onToggle(apply)
		self.enabled = apply
	end
end

function Modifier:onToggle(apply)
	local p = self.pawn
	
	-- Add or remove stats
	if p then
		local u = p.unit
		
		if(apply) then
			sign = 1
			
			if self.native_mod then
				p:addNativeModifier(self.native_mod)
			end
		else
			sign = -1
			
			if self.native_mod then
				p:removeNativeModifier(self.native_mod)
			end

            if self.sound_loop_task then
                -- Cancel the sound loop timer
                self.sound_loop_task:cancel()

                -- Stop the currently playing loop sound
                u:StopSound(self.loop_sound)
            end
		end
		
		p.move_speed = p.move_speed + sign * self.speed_bonus_abs
		p.max_hp = p.max_hp + sign * self.hp_bonus
		p.hp_regen = p.hp_regen + sign * self.hp_regen
		p.mass = p.mass + sign * self.mass
		p.dmg_factor = p.dmg_factor - sign * self.dmg_reduction_rel
		p.kb_factor = p.kb_factor - sign * self.kb_reduction
		p.dmg_reduction = p.dmg_reduction + sign * self.dmg_reduction_abs
		p.debuff_factor = p.debuff_factor + sign * self.debuff_factor
		
		p:applyStats()
	end
end

-- Events

-- Called after all dmg modifiers are applied, returns dmg change
function Modifier:modifyDamageTaken(dmg_info)
	return 0
end

-- Called after all dmg modifiers are applied and kb was dealt, returns dmg change
function Modifier:modifyDamagePostKB(dmg_info)
	return 0
end

function Modifier:onDeath()
	if self.temporary then
		GAME:removeModifier(self)
	end
end

function Modifier:onCollision(coll_info, cc)

end

function Modifier:onSpellCast()

end

-- Round start etc.
function Modifier:onReset()
	if self.temporary then
		GAME:removeModifier(self)
	end
end

function Modifier:onPreTick(dt)
	
end

----------------------
--- Game Interface
----------------------

-- Add / Remove modifiers

function Game:addModifier(mod)
	if(mod.pawn) then
        -- Add to modifiers by pawn list
		if not modifiers[mod.pawn] then
			modifiers[mod.pawn] = Set:new()
		end

        -- Add to modifiers by type list
        local t = mod.class
        if not modifiers_by_type[t] then
            modifiers_by_type[t] = Set:new()
        end

		modifiers[mod.pawn]:add(mod)
        modifiers_by_type[t]:add(mod)
	end

	mod:toggle(true)
end

function Game:removeModifier(mod)
	mod:toggle(false)

	if(mod.pawn) then
		modifiers[mod.pawn]:remove(mod)
        modifiers_by_type[mod.class]:remove(mod)
		mod.pawn = nil
	end
end

function Game:getModifiers(pawn)
    return modifiers[pawn]
end

function Game:getModifiersOfType(t)
    local mods = modifiers_by_type[t]

    if mods == nil then
        return Set:new()
    end

    return mods
end

function Pawn:hasModifierOfType(t)
	if modifiers[self] then
		for mod, _ in pairs(modifiers[self]) do
			if mod:instanceof(t) then
				return true
			end
		end
	end

	return false
end

function Pawn:getModifierOfType(t)
	if modifiers[self] then
		for mod, _ in pairs(modifiers[self]) do
			if mod:instanceof(t) then
				return mod
			end
		end
	end

	return nil
end

-- Events

-- Called before kb is dealt, returns dmg change
function Game:modDamageTaken(pawn, dmg_info)
	if(modifiers[pawn]) then
		local dmg_change = 0

		modifiers[pawn]:foreach(function(mod)
			dmg_change = dmg_change + mod:modifyDamageTaken(dmg_info)
		end)

		return dmg_change
	end

	return 0
end

-- Called after kb was dealt, returns dmg change
function Game:modDamagePostKB(pawn, dmg_info)
	if(modifiers[pawn]) then
		local dmg_change = 0

		modifiers[pawn]:foreach(function(mod)
			dmg_change = dmg_change + mod:modifyDamagePostKB(dmg_info)
		end)

		return dmg_change
	end

	return 0
end

-- Called when the owning pawn dies
function Game:modOnDeath(pawn)
	if(modifiers[pawn]) then
		modifiers[pawn]:foreach(function(mod)
			mod:onDeath()
		end)
	end
end

-- Called when the owning pawn collides
function Game:modOnCollision(coll_info, cc)
	if(modifiers[cc.actor]) then
		modifiers[cc.actor]:foreach(function(mod)
			mod:onCollision(coll_info, cc)
		end)
	end
end

-- Called when the owning pawn resets (round change)
function Game:modOnReset()
	for _, modset in pairs(modifiers) do
		modset:foreach(function(mod)
			mod:onReset()
		end)
	end
end

-- Called when the owning pawn casts a spell
function Game:modOnSpellCast(cast_info)
	local pawn = cast_info.caster_actor

	if(modifiers[pawn]) then
		modifiers[pawn]:foreach(function(mod)
			mod:onSpellCast(cast_info)
		end)
	end
end

function Game:modOnPreTick(pawn, dt)
	if(modifiers[pawn]) then
		modifiers[pawn]:foreach(function(mod)
			mod:onPreTick(dt)
		end)
	end
end
