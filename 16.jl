using Test;

struct Rule
    Low::Int
    High::Int
end

function parse_rule(r)
    s = split(r, "-")
    low = parse(Int, s[1])
    high = parse(Int, s[2])

    return Rule(low, high)
end

function valid_for_some_rule(num, rule_lookup)
    for k in keys(rule_lookup)
        for r in rule_lookup[k]
            if r.Low <= num && num <= r.High
                return true
            end
        end
    end

    return false
end

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    section = "rules"
    rule_lookup = Dict()
    total = 0
    for l in lines
        # check if we changed section in the doc..
        if l == ""
            continue
        elseif l == "your ticket:"
            section = ""
            section = "your_ticket"
            continue
        elseif l == "nearby tickets:"
            section = "nearby_tickets"
            continue
        end

        # in a section currently.. handle the line
        if section == "rules"
            parts = split(l, ": ")
            rule_name = parts[1]
            ranges = split(parts[2], " or ")
            rules = map(parse_rule, ranges)
            rule_lookup[rule_name] = rules
        elseif section == "nearby_tickets"
            nums = map((x) -> parse(Int, x), split(l, ","))
            for n in nums
                if ! valid_for_some_rule(n, rule_lookup)
                    println("NOT VALID: ", n)
                    total += n
                end
            end
        end
    end

    # println("Rules:", rule_lookup)
    println("[Part 1] File = ", fname, " ... result = ", total)
    return total
end

@test run("16ex.txt") == 71
run("16.txt")
