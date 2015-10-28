Learner = class()

function Learner:init(input_size, output_size, reward_func)
	self.model = Sequence:new()
	self.model:add(LinearLayer:new(input_size, 30))
	self.model:add(SigmoidLayer:new(30, 30))
	self.model:add(LinearLayer:new(30, output_size))

	self.criterion = MSECriterion:new()

	self.reward_func = reward_func
end

function Learner:getBestAction(action_qs)
	local max_action_q = nil
	local max_action = nil

	for i = 1, #action_qs do
		if not max_action or max_action_q < action_qs[i] then
			max_action_q = action_qs[i]
			max_action = i
		end
	end

	return max_action, max_action_q
end

function Learner:getAction(state)
	self.last_action_qs = self.model:forward(state)
	
	if math.random() > 0.2 then
		self.last_action, self.last_action_q = self:getBestAction(self.last_action_qs[1])
	else
		self.last_action = math.random(1, #self.last_action_qs[1])
		self.last_action_q = self.last_action_qs[1][i]
	end
	self.old_state = state

	return self.last_action
end

function Learner:update(new_state)
	local action_qs = self.model:forward(new_state)[1]

	local _, max_action_q = self:getBestAction(action_qs)

	local reward = self.reward_func(self.old_state, new_state)

	local actual_q = max_action_q + reward

	self.model:forward(self.old_state)

	local expected = self.last_action_qs:copy()
	expected[1][self.last_action] = actual_q

	print("-------------- ")
	print("Reward:", reward)
	print("Loss:", self.criterion:loss(self.last_action_qs, expected))
	local grad = self.criterion:calcGradient(self.last_action_qs, expected)

	self.model:backward(grad)
	self.model:learn(0.03)
end
