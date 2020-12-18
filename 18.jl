
using Test;

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    result = 0
    for l in lines
        result += compute(l)
    end

    println("[Part 1] Result = ", result)
    return result
end

function add(a, b)
    return a + b
end

function multiply(a, b)
    return a * b
end

funcs = Dict()
funcs["+"] = add
funcs["*"] = multiply

# WARNING: This is special math
function compute(s)
    # println("COMPUTE: ", s)

    if in('(', s)
        # if you find a pair of parenthesis, compute what's inside recursively
        start_idx = findlast(isequal('('), s)
        end_idx = findnext(isequal(')'), s, start_idx)

        pre = s[1:start_idx - 1]
        mid = compute(s[start_idx + 1:end_idx - 1])
        post = s[end_idx + 1:length(s)]
        return compute(pre * string(mid) * post)
    else
        parts = split(s)
        total = parse(Int, parts[1])
        parts = parts[2:length(parts)]
        while length(parts) > 1
            op = add
            if parts[1] == "*"
                op = multiply
            end
            val = parse(Int, parts[2])

            total = op(total, val)
            parts = parts[3:length(parts)] # remove first two
        end

        return total
    end
end

@test compute("1 + 2 * 3 + 4 * 5 + 6") == 71
@test compute("2 * 3 + (4 * 5)") == 26
@test compute("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437
@test compute("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240
@test compute("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632

run("18.txt")
