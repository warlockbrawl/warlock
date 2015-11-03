Learner = class()

-- Returns the action to perform given a state
function Learner:getAction(state) return nil end

-- Inform the learner of the new state after getAction was performed
function Learner:update(new_state, reward, is_terminal) end

-- SDRRL Learner
SDRRL = class(Learner)
SDRRL.SPARSITY = 0.03
SDRRL.DISCOUNT = 0.99
SDRRL.Q_ALPHA = 0.03
SDRRL.ACTION_ALPHA = 0.01
SDRRL.SURPRISE_LEARN_FACTOR = 4.0
SDRRL.AVG_SURPRISE_DECAY = 0.01
SDRRL.GAMMA_LAMBDA = 0.98
SDRRL.GATE_BIAS_ALPHA = 0.03
SDRRL.GATE_FORWARD_ALPHA = 0.03
SDRRL.EXPLORATION_STDDEV = 0.04
SDRRL.EXPLORATION_BREAK = 0.01
SDRRL.INIT_THRESHOLD = 0.1
SDRRL.ACTION_ITER_COUNT = 25
SDRRL.ACTION_DERIVE_ALPHA = 0.05

SDRRL.generate = false
SDRRL.z0 = 0
SDRRL.z1 = 0

local function rand_normal(mean, stddev)
    SDRRL.generate = not SDRRL.generate

    if not SDRRL.generate then
        return SDRRL.z1 * stddev + mean
    end

    local u1 = 0
    local u2 = 0
    repeat
        u1 = math.random()
        u2 = math.random()
    until u1 > 0.0001

    local x = math.sqrt(-2.0 * math.log(u1)) 

	SDRRL.z0 = x * math.cos(2 * math.pi * u2)
	SDRRL.z1 = x * math.sin(2 * math.pi * u2);
	return SDRRL.z0 * stddev + mean;
end

local function sigmoid(x)
	return 1.0 / (1 + math.exp(-x))
end

local function rand_weight()
	return 0.2 * 2 * (math.random() - 0.5)
end

function SDRRL:init(state_size, action_size, cell_count)
	self.state_size = state_size
	self.action_size = action_size
	self.cell_count = cell_count
	
	self.cells = {}
	self.states = {}
	self.reconstr_errors = {}
	self.actions = {}
	self.anti_actions = {}
	self.all_actions = {}
	
	self.prev_q = 0.0
	self.avg_surprise = 0.0
	
	for i = 1, state_size do
		self.states[i] = 0.0
		self.reconstr_errors[i] = 0.0
	end
	
	-- Initialize actions and anti-actions
	for i = 1, action_size do
		local action = {
			value = 0.0,
			exp_value = 0.0,
			err = 0.0
		}
		
		local anti_action = {
			value = 0.0,
			exp_value = 0.0,
			err = 0.0
		}
	
		self.actions[i] = action
		self.anti_actions[i] = anti_action
		self.all_actions[i] = action
		self.all_actions[i + action_size] = anti_action
	end
	
	-- Build cells
	for i = 1, cell_count do
		local cell = {}
		
		-- Forward connections
		cell.forward_conn = {}
		for j = 1, state_size do
			cell.forward_conn[j] = rand_weight()
		end
		
		cell.threshold = SDRRL.INIT_THRESHOLD
		
		cell.action_bias = {
			weight = rand_weight(),
			trace = 0.0
		}
		
		-- Actions connections
		cell.action_conn = {}
		for j = 1, 2 * action_size do
			cell.action_conn[j] = {
				weight = rand_weight(),
				trace = 0.0
			}
		end
		
		cell.q_conn = {
			weight = rand_weight(),
			trace = 0.0
		}
		
		cell.action_state = 0.0
		
		self.cells[i] = cell
	end
end

