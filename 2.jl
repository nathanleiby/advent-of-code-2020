struct Line
    password::String
    min::Int
    max::Int
    letter::Char
end

function parse_line(l)
    r = split(l, ':')
    rule = r[1]
    password = r[2]

    # Eep! Arrays are 1-indexed
    rule_parts = split(rule, " ")

    range = rule_parts[1]
    range_parts = split(range, "-")
    min = range_parts[1]
    max = range_parts[2]

    letter = rule_parts[2]

    return Line(strip(password), parse(Int64, min), parse(Int64, max), letter[1])
end

function is_valid(item)
    println(item)
    count = 0
    for c in item.password
        if c == item.letter
            count += 1
        end
    end
    return count >= item.min && count <= item.max
end

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    valid = map((x) -> is_valid(parse_line(x)), lines)
    println(valid)
    result = count(x -> x == true, valid)
    close(f)
    println("Ran ", fname, " got ", result)
    return result
end

@assert run("2example.txt") == 2

run("2.txt")
