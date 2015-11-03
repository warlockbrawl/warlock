-- Creates a copy of a table copying every table entry
function copy_shallow(t)
    local t_copy = {}

    for k, v in pairs(t) do
        t_copy[k] = v
    end

    return t_copy
end

-- Extends a table using another table
function extend_table(t_to_extend, t_extensions)
    for k, v in pairs(t_extensions) do
        t_to_extend[k] = v
    end
end

-- Copies a table and applies extensions from another table to it
function copy_extend(t_to_copy, t_extensions)
    local c = copy_shallow(t_to_copy)
    extend_table(c, t_extensions)
    return c
end

-- Normal Distribution
local generate = false
local z0 = 0
local z1 = 0

function rand_normal(mean, stddev)
    generate = not generate

    if not generate then
        return z1 * stddev + mean
    end

    local u1 = 0
    local u2 = 0
    repeat
        u1 = math.random()
        u2 = math.random()
    until u1 > 0.0001

    local x = math.sqrt(-2.0 * math.log(u1)) 

    z0 = x * math.cos(2 * math.pi * u2)
    z1 = x * math.sin(2 * math.pi * u2);
    return z0 * stddev + mean;
end
