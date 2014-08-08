--- classes
-- @author Krzysztof Lis (Adynathos)

--- Create a new class
-- @param superclass Parent class

-- Object
Object = {}
Object.__index = Object

function Object:init()
	print("Object:init()")
end

function Object:new(...)
	local obj = {}

	-- assign the class to the object
	setmetatable(obj, self)

	-- Call the constructor
	obj:init(...)

	return obj
end

function Object:slot(func_name)
	return function( ... )
		self[func_name](self, ...)
	end
end

function Object:instanceof(cls)
	local my_class = self.class

	while my_class ~= nil do
		if my_class == cls then
			return true
		else
			my_class = my_class.super
		end
	end

	return false
end

-- Class constructor
function class(superclass)
	if superclass == nil then
		superclass = Object
	end

	local cls = {}	-- the class object

	-- Class will be a metatable for its instances
	cls.__index = cls

	cls.class = cls
	cls.super = superclass


	-- If something is not found in cls,
	-- the superclass will be searched for it
	setmetatable(cls, superclass)

	return cls
end
