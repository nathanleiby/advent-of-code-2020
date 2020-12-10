using Test;

function run(fname)
    differences = Dict()
    # initialize
    differences[1] = 0
    differences[2] = 0
    differences[3] = 0

    f = open(fname, "r")
    lines = readlines(f)
    nums = map((x) -> parse(Int, x), lines)
    sort!(nums)

    # START edge case (wall has joltage of 0)
    diff = nums[1] - 0
    differences[diff] += 1

    for i in collect(2:length(nums))
        diff = nums[i] - nums[i - 1]
        differences[diff] += 1
    end

    # END edge case (there's always one last difference of 3)
    differences[3] += 1

    ones = differences[1]
    threes = differences[3]
    result = ones * threes
    println("[", fname, "] Ones = ", ones, " Threes = ", threes, " ... result = ", result)
    return result
end

@test run("10ex1.txt") == 7 * 5
@test run("10ex2.txt") == 22 * 10
run("10.txt")