function SDRRL:update(inputs, reward, is_terminal)
	-- Calculate cell excitement
	for i, cell in pairs(self.cells) do
		cell.excitation = -cell.threshold
		
		for j, input in pairs(inputs) do
			cell.excitation = cell.excitation + cell.forward_conn[j] * input
		end
	end

	-- Calculate cell states
	local num_active = SDRRL.SPARSITY * self.cell_count
	for i, cell in pairs(self.cells) do
		local num_higher = 0
		
		for j, other_cell in pairs(self.cells) do
			if cell ~= other_cell and other_cell.excitation >= cell.excitation then
				num_higher = num_higher + 1
			end
		end
		
		cell.state = num_higher < num_active and 1.0 or 0.0
	end
	
	for action_index, anti_action in pairs(self.anti_actions) do
		anti_action.value = 1.0 - self.actions[action_index].value
	end
	
	-- Action sampling
	for iter = 1, SDRRL.ACTION_ITER_COUNT do
		local q = 0.0
		
		-- Forward
		for _, cell in pairs(self.cells) do
			if cell.state > 0.0 then
				local sum = 0.0
				
				for action_index, action in pairs(self.all_actions) do
					sum = sum + cell.action_conn[action_index].weight * action.value
				end
				
				cell.action_state = sigmoid(sum) * cell.state
				
				q = q + cell.q_conn.weight * cell.action_state
			else
				cell.action_state = 0.0
			end
		end
		
		-- Action improvement
		for _, cell in pairs(self.cells) do
			cell.action_error = cell.q_conn.weight * cell.action_state * (1.0 - cell.action_state)
		end
		
		for action_index, action in pairs(self.all_actions) do
			local sum = 0.0
			
			for _, cell in pairs(self.cells) do
				sum = sum + cell.action_conn[action_index].weight * cell.action_error
			end
			
			action.err = sum
		end
		
		for action_index, action in pairs(self.actions) do
			action.value = math.min(1.0, math.max(0.0, action.value + SDRRL.ACTION_DERIVE_ALPHA * (action.err - self.anti_actions[action_index].err > 0.0 and 1.0 or -1.0)))
		end
		
		for action_index, action in pairs(self.anti_actions) do
			action.value = 1.0 - self.actions[action_index].value
		end
	end
	
	-- Exploration
	for _, action in pairs(self.all_actions) do
		if math.random() < SDRRL.EXPLORATION_BREAK then
			action.exp_value = math.random()
		else
            local rnd = rand_normal(0, SDRRL.EXPLORATION_STDDEV)
            action.exp_value = math.min(1.0, math.max(0.0, action.value + rnd))
			-- action.exp_value = math.min(1, math.max(0, action.value + SDRRL.EXPLORATION_STDDEV * 2 * (math.random() - 0.5)))
		end
	end
	
	-- Forward
	local q = 0.0
	for _, cell in pairs(self.cells) do
		if cell.state > 0.0 then
			local sum = 0.0
			
			for action_index, action in pairs(self.all_actions) do
				sum = sum + cell.action_conn[action_index].weight * action.exp_value
			end
			
			cell.action_state = sigmoid(sum) * cell.state
			
			q = q + cell.q_conn.weight * cell.action_state
		else
			cell.action_state = 0.0
		end
	end
	
	local td_error = reward + SDRRL.DISCOUNT * q - self.prev_q
	local q_alpha_td_error = SDRRL.Q_ALPHA * td_error
	local action_alpha_td_error = SDRRL.ACTION_ALPHA * td_error
	
	local surprise = td_error * td_error
	local learn_pattern = sigmoid(SDRRL.SURPRISE_LEARN_FACTOR * (surprise - self.avg_surprise))
	self.avg_surprise = (1.0 - SDRRL.AVG_SURPRISE_DECAY) * self.avg_surprise + SDRRL.AVG_SURPRISE_DECAY * surprise
	
	-- Update weights
	for _, cell in pairs(self.cells) do
		local err = cell.q_conn.weight * cell.action_state * (1.0 - cell.action_state)
		cell.action_bias.weight = cell.action_bias.weight + action_alpha_td_error * cell.action_bias.trace
		cell.action_bias.trace = cell.action_bias.trace * SDRRL.GAMMA_LAMBDA + err
		
		for action_index, action in pairs(self.all_actions) do
			cell.action_conn[action_index].weight = cell.action_conn[action_index].weight + action_alpha_td_error * cell.action_conn[action_index].trace
			cell.action_conn[action_index].trace = cell.action_conn[action_index].trace * SDRRL.GAMMA_LAMBDA + err * action.exp_value
		end
		
		cell.q_conn.weight = cell.q_conn.weight + q_alpha_td_error * cell.q_conn.trace
		cell.q_conn.trace = cell.q_conn.trace * SDRRL.GAMMA_LAMBDA + cell.action_state
	end
	
	-- Reconstruct
	for i, _ in pairs(self.reconstr_errors) do
		local reconstr = 0.0
		
		for _, cell in pairs(self.cells) do
			reconstr = reconstr + cell.forward_conn[i] * cell.state
		end
		
		self.reconstr_errors[i] = inputs[i] - reconstr
	end
	
	-- Learn SDRs
	for _, cell in pairs(self.cells) do
		if cell.state > 0.0 then
			for i = 1, self.state_size do
				cell.forward_conn[i] = cell.forward_conn[i] + SDRRL.GATE_FORWARD_ALPHA * learn_pattern * cell.state * self.reconstr_errors[i]
			end
		end
		
		cell.threshold = cell.threshold + SDRRL.GATE_BIAS_ALPHA * (cell.state - SDRRL.SPARSITY)
	end
	
	self.prev_q = q
