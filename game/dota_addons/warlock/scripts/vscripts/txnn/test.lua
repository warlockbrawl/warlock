require("txnn")

math.randomseed(123)

local input = Matrix:new(1000, 1)
local expected = Matrix:new(1000, 2)

for i = 1, 1000 do
    input[i][1] = math.random()
    expected[i][1] = input[i][1] * 0.5 + 0.5
    expected[i][2] = input[i][1] * 0.25 + 0.75
end

local model = Sequence:new()
model:add(LinearLayer:new(#input[1], 10))
model:add(SigmoidLayer:new())
model:add(LinearLayer:new(10, #expected[1]))
model:add(SigmoidLayer:new())

local crit = MSECriterion:new()

for i = 1, 20 do
    local predicted = model:forward(input)

    local loss = crit:loss(predicted, expected)
    
    if i % 1 == 0 then
        print("-- Loss:", loss)
        print("Predicted:", predicted[1][1])
        print("Expected:", expected[1][1])
    end

    local grad = crit:calcGradient(predicted, expected)

    --print("Grad output:", grad)

    local grad_input = model:backward(grad)

    --print("Grad input:", grad_input)

    model:learn(0.03)
end
