--- Task manager
-- @author Krzysztof Lis (Adynathos)

-------------------------------------------------------------------------------
--- Class Task

Task = class()

--- Task constructor
--@param task_def.id Id used for searching for tasks
--@param task_def.game Game object, set automatically
--@param task_def.args Arguments to pass to the function
--@param task_def.func Function to be called. Function should take 2 arguments:
--	args and task
--@param task_def.time Time when task should be executed.
--@param task_def.period Execute task in a loop every period time.
--@param task_def.attributes Attributes which will be assigned to the task
function Task:init(task_def)
	if task_def.attributes then
		for k,v in pairs(task_def.attributes) do
			self[k] = v
		end
	end

	self.id = task_def.id or 'task'
	self.game = task_def.game

	self.action = task_def.func
	self.args = task_def.args or {}

	self.time = (task_def.time or task_def.period or 0) + self.game:time()
	self.period = task_def.period

	self.active = true

	-- if self.time == nil then
	-- 	if self.period ~= nil then
	-- 		self.time = self.game:time() + self.period
	-- 	else
	-- 		self.time = 0
	-- 	end
	-- end
end

function Task:execute()
	status, err_msg = pcall(self.action, self.args, self)

	if status then
		-- If this is a periodic task and not deleted, add itself again
		if self.active and self.period ~= nil then
			self.time = self.time + self.period
			self.game:_submitTask(self)
		end
	else
		err('Task "'..self.id..'" failed: '..err_msg)
	end
end

function Task:cancel()
	self.active = false
	self.game:_removeTask(self)
end
-------------------------------------------------------------------------------


function Game:initTaskManager()
	self.taskSet = Set:new()
	self.taskHeap = heap()
end

--- Add a (timed) task
--@see Task:init
function Game:addTask(task_def)
	task_def.game = self
	local task = Task:new(task_def)
	self:_submitTask(task)

	return task
end

--- Call a function in the next event loop iteration
function Game:async(func)
	return self:addTask{func=func}
end

function Game:_submitTask(task)
	self.taskSet:add(task)
	self.taskHeap:insert(task.time, task)
end

function Game:_removeTask(task)
	self.taskSet:remove(task)
	-- cannot remove from the heap
end

function Game:tickTaskManager()
	local time = self:time()

	-- Get new tasks from the top of the heap
	while (not self.taskHeap:empty()) and self.taskHeap:top() <= time do

		-- Pop the task to be executed
		next_task_time, task = self.taskHeap:pop()
		self.taskSet:remove(task)

		if task.active then
			task:execute()
		end

		-- If it is a periodic task, it will add itself in execute
	end

end


