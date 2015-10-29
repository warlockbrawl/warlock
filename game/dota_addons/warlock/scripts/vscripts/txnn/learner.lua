Learner = class()

-- Returns the action to perform given a state
function Learner:getAction(state) return nil end

-- Inform the learner of the new state after getAction was performed
function Learner:update(new_state) end

--[[

    QLearner, learner for continuous states and discrete actions
        * Neural network that outputs the Q values for discrete actions
        * Best action is selected (or random action if exploring)
        * Learning after performing selected action with error = Predicted Q - Actual Q

--]]

QLearner = class(Learner)

-- Creates a new QLearner
--  * input_size: Size of the state vector
--  * output_size: Size of the action vector
--  * reward_func: A function returning the reward between two states
function QLearner:init(input_size, output_size, reward_func)
	self.model = Sequence:new()
	self.model:add(LinearLayer:new(input_size, output_size))

	self.criterion = MSECriterion:new()

	self.reward_func = reward_func
end

-- Returns the action with the highest qvalue and its qvalue
function QLearner.getBestAction(action_qs)
	local max_action_q = nil
	local max_action = nil

    -- Look for the biggets Q value
	for i = 1, #action_qs do
		if not max_action or max_action_q < action_qs[i] then
			max_action_q = action_qs[i]
			max_action = i
		end
	end

	return max_action, max_action_q
end

function QLearner:getAction(state)
	self.last_action_qs = self.model:forward(state)
	
    -- Select the best action or a random action
	if math.random() > 0.2 then
		self.last_action, self.last_action_q = QLearner.getBestAction(self.last_action_qs[1])
	else
		self.last_action = math.random(1, #self.last_action_qs[1])
		self.last_action_q = self.last_action_qs[1][i]
	end
	self.old_state = state

	return self.last_action
end

function QLearner:update(new_state)
    -- Calculate the Q values of the actions of the new state
	local action_qs = self.model:forward(new_state)[1]

    -- Select the action with the best Q value, which is the value of the new state
	local _, max_action_q = QLearner.getBestAction(action_qs)

    -- Calculate the reward given the old and the new state
	local reward = self.reward_func(self.old_state, new_state)

    -- Calculate the Q value of the new state
	local actual_q = max_action_q + reward

    -- Restore the old values of the model by running the old state through it again (inefficient)
	self.model:forward(self.old_state)

    -- Create the expected Q values which is a copy of the old one with the selected actions
    -- Q value replaced
	local expected = self.last_action_qs:copy()
	expected[1][self.last_action] = actual_q

    -- Backpropagate the error
	local grad = self.criterion:calcGradient(self.last_action_qs, expected)
	self.model:backward(grad)

    -- Learn the parameters
	self.model:learn(0.03)
end


-- Learner for continous states and continous actions
ADHDPLearner = class(Learner)

function ADHDPLearner:init(state_size, reward_func)
    -- Create a model for telling the action to perform in a state
    self.action_model = Sequence:new()
    self.action_model:add(LinearLayer:new(state_size, 1))
    self.action_model:add(SigmoidLayer:new())

    -- Create a model for telling the Q value of an action and a state
    self.critic_model = Sequence:new()
    self.critic_model:add(LinearLayer:new(state_size + 1, 1))
end

function ADHDPLearner.makeStateActionMatrix(state, action)
    -- Matrix containing the state and the action
    local x = Matrix:new(1, #state[1] + 1)

    -- Copy the state
    for i = 1, #state[1] do
        x[1][i] = state[1][i]
    end

    x[1][#state[1] + 1] = self.last_action

    return x
end

function ADHDPLearner:getAction(state)
    self.old_state = state
    self.last_action = self.action_model:forward(state)[1][1]

    -- Matrix containing the state and the action
    local x = ADHDPLearner.makeStateActionMatrix(state, self.last_action)

    self.last_action_q = self.critic_model:forward(x)[1][1]

    return self.last_action
end

function ADHDPLearner:update(new_state)
    local reward = self.reward_func(self.old_state, new_state)

    local action = self.action_model:forward(new_state)[1][1]

    local action_q = reward + ADHDPLearner.makeStateActionMatrix(new_state, action)

    -- TODO: Backward and learn
end
