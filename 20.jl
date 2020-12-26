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

function rotate(tile::Tile)::Tile
    t = tile.Data
    T = length(t)
    out = []
    for i in 1:T
        row = []
        for _ in 1:T
            push!(row, '-')
        end
        push!(out, row)
    end
    for i in 1:T
        for j in 1:T
            out[i][j] = t[T - (j - 1)][i];
        end
    end

    return Tile(out)
end

function flip_v(tile::Tile)::Tile
    return Tile(reverse(tile.Data))
end

function flip_h(tile::Tile)::Tile
    out = []
    for row in tile.Data
        push!(out, reverse(row))
    end
    return Tile(out)
end

function variations(tile::Tile)::Array{Tile}
    # TODO: Could return an iterator instead and do these one at a time?
    out = []

    push!(out, tile)
    push!(out, rotate(tile))
    push!(out, rotate(rotate(tile)))
    push!(out, rotate(rotate(rotate(tile))))

    vtile = flip_v(tile)
    push!(out, vtile)
    push!(out, rotate(vtile))
    push!(out, rotate(rotate(vtile)))
    push!(out, rotate(rotate(rotate(vtile))))

    htile = flip_h(tile)
    push!(out, htile)
    push!(out, rotate(htile))
    push!(out, rotate(rotate(htile)))
    push!(out, rotate(rotate(rotate(htile))))

    vhtile = flip_h(tile)
    push!(out, vhtile)
    push!(out, rotate(vhtile))
    push!(out, rotate(rotate(vhtile)))
    push!(out, rotate(rotate(rotate(vhtile))))

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

import Base.collect
function collect(te::TileEdges)
    return [te.Top, te.Right, te.Bottom, te.Left]
end

function find_common_edge(t1::Tile, t2::Tile)
    t1_edges = collect(get_tile_edges(t1))
    t2_edges = collect(get_tile_edges(t2))

    # TODO: Could determine here if reverse is needed
    for t1e in t1_edges
        if in(t1e, t2_edges) || in(reverse(t1e), t2_edges)
            return t1e
        end
    end

    throw("No common edge")
end

function get_tile_edges(tile::Tile)
    t = tile.Data
    top = t[1]
    left = map((x) -> x[1], t)
    bottom = t[length(t)]
    right = map((x) -> x[length(x)], t)

    return TileEdges(top, right, bottom, left)
end

function get_edge(te::TileEdges, k)
    if k == "Top"
        return te.Top
    elseif k == "Bottom"
        return te.Bottom
    elseif k == "Right"
        return te.Right
    elseif k == "Left"
        return te.Left
    end
    throw("invalid input $(k)")
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

# TODO: What's the right way to custom stringify something in Julia?
function print_tile(t::Tile)
    out = ""
    for row in t.Data
        out *= join(row)
        out *= "\n"
    end
    println(out)
end

# function align_tiles(tiles, arrangement, N)::Array{Array{Tile}}
function align_tiles(tiles, arrangement, N)
    N = length(arrangement)
    out = []
    for r in 1:N
        row = []
        for c in 1:N
            # make sure that edge is facing right
            cur = tiles[arrangement[r][c]]

            shared_e = Dict()
            if c + 1 <= N
                shared_e["Right"] = find_common_edge(cur, tiles[arrangement[r][c + 1]])
            end
            if c - 1 >= 1
                shared_e["Left"] = find_common_edge(cur, tiles[arrangement[r][c - 1]])
            end
            if r + 1 <= N
                shared_e["Bottom"] = find_common_edge(cur, tiles[arrangement[r + 1][c]])
            end
            if r - 1 >= 1
                shared_e["Top"] = find_common_edge(cur, tiles[arrangement[r - 1][c]])
            end

            # @show e_right
            # @show e_bottom

            # println("CURRENT:")
            # print_tile(cur)
            # println("\n")
            # println("BOTTOM:")
            # print_tile(bottom)
            # println("\n")

            for v in variations(cur)
                te = get_tile_edges(v)
                aligned = true
                for k in ["Top", "Bottom", "Right", "Left"]
                    # TODO: Might also be equal to reverse of shared_e[k]
                    if haskey(shared_e, k) && !(get_edge(te, k) == shared_e[k] || reverse(get_edge(te, k)) == shared_e[k])
                        aligned = false
                        break
                    end
                end

                if aligned
                    println("r=$r c=$c .. found a working alignment!")
                    # TODO: If we didn't find something for every position, fail
                    push!(row, v)
                    break
                end
            end
        end
        push!(out, row)
    end

    return out
end

function print_grid(grid)
    ex_tile = grid[1][1]
    for row in grid
        for y in 1:length(ex_tile.Data) # for each tile idx
            line = join(map((x) -> join(x.Data[y]), row), " ")
            println(line)
        end
        println("")
    end

end
function search_for_monsters(aligned)
    # TODO: Search for Monsters
    # (1) The borders of each tile are not part of the actual image; start by removing them.
    # (2) Find patterns that look like monster.. try various orientations of image until you see >0

    # trip the borders of each tile
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
    print_grid(aligned)

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


@test rotate(Tile([
    collect("abc"),
    collect("def"),
    collect("ghi"),
])).Data == Tile([
    collect("gda"),
    collect("heb"),
    collect("ifc"),
]).Data

@test flip_h(Tile([
    collect("abc"),
    collect("def"),
    collect("ghi"),
])).Data == Tile([
    collect("cba"),
    collect("fed"),
    collect("ihg"),
]).Data

@test flip_v(Tile([
    collect("abc"),
    collect("def"),
    collect("ghi"),
])).Data == Tile([
    collect("ghi"),
    collect("def"),
    collect("abc"),
]).Data

@test run("20ex.txt")[1] == (1951 * 3079 * 2971 * 1171)
@test run("20.txt")[1] == 60145080587029
