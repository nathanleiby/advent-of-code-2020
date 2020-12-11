using Test;

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    # Each position is either floor (.), an empty seat (L), or an occupied seat (#).

    prev = lines
    while true
        new_lines = take_step(prev)
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
    println("[part I] Ran file ", fname, " and got result = ", result)
    return result
end

function take_step(lines)
    # If a seat is empty (L) and there are no occupied seats adjacent to it, the seat becomes occupied.
    # If a seat is occupied (#) and four or more seats adjacent to it are also occupied, the seat becomes empty.
    # Otherwise, the seat's state does not change.
    out = []
    for row in 1:length(lines)
        new_row = ""
        for col in 1:length(lines[1])
            n = get_new_state(lines, row, col)
            new_row *= n
        end
        push!(out, new_row)
    end
    return out
end

row_offsets = [-1, 0, 1]
col_offsets = [-1, 0, 1]
function get_new_state(lines, row, col)
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

ex = readlines(open("11ex.txt", "r"))
ex_1 = readlines(open("11ex.1.txt", "r"))
ex_2 = readlines(open("11ex.2.txt", "r"))
ex_5 = readlines(open("11ex.5.txt", "r"))

@test take_step(ex) == ex_1
@test take_step(take_step(ex)) == ex_2
@test take_step(take_step(take_step(take_step(take_step(ex))))) == ex_5
# .. stays stable?
@test take_step(take_step(take_step(take_step(take_step(take_step(ex)))))) == ex_5

@test run("11ex.txt") == 37
run("11.txt")
