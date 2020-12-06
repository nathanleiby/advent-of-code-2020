struct BoardingPass
    Row::Int
    Column::Int
    SeatID::Int
end

function toBoardingPass(s::String)::BoardingPass
    s = replace(s, "F" => 0)
    s = replace(s, "B" => 1)
    s = replace(s, "L" => 0)
    s = replace(s, "R" => 1)

    row_s = s[1:length(s) - 3]
    row = parse(Int, row_s, base=2)
    col_s = s[length(s) - 2:length(s)]
    column = parse(Int, col_s, base=2)
    seat = row * 8 + column
    result = BoardingPass(row, column, seat)
    println("parse(", s, ") = ", result)
    return result
end

# examples
@assert toBoardingPass("FBFBBFFRLR") == BoardingPass(44, 5, 357)
@assert toBoardingPass("BFFFBBFRRR") == BoardingPass(70, 7, 567)
@assert toBoardingPass("FFFBBBFRRR") == BoardingPass(14, 7, 119)
@assert toBoardingPass("BBFFBBFRLL") == BoardingPass(102, 4, 820)

function run(fname)
    # read file
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    # compute BoardingPasses
    seatIDs = map((x) -> toBoardingPass(x).SeatID, lines)
    result = maximum(seatIDs) # Warning: max() != maximum()
    println("Ran ", fname, " got ", result)
    return result
end

run("5.txt")

