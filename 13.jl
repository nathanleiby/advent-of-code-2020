
using Test;

function run(fname)
    # read fil
    f = open(fname)
    lines = readlines(f)
    close(f)

    # parse input
    earliest_depart = parse(Int, lines[1])
    nums = split(lines[2], ",")
    filter!(x -> x != "x", nums)
    bus_ids = map(x -> parse(Int, x), nums)

    println("Earliest departure = ", earliest_depart)
    println("Bus IDs = ", bus_ids)

    result_bus = -1
    result_wait = +Inf
    for bid in bus_ids
        possible_departure = (div(earliest_depart, bid) + 1) * bid
        possible_wait_time = possible_departure - earliest_depart
        println("Possible = ", possible_wait_time, " (Bus ID = ", bid, " Departure = ", possible_departure, ")")
        if possible_wait_time < result_wait
            result_bus = bid
            result_wait = possible_wait_time
        end
    end

    result = result_bus * result_wait
    println("Result = ", result, " (Bus ID = ", result_bus, ", Wait Time = ", result_wait, ")")

    return result
end

# 59*5 = 295
@test run("13ex.txt") == 295
run("13.txt")
