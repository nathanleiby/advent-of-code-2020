
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

# Chinese Remainder Theorem
# https://en.wikipedia.org/wiki/Chinese_remainder_theorem#Computation
# I first tried to use mods.jl CRT() function but hit error (https://github.com/scheinerman/Mods.jl)
# Now following approach here https://www.freecodecamp.org/news/how-to-implement-the-chinese-remainder-theorem-in-java-db88a3f1ffe0/
function CRT(nums, rems)
    # Step 1: Find the product of all the numbers
    product = reduce(*, nums)
    # Step 2: Find the partial product of each number.
    partial_products = map((x) -> Int(product / x), nums)
    # Step 3: Find the modular multiplicative inverse of number[i] modulo partialProduct[i].
    inverses = []
    for i in 1:length(nums)
        push!(inverses, invmod(partial_products[i], nums[i]))
    end

    # Step 4: Final total
    total = 0
    for i in 1:length(nums)
        total += partial_products[i] * inverses[i] * rems[i];
    end

    return mod(total, product)
end

function run2(l)
    # Parse the input
    nums = []
    rems = []
    for (idx, num) in enumerate(l)
        if num == 0
            # skip 0's, these are the X's in the puzzle input
            continue
        end

        rem = 0
        if idx != 1
            rem = num - (idx - 1)
        end
        push!(nums, num)
        push!(rems, rem)
    end

    result = CRT(nums, rems)
    println("[part 2] Result = ", result)
    return result
end


# NOTE: replaced x's with 0's
@test run2([17,0,13,19]) == 3417.
# 3417 mod 17 = (17-0) # where 0 is offset in list
# 3417 mod 13 = (13-2) # where -2 is offset in list
# 3417 mod 19 = (19-3) # where -3 is offset in list
# i.e.
# (3417 + 0) mod 17 = 0    # where 0 is offset in list
# (3417 + 2) mod 13 = 0    # where -2 is offset in list
# (3417 + 3) mod 19 = 0    # where -3 is offset in list
# i.e.
# trying to solve:
#     (X mod 17) =  (X+2 mod 13) = (X+3 mod 19)

@test run2([67,7,59,61]) == 754018.
@test run2([67,0,7,59,61]) == 779210.
@test run2([67,7,0,59,61]) == 1261476.
@test run2([1789,37,47,1889]) == 1202161486.

run2([17,0,0,0,0,0,0,0,0,0,0,37,0,0,0,0,0,439,0,29,0,0,0,0,0,0,0,0,0,0,13,0,0,0,0,0,0,0,0,0,23,0,0,0,0,0,0,0,787,0,0,0,0,0,0,0,0,0,41,0,0,0,0,0,0,0,0,19])
