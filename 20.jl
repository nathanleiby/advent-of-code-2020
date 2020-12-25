using Test
using DataStructures
using LightGraphs

struct Tile
    Data::Array{Array{Char}}
end

struct TileEdges
    Top::Array{Char}
    Right::Array{Char}
    Bottom::Array{Char}
    Left::Array{Char}
end

function rotate(tile::Tile)
    # rotate 90 degrees clockwise
    # t = tile.Data
    # return TileEdges(t.Left, t.Top, t.Right, t.Bottom)
    return Nothing # TODO
end

function flip_h(tile::Tile)
    out = []
    for row in tile.Data
        push!(out, reverse(row))
    end
    return out
end

function similarity(t1::TileEdges, t2::TileEdges)
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

function get_tile_edges(tile::Tile)
    t = tile.Data
    top = t[1]
    left = map((x) -> x[1], t)
    bottom = t[length(t)]
    right = map((x) -> x[length(x)], t)

    return TileEdges(top, right, bottom, left)
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

function determine_arrangement(tiles, scores)
    g = SimpleGraph(length(tiles))
    N = Int(sqrt(length(tiles)))

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

    println("G : vertices=$(nv(g)) edges = $(ne(g))")
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

    # convert from graph IDs to tile IDs
    for r in 1:N
        for c in 1:N
            out[r][c] = vertex_to_tile_id[out[r][c]]
        end
    end

    println("Tile arrangement:")
    display(out)
    println("")
    return out
end

function align_tiles(tiles, arrangement, N)
    # TODO: Cleanup and verify the arrangement
    # - JUST ROTATE, first
    # - then add flipping later
    # - flip things around until it's a perfect fit
    # - verify the fix
    # - draw it!


    out = []
    # for r in 1:N
    #     for c in 1:N
    #         if r == 1 && c == 1
    #             # special case to align the first tile
    #             next_tile = get_tile_edges(tiles[r[1][2]])
    #             # find common edge

    #             # make sure that edge is facing right
    #             for i in 1:4
    #                 for j in 1:4
    #                 end
    #             end
    #         end
    #         tile_id = arrangement[r][c]
    #         # rotate until aligned
    #         for i in 1:4
    #             for j in 1:4
    #             end
    #         end
    #         edges = get_tile_edges(tiles[tile_id])

    #     end
    # end

    return out
end

function search_for_monsters(aligned)
    # TODO: Search for Monsters
    # (1) The borders of each tile are not part of the actual image; start by removing them.
    # (2) Find patterns that look like monster.. try various orientations of image until you see >0

    return 0
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
    # build a graph from above information
    arrangement = determine_arrangement(tiles, scores)
    # we now need to rotate individual tiles so it's perfectly aligned
    aligned = align_tiles(tiles, arrangement, N)
    monster_count = search_for_monsters(aligned)

    # This shortcut works, since I didn't actual determine how the grid is arranged
    # corner_tiles = keys(filter((x) -> x[2] == 2, freq))
    corner_tiles = [
        arrangement[1][1],
        arrangement[1][N],
        arrangement[N][1],
        arrangement[N][N],
    ]
    return reduce(*, corner_tiles), monster_count

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
            tiles[current_tile] = Tile([])
        elseif l == ""
            # skip
        else
            push!(tiles[current_tile].Data, collect(l))
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

@test run("20ex.txt")[1] == (1951 * 3079 * 2971 * 1171)
@test run("20.txt")[1] == 60145080587029
