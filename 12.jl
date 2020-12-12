using Test;

direction_to_xy = Dict(
    0 => [0, 1], # north
    90 => [1, 0], # east
    180 => [0, -1], # south
    270 => [-1, 0], # west
)

function turn(start_direction, degrees)
    return mod(start_direction + degrees, 360)
end

function move(start_pos, direction, distance)
    m = direction_to_xy[direction] .* distance
    return start_pos + m
end

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)

    pos = [0, 0]
    direction = 90 # East
    println(pos)
    for l in lines
        command = l[1]
        number = parse(Int, l[2:length(l)])
        println("cmd=", command, " num=", number)

        # Action N means to move north by the given value.
        mov_dir = direction
        if command == 'N'
            pos = move(pos, 0, number)
        elseif command == 'S'
            pos = move(pos, 180, number)
        elseif command == 'E'
            pos = move(pos, 90, number)
        elseif command == 'W'
            pos = move(pos, 270, number)
        elseif command == 'L'
            direction = turn(direction, -1 * number)
        elseif command == 'R'
            direction = turn(direction, number)
        elseif command == 'F'
            pos = move(pos, direction, number)
        end

        println("pos: ", pos, " facing: ", direction_to_xy[direction])
    end

    result = abs(pos[1]) + abs(pos[2])
    println("[part 1] File = ", fname, " ... Result = ", result)

    return result
end

function reflect(start_pos, degrees)
    deg = mod(degrees, 360)

    if deg == 0
        return start_pos
    elseif deg == 90
        # [1,2] .. R90  (L270) .. [2,-1]  # swap and -1 the second element
        return [start_pos[2], -1 * start_pos[1]]
    elseif deg == 180
        # [1,2] .. R180 (L180) .. [-1,-2] # -1 both elements
        return start_pos .* -1
    elseif deg == 270
        # [1,2] .. R270 (L90)  .. [-2,1]  # swap and -1 the first element
        return [-1 * start_pos[2], start_pos[1]]
    else
        throw("invalid input: degrees = " * degrees)
    end
end


function run2(fname)
    f = open(fname, "r")
    lines = readlines(f)

    pos = [10, 1] # waypoint pos
    ship_pos = [0, 0] # ship position
    println(pos)
    for l in lines
        command = l[1]
        number = parse(Int, l[2:length(l)])
        println("cmd=", command, " num=", number)

        if command == 'N'
            pos = move(pos, 0, number)
        elseif command == 'S'
            pos = move(pos, 180, number)
        elseif command == 'E'
            pos = move(pos, 90, number)
        elseif command == 'W'
            pos = move(pos, 270, number)
        elseif command == 'L'
            pos = reflect(pos, -1 * number)
        elseif command == 'R'
            pos = reflect(pos, number)
        elseif command == 'F'
            # Move the ship
            for i in 1:number
                ship_pos += pos
            end
        end

        println("ship_pos: ", ship_pos, " waypoint_pos: ", pos)
    end

    result = abs(ship_pos[1]) + abs(ship_pos[2])
    println("[part 2] File = ", fname, " ... Result = ", result)

    return result
end


@test run("12ex.txt") == 25
run("12.txt")

@test run2("12ex.txt") == 286
run2("12.txt")
