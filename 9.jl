using Test;

# Learning:
# - my first "multiple dispatch"... I added a fallback here so that
#   minimum will still work even though I'm giving one Float (±Inf) and one Int
# - Also, apparently I can type `\pm` and VSCode will convert it to ± for Julia magic. Cool!
function minimum(a, b)
    return a < b ? a : b
end

function maximum(a, b)
    return a > b ? a : b
end

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

function run2(fname, target)
    # read file
    f = open(fname, "r")
    lines = map(parse_line, readlines(f))
    close(f)

    result = -1
    len = length(lines)
    for idx in 1:len
        total = 0
        low = +Inf
        high = -Inf
        inner_idx = idx
        while total < target && inner_idx <= len
            val = lines[inner_idx]
            low = minimum(low, val)
            high = maximum(high, val)
            total += val
            inner_idx += 1
        end

        if total == target
            println("Total = ", total, " Low = ", low, " High = ", high)
            result = low + high
            break
        end
    end

    println("[part 2] Ran ", fname, " got ", result)
    return result
end



@test run("9ex.txt", 5) == 127
run("9.txt", 25)

@test run2("9ex.txt", 127) == 62
run2("9.txt", 3199139634)
