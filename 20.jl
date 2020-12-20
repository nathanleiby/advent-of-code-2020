using Test
using DataStructures

# function get_tile_variations(t)
#     # gets all possible rotations/variations of a tile
#     edges = get_tile_edges(t)
#     return [
#         edges,
#     ]
# end

struct Tile
    Top::String
    Right::String
    Bottom::String
    Left::String
end

function similarity(t1::Tile, t2::Tile)
    t1_edges = [t1.Top, t1.Right, t1.Bottom, t1.Left]
    t2_edges = [t2.Top, t2.Right, t2.Bottom, t2.Left]
    score = 0
    for t1e in t1_edges
        if in(t1e, t2_edges) || in(reverse(t1e), t2_edges)
            score += 1
        end
    end
    return score
end

function get_tile_edges(t)
    top = t[1]
    left = join(map((x) -> x[1], t))
    bottom = t[length(t)]
    right = join(map((x) -> x[length(x)], t))

    return Tile(top, right, bottom, left)
end

function compute_similarities(tile_edges)
    scores = Dict()
    for current in keys(tile_edges)
        for other in keys(tile_edges)

            if current == other
                continue
            end
            scores[(current, other)] = similarity(tile_edges[current], tile_edges[other])
        end
    end

    # just the non-zero ones
    filter!((x) -> last(x) > 0, scores)
    return scores
end

function is_corner(r, c, N)
    return
    # top left
    (r == 1 && c == 1) ||
    # top right
    (r == 1 && c == N) ||
    # bottom left
    (r == N && c == 1) ||
    # bottom right
    (r == N && c == N)
end

function is_edge(r, c, N)
    return in(r, [1,N]) || in(c, [1,N])
end

# TODO: Lel, I don't need to build these b/c the answer just requires the corners
# function determine_arrangement(scores, freq)
#     tile_ids = Set(keys(tile_ids))
#     N = Int(sqrt(length(tile_ids)))
#     done = false

#     # todo: shortcut to get items with that many adjacencies
#     twos = filter((x) -> x[2] == 2, collect(freq))
#     threes =
#     fours =

#     # initialize output image
#     output = []
#     for r in 1:N
#         push!(output, []) # add row
#         for c in 1:N
#             # how many tiles should it touch?
#             expected_adjacent_tiles = 4 # middle
#             if is_corner(r, c, N)
#                 expected_adjacent_tiles = 2
#             elseif is_edge(r, c, N)
#                 expected_adjacent_tiles = 3
#             end

#             filter((x) -> x[2] == expected_adjacent_tiles, collect(freq))
#             push!(output[r], 0) # add column value
#         end


#         return [
#         [1951,Nothing,3079],
#         [Nothing,Nothing,Nothing],
#         [2971,Nothing,1171],
#     ]
#     end
# end

function brute_force(tiles)
    num_tiles = length(tiles)
    N = Int(sqrt(num_tiles))
    println("Found $(length(tiles)) tiles, for square size of $(N)")

    # we only care about edges
    tile_edges = Dict()
    for k in keys(tiles)
        tile_edges[k] = get_tile_edges(tiles[k])
    end

    # find anything that shares >0 edges
    scores = compute_similarities(tile_edges)
    println("Non-zero scores:")
    for s in keys(scores)
        println("$(s) $(scores[s])")
    end

    # frequency by tile ID
    freq = Dict()
    for s in keys(scores)
        if !in(s[1], keys(freq))
            freq[s[1]] = 0
        end
        if !in(s[2], keys(freq))
            freq[s[2]] = 0
        end
        freq[s[1]] += 1
        freq[s[2]] += 1
    end
    # half them since we double counted tile IDs above
    for k in keys(freq)
        freq[k] = Int(freq[k] / 2)
    end


    println("Frequency by Tile IDj:")
    for k in keys(freq)
        println("$(k) $(freq[k])")
    end


    # This shortcut works, since I didn't actual determine how the grid is arranged
    corner_tiles = keys(filter((x) -> x[2] == 2, freq))
    println(corner_tiles)
    @assert length(corner_tiles) == 4 # must be exactly four corner tiles
    return reduce(*, corner_tiles)

    # OK, so now we know which items are in the four corners, and we should be able to tile outwards from there!
    # arrangement = determine_arrangement(scores)
    # top_left = arrangement[1][1]
    # top_right = arrangement[1][N]
    # bottom_left = arrangement[N][1]
    # bottom_right = arrangement[N][N]

    # println("$(top_left) $(top_right) $(bottom_left) $(bottom_right)")

    # return top_left * top_right * bottom_left * bottom_right
end

function run(fname)
    ################
    # Read input
    ################
    f = open(fname, "r")
    lines = readlines(f)
    tiles = Dict()
    current_tile = Nothing
    for l in lines
        if startswith(l, "Tile")
            tile_number = parse(Int, l[6:length(l) - 1])
            current_tile = tile_number
            tiles[current_tile] = []
        elseif l == ""
            # skip
        else
            push!(tiles[current_tile], l)
        end
    end

    ################################
    # Compute arrangement
    # By rotating, flipping, and rearranging them, you can find a square arrangement that causes all adjacent borders to line up
    ################################
    # TODO: return product of corner tile IDs
    result = brute_force(tiles)
    println("Result = ", result)
    return result
end

@test run("20ex.txt") == (1951 * 3079 * 2971 * 1171)
run("20.txt")
