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

function compute_rule_positions(tickets, rule_lookup)
    # to begin, each position could be any of the rules
    possibles = []
    for i in 1:length(tickets[1])
        p = Set()
        for k in keys(rule_lookup)
            push!(p, k)
        end
        push!(possibles, p)
    end

    for t in tickets
        for (idx, val) in enumerate(t)
            # check if it fails to satisfy any of the remaining possible rules
            to_delete = []
            for rule_name in possibles[idx]
                rules = rule_lookup[rule_name]
                invalid_count = 0
                for r in rules
                    if !(r.Low <= val && val <= r.High)
                        invalid_count += 1
                    end
                end
                if invalid_count == 2
                    push!(to_delete, rule_name)
                end
            end
            for rule_name in to_delete
                delete!(possibles[idx], rule_name)
            end
        end
    end

    println("Possibles", possibles)

    # Simplify based on things which have only one option
    progress = true
    done = Set()
    while progress
        progress = false

        for (idx, p) in enumerate(possibles)
            if length(p)  == 1 && ! in(idx, done)
                # record the value in this set
                val = Nothing
                for v in p
                    val = v
                end

                # remove this item from other sets
                for i in 1:length(possibles)
                    if i != idx
                        delete!(possibles[i], val)
                    end
                end

                progress = true
                push!(done, idx)
                break
            end
        end
    end

    out = []
    for p in possibles
        val = Nothing
        for v in p
            push!(out, v)
            # assume just one, else we messed up
            break
        end
    end

    return out
end

function run2(fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    section = "rules"
    rule_lookup = Dict()
    valid_tickets = []
    your_ticket = Nothing # not defined yet
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
        elseif section == "your_ticket"
            nums = map((x) -> parse(Int, x), split(l, ","))
            your_ticket = nums
        elseif section == "nearby_tickets"
            nums = map((x) -> parse(Int, x), split(l, ","))
            valid = true
            for n in nums
                if ! valid_for_some_rule(n, rule_lookup)
                    valid = false
                    break
                end
            end
            if valid
                push!(valid_tickets, nums)
            end
        end
    end

    println("Rules:", rule_lookup)
    println("Your ticket:", your_ticket)
    println("Valid tickets:", valid_tickets)

    rule_list = compute_rule_positions(valid_tickets, rule_lookup)
    println("rule_list = ", rule_list)

    result = 1
    for (idx, r) in enumerate(rule_list)
        if startswith(r, "departure")
            val = your_ticket[idx]
            println(r, " ", val)
            result *=  val
        end
    end

    println("[Part 2] File = ", fname, " ... result = ", result)
    return result
end

# @test run("16ex.txt") == 71
# run("16.txt")

run2("16ex.part2.txt")

run2("16.txt")
