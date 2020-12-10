using Test;
using Combinatorics;
# LEARNINGS:
# - for run2: using Combinatorics + powerset(nums) ... is the right logic but WAAAAY too slow


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
    println(nums)

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

function run2(fname)
    f = open(fname, "r")
    lines = readlines(f)
    nums = map((x) -> parse(Int, x), lines)
    sort!(nums)

    valid_count = 0
    min_val = 0
    max_val = nums[length(nums)] + 3

    nums = [min_val, nums..., max_val]

    # NEW ALGO:
    # - find all jumps of 3.
    # - partition the list into sublists, separated by those jumps.
    all_sets = []
    current_set = [nums[1]]
    for i in collect(2:length(nums))
        diff = nums[i] - nums[i - 1]
        if diff == 3
            push!(all_sets, current_set)
            current_set = [nums[i]]
        else
            push!(current_set, nums[i])
        end
    end
    # add last set
    push!(all_sets, current_set)

    result = 1
    for s in all_sets
        # - run algo on those smaller sublists
        # - multiply results
        vs = valid_subsets(s)
        println("S = ", s, " .. valid subsets = ", length(vs))
        for vvs in vs
            println("\t", vvs)
        end
        result *= length(vs)
    end


    println("[", fname, "] [part II] result = ", result)
    return result
end

function valid_subsets(s)
    if length(s) < 3
        return 1
    end

    out = []
    total = 0
    inner_items = powerset(s[2:length(s) - 1])
    for ii in inner_items
        vs = [first(s), ii..., last(s)]
        if is_valid(vs)
            push!(out, vs)
        end
    end
    return out
end

function is_valid(l)
    for i in 2:length(l)
        if (l[i] - l[i - 1]) > 3
            return false
        end
    end
    return true
end

@test run("10ex1.txt") == 7 * 5
@test run("10ex2.txt") == 22 * 10
run("10.txt")

@test run2("10ex1.txt") == 8
@test run2("10ex2.txt") == 19208
run2("10.txt")
