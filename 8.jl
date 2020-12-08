struct Command
    Name::String
    Value::Int
end

function parse_line(s)
    parts = split(s)
    name = parts[1]
    value = parse(Int, parts[2])
    return Command(name, value)
end

function run(fname)
    # read file
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    instructions = map(parse_line, lines)
    visited = Set()
    accum = 0
    idx = 1
    while true
        push!(visited, idx)

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
            println("Infinite Loop, at idx = ", idx)
            break
        end
    end


    result = accum
    println("Ran ", fname, " got ", result)
    return result
end

run("8ex.txt")
run("8.txt")
