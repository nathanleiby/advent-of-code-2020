# LEARNINGS:
# - fields of a struct are compared via object equality (===)
ex = [
"light red bags contain 1 bright white bag, 2 muted yellow bags.",
"dark orange bags contain 3 bright white bags, 4 muted yellow bags.",
"bright white bags contain 1 shiny gold bag.",
"muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.",
"shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.",
"dark olive bags contain 3 faded blue bags, 4 dotted black bags.",
"vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.",
"faded blue bags contain no other bags.",
"dotted black bags contain no other bags.",
]

struct BagType
    Kind::String
    Contents::Dict
end

function parse_contents(s::String)
    if s[length(s)] == '.'
        s = chop(s)
    end

    out = Dict()
    if s == "no other bags"
        return out
    end

    parts = split(s, ",")
    for p in parts
        # p is something like "5 faded blue bags"
        words = split(p)
        cNum = parse(Int, words[1])
        cKind = words[2] * " " * words[3]
        out[cKind] = cNum
    end

    return out
end

function parse_rule(s::String)
    parts = split(s, " bags contain ")
    kind = parts[1]
    contents = parse_contents(String(parts[2]))

    out = BagType(kind, contents)
    return out
end

@assert parse_contents("5 faded blue bags, 6 dotted black bags.") == Dict(
    "faded blue" => 5,
    "dotted black" => 6,
)

@assert parse_contents("no other bags.") == Dict()

# parse rule
out = parse_rule("light red bags contain 1 bright white bag, 2 muted yellow bags.")
@assert out.Kind == "light red"
@assert out.Contents == Dict(
    "bright white" => 1,
    "muted yellow" => 2,
)

out = parse_rule("maroon tsunami bags contain no other bags.")
@assert out.Kind == "maroon tsunami"
@assert out.Contents == Dict()


function run(fname)
    # read file
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    bagTypes = map(parse_rule, lines)
    toSearch = []
    push!(toSearch, "shiny gold")
    searched = []
    result = 0
    while length(toSearch) > 0
        item = pop!(toSearch)
        push!(searched, item)

        # If it's in this bagType AND we haven't searched it yet
        for bag in bagTypes
            if haskey(bag.Contents, item)
                # check if parent bag's kind has been searched yet
                if ! in(bag.Kind, searched) && ! in(bag.Kind, toSearch)
                    push!(toSearch, bag.Kind)
                    result += 1
                end
            end
        end
    end

    println("Ran ", fname, " got ", result)
    return result
end

function count_bags_inside(bagMap, bag)
    contents = bagMap[bag].Contents
    if length(contents) == 0
        return 0
    else
        total = 0
        for k in keys(contents)
            val = contents[k]
            # add number of bags at this layer
            total += val
            r = count_bags_inside(bagMap, k)
            # add number of bags inside each of the bags at this layer
            total += (val * r)
        end
        return total
    end
end

function run2(fname)
    # read file
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    bagTypes = map(parse_rule, lines)
    bagMap = Dict()
    for b in bagTypes
        bagMap[b.Kind] = b
    end

    result = count_bags_inside(bagMap, "shiny gold")

    println("[part 2] Ran ", fname, " got ", result)
    return result
end

@assert run("7ex.txt") == 4
run("7.txt")

@assert run2("7ex2.txt") == 126
run2("7.txt")
