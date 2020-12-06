function compute(rows)
    # initialize position
    x = 1
    y = 1
    # slope
    mx = 3
    my = 1

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
    f = open(fname, "r")
    result = compute(readlines(f))
    close(f)
    println("Ran ", fname, " got ", result)
    return result
end

@assert run("3example.txt") == 7

run("3.txt")
