function computeGroup(rows::Array{String})
    # println("Rows:\n", rows)
    seen = Set{Char}()
    for r in rows
        for c in r
            push!(seen, c)
        end
    end
    return length(seen)
end

# example
exampleGroup = [
"abcx"
"abcy"
"abcz"
]
@assert computeGroup(exampleGroup) == 6

function parseLines(lines)::Array{Array{String}}
    groups = []
    g = []
    for l in lines
        if l == ""
            # reset
            push!(groups, g)
            g = []
        else
            push!(g, l)
        end
    end

    # add last group
    push!(groups, g)

    return groups
end

function run(fname)
    # read file
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    groups = parseLines(lines)
    counts = map(computeGroup, groups)
    result = sum(counts)
    println("Ran ", fname, " got ", result)
    return result
end

@assert run("6ex.txt") == 11
run("6.txt")
