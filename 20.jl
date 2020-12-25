using Test
using DataStructures
# graphs
using LightGraphs

# plotting the graph
# using GraphPlot

# outputting an image of drawn graph
# using Cairo
# using Compose

# write to DOT for funz
# using GraphIO

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
    top_left = (r == 1 && c == 1)
    top_right = (r == 1 && c == N)
    bot_left = (r == N && c == 1)
    bot_right = (r == N && c == N)
    return top_left || top_right || bot_left || bot_right
end

function is_edge(r, c, N)
    return in(r, [1,N]) || in(c, [1,N])
end

function find_matching_vertex(g, adjacent_vs, n_count, used)
    for v in vertices(g)
        if in(v, used)
            continue
        end

        ns = Set(collect(neighbors(g, v)))
        if length(ns) == n_count && issubset(adjacent_vs, ns)
            return v
        end
    end
    return Nothing
end

function determine_arrangement(tiles, scores, freq)
    g = SimpleGraph(length(tiles))
    N = Int(sqrt(length(tiles)))

    # @show g

    # Create mappings from vertex_id (1,2,3,....) <=> tile_id (4-digit number like 1492, 4192, etc)
    vertex_to_tile_id = Dict()
    tile_id_to_vertex = Dict()
    for (vertex_id, tile_id) in enumerate(keys(tiles))
        vertex_to_tile_id[vertex_id] = tile_id
        tile_id_to_vertex[tile_id] = vertex_id
    end

    println("G : vertices=$(nv(g)) edges = $(ne(g))")
    for s in keys(scores)
        # a score of >0 means those tile IDs are connected
        src = tile_id_to_vertex[s[1]]
        dst = tile_id_to_vertex[s[2]]
        add_edge!(g, src, dst)
    end

    # @show g
    println("G : vertices=$(nv(g)) edges = $(ne(g))")
    # savegraph("20graph.dot", g, DotFormat())
    used = Set()

    out = []
    for r in 1:N
        row = []
        for c in 1:N
            # println("r=$(r),c=$(c)")
            val = Nothing
            if r == 1 && c == 1
                # initial vertex
                startV = Nothing
                for v in vertices(g)
                    ns = neighbors(g, v)
                    if length(ns) == 2 && startV == Nothing
                        val = v
                        break
                    end
                end
            else
                adjacent_vs = Set()
                if r > 1
                # above
                    push!(adjacent_vs, out[r - 1][c])
                end
                if c > 1
                # left
                    push!(adjacent_vs, row[c - 1])
                end

                n_count = 4
                if is_corner(r, c, N)
                    n_count = 2
                elseif is_edge(r, c, N)
                    n_count = 3
                end
                val = find_matching_vertex(g, adjacent_vs, n_count, used)
                if val == Nothing
                    throw("Could not find matching vertex r=$(r) c=$(c) adjacent_vs=$(adjacent_vs) used=$(used)")
                end
            end

            push!(used, val)
            push!(row, val)
        end
        push!(out, row)
    end

    println("OUT, before conversion:")
    display(out)
    println("")

    # convert from graph IDs to tile IDs
    for r in 1:N
        for c in 1:N
            out[r][c] = vertex_to_tile_id[out[r][c]]
        end
    end

    println("OUT, after conversion:")
    display(out)
    println("")
    return out

    # if N == 3
    #     return [
    #         [1951,Nothing,3079],
    #         [Nothing,Nothing,Nothing],
    #         [2971,Nothing,1171],
    #     ]
    # else N == 12
    #     return [
    #         [2857, 1151,2689,1913,2161,1999,1901,1181,3331,2633,2713,3083],


    #     ]
    # end
end

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
    # println("Non-zero scores:")
    # @show scores
    # for s in keys(scores)
    #     println("$(s) $(scores[s])")
    # end

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


    # println("Frequency by Tile ID:")
    # @show freq
    # for k in keys(freq)
    #     println("$(k) $(freq[k])")
    # end

    # OK, so now we know which items are in the four corners, and we should be able to tile outwards from there!
    arrangement = determine_arrangement(tiles, scores, freq)

    # TODO: Cleanup and verify the arrangement
    # - flip things around until it's a perfect fit
    # - verify the fix
    # - draw it!

    # TODO: Search for Monsters
    # (1) The borders of each tile are not part of the actual image; start by removing them.
    # (2) Find patterns that look like monster.. try various orientations of image until you see >0


    # This shortcut works, since I didn't actual determine how the grid is arranged
    # corner_tiles = keys(filter((x) -> x[2] == 2, freq))
    corner_tiles = [
        arrangement[1][1],
        arrangement[1][N],
        arrangement[N][1],
        arrangement[N][N],
    ]
    println(corner_tiles)
    @assert length(corner_tiles) == 4 # must be exactly four corner tiles
    return reduce(*, corner_tiles)

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
    result = brute_force(tiles)
    println("Result = ", result)
    return result
end

@test run("20ex.txt") == (1951 * 3079 * 2971 * 1171)
run("20.txt")
