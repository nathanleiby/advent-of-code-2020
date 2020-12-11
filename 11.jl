# LEARNING:
# - Julia has "." operators  that perform an operation elementwise on everything in an array
#   https://docs.julialang.org/en/v1/manual/mathematical-operations/#man-dot-operators
#   .. leads to concise syntax like: https://github.com/leesharma/game-of-life-julia/blob/main/rules/standard.jl#L5

using Test;

function run(fname, version=1)
    f = open(fname, "r")
    lines = readlines(f)
    # Each position is either floor (.), an empty seat (L), or an occupied seat (#).

    prev = lines
    while true
        new_lines = take_step(prev, version)
        if prev == new_lines
            break
        end
        prev = new_lines
    end

    occupied_chairs = 0
    for row in prev
        for c in row
            if c == '#'
                occupied_chairs += 1
            end
        end
    end

    result = occupied_chairs
    println("[part ", version, "] Ran file ", fname, " and got result = ", result)
    return result
end

function take_step(lines, version=1)::Array{String}
    # If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
    # If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
    # Otherwise, the seat's state does not change.
    f = get_new_state
    if version == 2
        f = get_new_state_v2
    end

    out = []
    for row in 1:length(lines)
        new_row = ""
        for col in 1:length(lines[1])
            n = f(lines, row, col)
            new_row *= n
        end
        push!(out, new_row)
    end
    return out
end

row_offsets = [-1, 0, 1]
col_offsets = [-1, 0, 1]
function get_new_state(lines, row, col)::Char
    if lines[row][col] == '.'
        return '.'
    end

    # count occupied neighbors
    occupied = 0
    total_rows = length(lines)
    total_cols = length(lines[1])
    for r in row_offsets
        for c in col_offsets
            # if in bounds
            if !(r == 0 && c == 0) &&
                (row + r >= 1 && row + r <= total_rows) &&
                (col + c >= 1 && col + c <= total_cols)
                if lines[row + r][col + c] == '#'
                    occupied += 1
                end
            end
        end
    end

    seat = lines[row][col]
    if seat == 'L' && occupied == 0
        return '#'
    elseif occupied >= 4
        return 'L'
    else
        return lines[row][col]
    end
end

function get_new_state_v2(lines, row, col)::Char
    if lines[row][col] == '.'
        return '.'
    end

    # count occupied neighbors
    occupied = 0
    total_rows = length(lines)
    total_cols = length(lines[1])
    for r in row_offsets
        for c in col_offsets
            if (r == 0 && c == 0)
                # don't include current seat
                continue
            end

            # while in bounds..
            step_size = 1
            new_r = row + (step_size * r)
            new_c = col + (step_size * c)
            while (new_r >= 1 && new_r <= total_rows) &&
                    (new_c >= 1 && new_c <= total_cols)
                val = lines[new_r][new_c]
                if val == '.'
                    step_size += 1
                    new_r = row + (step_size * r)
                    new_c = col + (step_size * c)
                elseif val == '#'
                    occupied += 1
                    break
                else
                    # val is 'L'
                    break
                end
            end
        end
    end

    seat = lines[row][col]
    if seat == 'L' && occupied == 0
        return '#'
    elseif occupied >= 5
        return 'L'
    else
        return seat
    end
end

ex = readlines(open("11ex.txt", "r"))
ex_1 = readlines(open("11ex.1.txt", "r"))
ex_2 = readlines(open("11ex.2.txt", "r"))
ex_5 = readlines(open("11ex.5.txt", "r"))

@test take_step(ex) == ex_1
# LEARNING: Julia has function composition operator (\circ)
# - https://docs.julialang.org/en/v1/manual/functions/#Function-composition-and-piping
# - https://github.com/leesharma/game-of-life-julia/blob/main/manifolds/grid_torus.jl#L18-L21
take_2_steps = take_step ∘ take_step
@test take_2_steps(ex) == ex_2
@test take_step(take_step(take_step(take_step(take_step(ex))))) == ex_5
# .. stays stable?
@test take_step(take_step(take_step(take_step(take_step(take_step(ex)))))) == ex_5

@test run("11ex.txt") == 37
run("11.txt")

println("VERSION 2")

ex_2_ver2 = readlines(open("11ex.2b.txt", "r"))
@test take_step(ex, 2) == ex_1
@test take_step(take_step(ex, 2), 2) == ex_2_ver2

@test run("11ex.txt", 2) == 26
run("11.txt", 2)
