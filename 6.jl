# Learnings:
# - the ! operator
    # - push with ! operator means it will overwrite list with the new value
    # - push without ! operator means it will return the new value, but not modify list

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

function computeGroupV2(rows::Array{String})
    # println("Rows:\n", rows)
    sets = []
    for r in rows
        s = Set{Char}()
        for c in r
            push!(s, c)
        end
        push!(sets, s)
    end
    common = intersect(sets...)
    return length(common)
end


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

function run(fname, version)
    # read file
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    groups = parseLines(lines)
    f = version == 1 ? computeGroup : computeGroupV2
    counts = map(f, groups)
    result = sum(counts)
    println("Ran ", fname, " got ", result)
    return result
end

@assert run("6ex.txt", 1) == 11
run("6.txt", 1)

@assert run("6ex.txt", 2) == 6
run("6.txt", 2)
