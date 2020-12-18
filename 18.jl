
using Test;

function run(fname, version=1)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    result = 0
    for l in lines
        if version == 1
            result += compute(l)
        elseif version == 2
            result += compute2(l)
        end
    end

    println("[Part ", version, "] Result = ", result)
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
function compute(s, version=1)
    if occursin('(', s)
        # if you find a pair of parenthesis, compute what's inside recursively
        start_idx = findlast(isequal('('), s)
        end_idx = findnext(isequal(')'), s, start_idx)

        pre = s[1:start_idx - 1]
        mid = compute(s[start_idx + 1:end_idx - 1], version)
        post = s[end_idx + 1:length(s)]
        return compute(pre * string(mid) * post, version)
    else
        parts = split(s)
        while length(parts) > 1
            start = 1
            if version == 2 && in("+", parts)
                # "Advanced Math": plus is resolved before multiply
                start = findfirst(isequal("+"), parts) - 1
            end
            val = resolve(parts[start:start + 2])
            parts = [parts[1:start - 1]..., string(val), parts[start + 3:length(parts)]...]
        end

        total = parse(Int, parts[1])
        return total
    end
end

function resolve(list)
    # println(list)
    # given a list of 3 items (value1, operation, value2), reduces to 1 item (output value)
    v1 = parse(Int, list[1])
    v2 = parse(Int, list[3])
    op = add
    if list[2] == "*"
        op = multiply
    end

    return op(v1, v2)
end

function compute2(s)
    return compute(s, 2)
end

# @test compute("1 + 2 * 3 + 4 * 5 + 6") == 71
# @test compute("2 * 3 + (4 * 5)") == 26
# @test compute("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 437
# @test compute("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 12240
# @test compute("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 13632

# run("18.txt")

@test resolve(["1", "+", "3"]) == 4
@test resolve(["1", "*", "3"]) == 3

@test compute2("1 + 2 * 3 + 4 * 5 + 6") == 231
@test compute2("1 + (2 * 3) + (4 * (5 + 6))") == 51
@test compute2("2 * 3 + (4 * 5)") == 46
@test compute2("5 + (8 * 3 + 9 + 3 * 4 * 3)") == 1445
@test compute2("5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))") == 669060
@test compute2("((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2") == 23340

run("18.txt", 2)
