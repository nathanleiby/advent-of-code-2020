using Test;

function format_re(s)
    out = ""
    indent = ""
    for c in s
        out *= c
        if c == '('
            indent *= "  "
            out *= ("\n" * indent)
        elseif c == ')'
            indent = indent[1:length(indent) - 2]
            out *= ("\n" * indent)
        end
    end
    return out
end

function expand(rules, num, version=1)::String
    # base case
    if typeof(rules[num]) == String
        # println(offset, rules[num])
        return rules[num]
    else
    # recursive case
        options = []
        if version == 2
            rules[11] = [[42],[31]]
        end
        for choice in rules[num] # things separated by '|'
            val = ""
            for r in choice # numbers in the rule
                val *= expand(rules, r, version)
            end
            push!(options, val)
        end
        out = join(options, "|")
        if version == 2
            if num == 8
                return "($out)+"
            elseif num == 11
                a = options[1]
                b = options[2]
                # ab,aabb,aaabbb,aaaabbbb,...
                # 4 seems to be enough to get all answers
                return "((($a)($b))|(($a){2}($b){2})|(($a){3}($b){3})|(($a){4}($b){4}))"
            else
                return "($out)"
            end
        end
        return "($out)"
    end
end

function parse_input(lines, version=2)
    messages = []
    rules = Dict()
    for l in lines
        if l == ""
            continue
        elseif ':' in l
            if version == 2
                # part 2: add repeats
                # if startswith(l, "8: ")
                #     # same number repeated over and over
                #     l = "8: 42 | 42 42 | 42 42 42 | 42 42 42 42 | 42 42 42 42 42 "
                # if startswith(l, "11: ")
                # #     # (a^x)(b^x) where x is the same number... is hard to represent in regex, so just keep extending until I find all the hits
                #     l = "11: 42 31 | 42 42 31 31 | 42 42 42 31 31 31"
                #     # l = "11: 42 31 | 42 42 31 31 | 42 42 42 31 31 31 | 42 42 42 42 31 31 31 31"
                # #     # l = "11: 42 31 | 42 42 31 31 | 42 42 42 31 31 31 | 42 42 42 42 31 31 31 31| 42 42 42 42 42 31 31 31 31 31"
                # end
            end
            num, rule = parse_rule(l)
            rules[num] = rule
        else
            push!(messages, l)
        end
    end
    return rules, messages
end

function parse_rule(l)
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

function run(fname, version=1)
    println("[part ", version, "][START] Running file = ", fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    # Parse input
    rules, messages = parse_input(lines, version)
    rule_regex = expand(rules, 0, version)
    println("Rule:")
    println("")
    println(rule_regex)
    # println(format_re(rule_regex))
    println("")
    re = Regex("^$(rule_regex)\$")
    result = 0
    for m in messages
        if occursin(re, m)
            # println("match:    ", m)
            result += 1
        else
            # println("no match: ", m)
        end
    end

    println("[part ", version, "][END] Running file = ", fname, " ... got result = ", result)
    return result
end

# example_rules = """
# 0: 4 1 5
# 1: 2 3 | 3 2
# 2: 4 4 | 5 5
# 3: 4 5 | 5 4
# 4: "a"
# 5: "b"
# """

# expected_rules = Dict()
# expected_rules[0] = [[4,1,5]]
# expected_rules[1] = [[2,3], [3,2]]
# expected_rules[2] = [[4,4], [5,5]]
# expected_rules[3] = [[4,5], [5,4]]
# expected_rules[4] = "a"
# expected_rules[5] = "b"

# actual_rules, _ = parse_input(split(example_rules, "\n"))
# @test actual_rules == expected_rules

# println("== START ==")
# println(expand(actual_rules, 0))
# println("== END ==")

# @test run("19ex.txt") == 2

# run("19.txt")

# @test run("19ex.part2.txt") == 3
# @test run("19ex.part2.txt", 2) == 12

run("19.txt", 2)

