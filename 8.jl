using Test;
# Learnings
# - structs must be mutable to update them
# - be careful with variable scopings
# - `@test` works similarly to `@assert` but provides feedback on the failure

mutable struct Command
    Name::String
    Value::Int
end

function parse_line(s)
    parts = split(s)
    name = parts[1]
    value = parse(Int, parts[2])
    return Command(name, value)
end

function swap!(cmd)
    if cmd.Name == "jmp"
        cmd.Name = "nop"
    elseif cmd.Name == "nop"
        cmd.Name = "jmp"
    end
end

function run(fname)
    # read file
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    result = -1
    instructions = map(parse_line, lines)
    inf_loop = true
    for idx_to_swap in 1:length(instructions)
        # try swapping an instruction
        if idx_to_swap > 1
            swap!(instructions[idx_to_swap - 1])
        end
        swap!(instructions[idx_to_swap])

        idx = 1
        accum = 0
        visited = Set()
        while true
            push!(visited, idx)
            if idx > length(instructions)
                inf_loop = false
                break
            end

            cmd = instructions[idx]
            if cmd.Name == "nop"
                idx += 1
            elseif cmd.Name == "acc"
                idx += 1
                accum += cmd.Value
            elseif cmd.Name == "jmp"
                idx += cmd.Value
            end

            if in(idx, visited)
                # println("Infinite Loop, at idx = ", idx)
                break
            end
        end

        if ! inf_loop
            result = accum
            break
        end
    end

    println("Ran ", fname, " got ", result)
    return result
end

@test run("8ex.txt") == 8

run("8.txt")
