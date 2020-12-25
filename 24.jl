using Test

struct Point
    x::Float64
    y::Float64
end

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
offsets = Dict(
    e => Point(1, 0),
    ne => Point(0.5, 0.5),
    se => Point(0.5, -0.5),
    w => Point(-1, 0),
    nw => Point(-0.5, 0.5),
    sw => Point(-0.5, -0.5),
)

# determine if a series of moves are equivalent

function get_neighbors(p::Point)
    return map((o) -> Point(p.x + o.x, p.y + o.y), collect(values(offsets)))
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
        o = offsets[dmap[ds]]
        x += o.x
        y += o.y
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

    pts = map(x -> x[1], filter(x -> isodd(x[2]), collect(flipped)))
    # @show pts
    result = length(pts)
    println("[part 1] Ran $(fname) and got result = $(result)")
    return result, pts
end

function day(pts)
    min_y  = minimum((p) -> p.y, pts)
    max_y = maximum((p) -> p.y, pts)
    min_x  = minimum((p) -> p.x, pts)
    max_x = maximum((p) -> p.x, pts)

    # @show min_x, min_y, max_x, max_y
    before = pts
    after = Set()

    y = min_y - 1
    while y <= (max_y + 1)
        x = min_x - 1
        while x <= (max_x + 1)
            cur = Point(x, y)
            ns = get_neighbors(cur)
            num_black_tiles_adj = length(filter(n -> in(n, before), ns))
            if in(cur, before)
                # Any black tile with zero or more than 2 black tiles immediately
                # adjacent to it is flipped to white.
                if 1 <= num_black_tiles_adj <= 2
                    push!(after, cur)
                end
            else
                # Any white tile with exactly 2 black tiles immediately adjacent to
                # it is flipped to black.
                if num_black_tiles_adj == 2
                    push!(after, cur)
                end
            end

            x += 0.5
        end
        y += 0.5
    end

    return after
end


function run2(fname)
    _, pts = run(fname)

    black_tiles = Set()
    for p in pts
        push!(black_tiles, p)
    end

    println("Day = 0 $(length(black_tiles))")
    for d in 1:100
        black_tiles = day(black_tiles)
        println("Day = $(d) $(length(black_tiles))")
    end

    result = length(black_tiles)
    println("[part 2] Ran $(fname) and got result = $(result)")
    return result
end


@test move("esew") == Point(+0.5, -0.5)
@test move("nwwswee") == Point(0, 0)

@test run("24ex.txt")[1] == 10

run("24.txt")

# TODO: run2
# - run() gives us initial state
# - then, do conway style simulation
run2("24ex.txt")

run2("24.txt")