end

function SDRRL:getAction()
    local actions = {}
    for _, action in pairs(self.actions) do
        table.insert(actions, action.exp_value)
    end
    return actions
end

-- Action Gradient Learner
AGLearner = class(Learner)

function AGLearner:init(state_size, action_size, opts)
    self.state_size = state_size
    self.action_size = action_size

    -- Create a model outputting the Q value of state-action pairs
    self.model = Sequence:new()
    self.model:add(LinearLayer:new(state_size + action_size, 10))
    self.model:add(SigmoidLayer:new())
    self.model:add(LinearLayer:new(10, 1))

    self.criterion = MSECriterion:new()

    opts = opts or {}

    self.exploration_chance = opts.exploration_chance or 0.2
    self.q_learn_rate = opts.q_learn_rate or 0.03
    self.action_iter_count = opts.action_iter_count or 100
    self.action_learn_rate = opts.action_learn_rate or 0.03
    self.q_discount = opts.q_discount or 0.99
end

function AGLearner:calcAction(state)
    local action = Matrix:new(1, self.action_size, 0)
    local iters = -1

    for i = 1, self.action_iter_count do
        -- Calculate the Q value of the state-action pair
        self.model:forward(action:concath(state))

        -- Backpropagate 1
        local grad = self.model:backward(Matrix:new(1, 1, -1))

        -- Take only the gradient of the action without the state
        local action_grad = grad:subm(1, 1, 1, self.action_size)

        --print(i, "action grad norm:", action_grad:normmax())
        if i % 20 == 0 then
            print(i, "norm:", action_grad:normmax())
        end

        -- Use only sign of gradients
        action_grad = action_grad:replace(function(x) if x > 0 then return 1 end return -1 end)

        -- Update the action
        for j = 1, #action[1] do
            action[1][j] = math.max(-1, math.min(1, action[1][j] - self.action_learn_rate * action_grad[1][j]))
        end
    end

    print("Action:", action)

    self.model:learn(0) -- Forget gradients
    local action_q = self.model:forward(action:concath(state))[1][1]

    return action, action_q
end

-- Called when a new action is to be performed
function AGLearner:getAction(state)
    self.old_state = state

    local action = nil
    local action_q = nil

    self.c = (self.c or 0) + 1

    if math.random() > self.exploration_chance then
        action, action_q = self:calcAction(state)
    else
        action = Matrix:new(1, self.action_size):replace(function(x) return 5*(math.random()-0.5) end)
        action_q = self.model:forward(action:concath(state))[1][1]
    end

    self.predicted_q = action_q

    return action
end

-- Called when a new state is known after performing an action
function AGLearner:update(new_state, reward, is_terminal)
    local actual_q = reward

    if not is_terminal then
        -- Calculate the new action to perform
        local action, action_q = self:calcAction(new_state)

        -- Calculate the actual Q value
        actual_q = actual_q + self.q_discount * action_q
    end

    print("new_state:", new_state)
    print("Predicted:", self.predicted_q, "actual:", actual_q, "reward:", reward)

    -- Update the model using the TD error
    local grad = self.criterion:calcGradient(Matrix:new(1, 1, self.predicted_q), Matrix:new(1, 1, actual_q))
    self.model:backward(grad)

    self.model:learn(self.q_learn_rate)
end
