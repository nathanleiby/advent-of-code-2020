using Test;

function expand(rules, num)::String
    # base case
    if typeof(rules[num]) == String
        # println(offset, rules[num])
        return rules[num]
    else
    # recursive case
        options = []
        for choice in rules[num] # things separated by '|'
            val = ""
            for r in choice # numbers in the rule
                val *= expand(rules, r)
            end
            push!(options, val)
        end
        out = join(options, "|")
        return "($out)"
    end
end

function parse_input(lines)
    messages = []
    rules = Dict()
    for l in lines
        println(l)
        if l == ""
            continue
        elseif ':' in l
            num, rule = parse_rule(l)
            rules[num] = rule
        else
            push!(messages, l)
        end
    end
    return rules, messages
end

function parse_rule(l)
    println("l = ", l)
    parts = split(l, ": ")
    num = parse(Int, parts[1])
    if in('"', parts[2])
        # it's just a char
        return num, replace(parts[2], "\"" => "")
    end

    out = []
    for choice in split(parts[2], "|")
        items = split(choice)
        nums = map((x) -> parse(Int, x), items)
        push!(out, nums)
    end
    return num, out
end

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    # Parse input
    rules, messages = parse_input(lines)
    rule_regex = expand(rules, 0)
    re = Regex("^$(rule_regex)\$")
    result = 0
    for m in messages
        if occursin(re, m)
            println("match:    ", m)
            result += 1
        else
            println("no match: ", m)
        end
    end

    println("[part 1] Running file = ", fname, " ... got result = ", result)
    return result
end

# brute force
# 1. generate every possible message that could match rule 0
# 2. see if input is in that list
# TODO consider building the trees first for all "choice" states

example_rules = """
0: 4 1 5
1: 2 3 | 3 2
2: 4 4 | 5 5
3: 4 5 | 5 4
4: "a"
5: "b"
"""

expected_rules = Dict()
expected_rules[0] = [[4,1,5]]
expected_rules[1] = [[2,3], [3,2]]
expected_rules[2] = [[4,4], [5,5]]
expected_rules[3] = [[4,5], [5,4]]
expected_rules[4] = "a"
expected_rules[5] = "b"

actual_rules, _ = parse_input(split(example_rules, "\n"))
@test actual_rules == expected_rules

println("== START ==")
println(expand(actual_rules, 0))
println("== END ==")

@test run("19ex.txt") == 2
run("19.txt")
