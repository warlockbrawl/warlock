require("txnn")


function test_mlp_regression()
    math.randomseed(123)

    -- Create some training data
    local input = Matrix:new(1000, 1)
    local expected = Matrix:new(1000, 2)
    for i = 1, 1000 do
        input[i][1] = math.random()
        expected[i][1] = input[i][1] * 0.5 + 0.5
        expected[i][2] = input[i][1] * 0.25 + 0.75
    end

    -- Create a multilayer perceptron with 10 hidden units
    -- fancy term for y = f(W2*f(W1*x))
    local model = Sequence:new()
    model:add(LinearLayer:new(#input[1], 10))
    model:add(SigmoidLayer:new())
    model:add(LinearLayer:new(10, #expected[1]))
    model:add(SigmoidLayer:new())

    -- Create a mean squared error criterion (error = (predicted - actual)^2)
    local crit = MSECriterion:new()

    for i = 1, 20 do
        -- Predict the output using the input
        local predicted = model:forward(input)

        -- Calculate the error of the prediction
        local loss = crit:loss(predicted, expected)

        print("-- Loss:", loss)
        print("Predicted:", predicted[1][1])
        print("Expected:", expected[1][1])

        -- Calculate the gradient at the output
        local grad = crit:calcGradient(predicted, expected)

        -- Backpropagate the gradient to calculate all gradients
        local grad_input = model:backward(grad)

        -- Learn the parameters
        model:learn(0.03)
    end
end

function test_mlp_classification()
    math.randomseed(123)

    -- Create some training data
    local input = Matrix:new(10, 1)
    local expected = Matrix:new(10, 1)
    for i = 1, 10 do
        input[i][1] = math.random()
        expected[i][1] = input[i][1] > 0.5 and 1 or 2
    end

    -- Create a multilayer perceptron with 10 hidden units
    -- fancy term for y = f(W2*f(W1*x))
    local model = Sequence:new()
    model:add(LinearLayer:new(#input[1], 10))
    model:add(SigmoidLayer:new())
    model:add(LinearLayer:new(10, #expected[1]))
    model:add(LogSoftMaxLayer:new())

    -- Create a mean squared error criterion (error = (predicted - actual)^2)
    local crit = ClassNLLCriterion:new()

    for i = 1, 100 do
        -- Predict the output using the input
        local predicted = model:forward(input)

        -- Calculate the error of the prediction
        local loss = crit:loss(predicted, expected)

        print("-- Loss:", loss)
        print("Predicted:", predicted[1][1])
        print("Expected:", expected[1][1])

        -- Calculate the gradient at the output
        local grad = crit:calcGradient(predicted, expected)

        -- Backpropagate the gradient to calculate all gradients
        local grad_input = model:backward(grad)

        -- Learn the parameters
        model:learn(0.03)
    end
end

test_mlp_classification()
--test_mlp_regression()