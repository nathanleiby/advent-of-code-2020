function compute(rows, mx, my)
    # initialize position
    x = 1
    y = 1

    width = length(rows[1])
    height = length(rows)

    trees_encountered = 0
    while y <= height
        # is tree?
        temp_x = (x == 0) ? width : x # 1 indexed arrays :(
        if rows[y][temp_x] == '#'
            trees_encountered += 1
        end

        # move
        x = (x + mx) % width
        y = y + my
    end

    return trees_encountered
end

function run(fname)
    println("Running", fname, " ...")
    f = open(fname, "r")
    rows = readlines(f)
    close(f)
    result = compute(rows, 1, 1)
    result2 = compute(rows, 3, 1)
    result3 = compute(rows, 5, 1)
    result4 = compute(rows, 7, 1)
    result5 = compute(rows, 1, 2)

    out = result * result2 * result3 * result4 * result5

    println("Final result for ", fname, " was: ", out)
    return out
end

@assert run("3ex.txt") == 336

run("3.txt")
