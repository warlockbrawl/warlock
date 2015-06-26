--- Set
-- @author Krzysztof Lis (Adynathos)

Set = class()

function Set:init(elements)
	-- if an array of elements was passed, load its elements
	if type(elements) == "table" then
		for index, value in pairs(elements) do
			self:add(value)
		end
	end
end

function Set:add(obj)
	if obj ~= nil then self[obj] = true end
	return self
end

function Set:remove(obj)
	if obj ~= nil then self[obj] = nil end
	return self
end

function Set:contains(obj)
	return self[obj] ~= nil
end

--- Iterate over the set with a function
-- additional arguments are passed to the iteration function
function Set:foreach(func, ...)
	for elem in pairs(self) do
		func(elem, ...)
	end
end

function Set:toList()
	local elements = {}

	for elem, _ in pairs(self) do
		table.insert(elements, elem)
	end

	return elements
end
