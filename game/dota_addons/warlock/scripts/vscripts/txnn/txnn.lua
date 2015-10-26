require("class")

Matrix = require("matrix")

Layer = class()
Layer.forward = function(input) return nil end
Layer.backward = function(grad_output) return nil end
Layer.learn = function(learn_rate) end

----------------------------------------
-- Sequence contains multiple layers
----------------------------------------

Sequence = class(Layer)

function Sequence:init(def)
    self.layers = {}
end

function Sequence:add(layer)
    table.insert(self.layers, layer)
end

function Sequence:forward(input)
    self.input = input
    
    local next_input = input
    for _, layer in pairs(self.layers) do
        next_input = layer:forward(next_input)
    end

    self.output = next_input
    return next_input
end

function Sequence:backward(grad_output)
    local last_grad_output = grad_output

    for i = #self.layers, 1, -1 do
        last_grad_output = self.layers[i]:backward(last_grad_output)
    end

    self.grad_input = last_grad_output
    return last_grad_output
end

function Sequence:learn(learn_rate)
    for _, layer in pairs(self.layers) do
        layer:learn(learn_rate)
    end
end

----------------------------------------
-- Linear transformation layer
----------------------------------------

LinearLayer = class(Layer)

function LinearLayer:init(input_size, hidden_size)
    self.input_size = input_size
    self.hidden_size = hidden_size
    self.weights = Matrix:new(self.input_size, self.hidden_size):replace(function(x)
        return 2.0 * math.random() - 1.0
    end)
    self.bias = Matrix:new(self.hidden_size, 1):replace(function(x)
        return 2.0 * math.random() - 1.0
    end)
end

-- BxF * FxO + BxO = BxO
function LinearLayer:forward(input)
    self.input = input

    -- Copy the same bias for every batch sample
    b = Matrix:new(#input, self.hidden_size)
    for i = 1, #b do
        for j = 1, self.hidden_size do
            b[i][j] = self.bias[j][1]
        end
    end

    self.output = input * self.weights + b

    return self.output
end

function LinearLayer:backward(grad_output)
    self.grad_output = grad_output

    self.grad_input =  self.weights * grad_output:transpose()
    return self.grad_input:transpose()
end

function LinearLayer:learn(learn_rate)
    self.weights = self.weights - learn_rate * self.input:transpose() * self.grad_output
    self.bias = self.bias - learn_rate * self.grad_output:transpose()
end

----------------------------------------
-- Sigmoid layer
----------------------------------------

SigmoidLayer = class(Layer)

function SigmoidLayer:init(def)
    self.func = function(x)
        return 1.0 / (1 + math.exp(-x))
    end
end

function SigmoidLayer:forward(input)
    self.input = input

    self.output = self.input:replace(self.func)
    return self.output
end

function SigmoidLayer:backward(grad_output)
    self.grad_output = grad_output

    self.grad_input = self.output:replace(function(x) return x * (1 - x) end)

    for i = 1, #self.grad_input do
        for j = 1, #self.grad_input[i] do
            self.grad_input[i][j] = grad_output[i][j] * self.grad_input[i][j]
        end
    end

    return self.grad_input
end

----------------------------------------
-- Mean Squared Error Layer
----------------------------------------

Criterion = class()
Criterion.loss = function(predicted, expected) return nil end

MSECriterion = class(Criterion)

function MSECriterion:init(def)
end

function MSECriterion:loss(predicted, expected)
    local diff = predicted - expected
    local l = 0

    for i = 1, #diff do
        local batch_l = 0

        for j = 1, #diff[i] do
            batch_l = batch_l + diff[i][j] * diff[i][j]
        end

        l = l + batch_l
    end

    l = l / #diff

    return 0.5 * l
end

function MSECriterion:calcGradient(predicted, expected)
    return predicted - expected
end
