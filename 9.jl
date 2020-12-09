using Test;

function find_pair(prev_lines, val)
    for i in 1:length(prev_lines)
        for j in (i + 1):length(prev_lines)
            if prev_lines[i] + prev_lines[j] == val
                return true
            end
        end
    end
    return false
end

function parse_line(s)
    return parse(Int64, s)
end
function run(fname, preamble_length)
    # read file
    f = open(fname, "r")
    lines = map(parse_line, readlines(f))
    close(f)


    result = -1
    for (idx, val) in enumerate(lines)
        if idx > preamble_length
            if ! find_pair(lines[idx - preamble_length:idx - 1], val)
                result = val
                break
            end
        end
    end

    println("Ran ", fname, " got ", result)
    return result
end

@test run("9ex.txt", 5) == 127
run("9.txt", 25)


