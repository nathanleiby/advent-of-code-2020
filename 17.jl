using Test;

active = '#'
inactive = '.'

struct Point
    x::Int
    y::Int
    z::Int
end

function get_neighbors(p::Point)
    neighbors = []
    for x_offset in [1,0,-1]
        for y_offset in [1,0,-1]
            for z_offset in [1,0,-1]
                if x_offset == 0 && y_offset == 0 && z_offset == 0
                    # skip returning the same point
                    continue
                end
                push!(neighbors, Point(p.x + x_offset, p.y + y_offset, p.z + z_offset))
            end
        end
    end
    return neighbors
end

function is_active(values, pt)
    return in(pt, keys(values)) && values[pt] == active
end

function copy(p::Point)
    return Point(p.x, p.y, p.z)
end

function do_iter(values, low::Point, high::Point)
    new_values = Dict()
    # new_low = copy(low)
    # new_high = copy(high)

    # We need not just the current points, but also all things adjacent to them
    all_points = Set()
    for p in keys(values)
        for n in get_neighbors(p)
            push!(all_points, n)
        end
    end

    for p in all_points
        active_neighbor_count = sum(map((x) -> is_active(values, x), get_neighbors(p)))
        # If a cube is active
        if is_active(values, p)
            # and exactly 2 or 3 of its neighbors are also active, the cube remains active.
            if in(active_neighbor_count, [2,3])
                new_values[p] = active
            # Otherwise, the cube becomes inactive.
            else
                new_values[p] = inactive
            end
        # If a cube is inactive
        else
            # but exactly 3 of its neighbors are active, the cube becomes active.
            if active_neighbor_count == 3
                new_values[p] = active
            # Otherwise, the cube remains inactive.
            else
                new_values[p] = inactive
            end
        end

        # TODO: Try to have better boundaries
        # if new_values[p] == active
        #     # update boundary values
        #     new_low.x = min(p.x, new_low.x)
        #     new_low.y = min(p.y, new_low.y)
        #     new_low.z = min(p.z, new_low.z)
        #     new_high.x = max(p.x, new_high.x)
        #     new_high.y = max(p.y, new_high.y)
        #     new_high.z = max(p.z, new_high.z)
        # end
    end

    new_low = Point(low.x - 1, low.y - 1, low.z - 1)
    new_high = Point(high.x + 1, high.y + 1, high.z + 1)
    return new_values, new_low, new_high
end

DEBUG = false
function print_values(values, low, high)
    if ! DEBUG
        return
    end

    for z in low.z:high.z
        println("z=", z)
        for y in low.y:high.y
            for x in low.x:high.x
                print(values[Point(x, y, z)])
            end
            println("")
        end
        println("")
    end
end

function count_active(values)
    result = 0
    for k in keys(values)
        v = values[k]
        if v == active
            result += 1
        end
    end
    return result
end

function run(fname, cycles=6)
    # parse input
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    # initialize
    values = Dict{Point,Char}()
    for y in 1:length(lines)
        for (x, val) in enumerate(lines[y])
            values[Point(x, y, 0)] = val
        end
    end

    low_point = Point(1, 1, 0)
    high_point = Point(3, 3, 0)

    # print base state
    println("After ", 0, " cycle...")
    print_values(values, low_point, high_point)

    # do cycles...
    for c in 1:cycles
        # println(length(values), low_point, high_point)
        values, low_point, high_point = do_iter(values, low_point, high_point)
        println("After ", c, " cycle...")
        print_values(values, low_point, high_point)
        println("")
    end

    # Count number of active (`#`)
    result = count_active(values)
    return result
end

@test run("17ex.txt", 0) == 5
@test run("17ex.txt", 1) == 11
@test run("17ex.txt", 2) == 21

@test run("17ex.txt") == 112

print(run("17.txt"))
