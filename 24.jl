using Test

# valid directions
@enum Directions e se sw w nw ne
directions = ["e", "se", "sw", "w", "nw", "ne"]
dmap = Dict(
    "e" => e,
    "ne" => ne,
    "nw" => nw,
    "se" => se,
    "sw" => sw,
    "w" => w,
)

# determine if a series of moves are equivalent

struct Point
    X::Float64
    Y::Float64
end

function move(path::String)
    x = 0
    y = 0
    ds = Nothing
    i = 1
    while i <= length(path)
        # get next direction
        if (length(path) >= i + 1) && in(path[i:i + 1], directions)
            ds = path[i:i + 1]
            i += 2
        else
            ds = string(path[i])
            i += 1
        end

        # move
        d = dmap[ds]
        if d == e
            x += 1
        elseif d == w
            x -= 1
        elseif d == nw
            x -= 0.5
            y += 0.5
        elseif d == ne
            x += 0.5
            y += 0.5
        elseif d == sw
            x -= 0.5
            y -= 0.5
        elseif d == se
            x += 0.5
            y -= 0.5
        else
            throw("Failed to parse direction")
        end
    end

    return Point(x, y)
end

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    flipped = Dict()
    for l in lines
        p = move(l)
        if ! haskey(flipped, p)
            flipped[p] = 0
        end
        flipped[p] += 1
    end

    # @show flipped

    result = length(filter(x -> isodd(x[2]), collect(flipped)))

    println("Ran $(fname) and got result = $(result)")
    return result
end

@test move("esew") == Point(+0.5, -0.5)
@test move("nwwswee") == Point(0, 0)

@test run("24ex.txt") == 10

run("24.txt")
