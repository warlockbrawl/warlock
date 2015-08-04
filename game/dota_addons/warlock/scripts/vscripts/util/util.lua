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
