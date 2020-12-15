using Test

function run(nums, target_turn=2020)
    last_said_on_turn = Dict()

    turn = 1
    # initialize
    for n in nums[1:length(nums) - 1]
        last_said_on_turn[n] = turn
        turn += 1
        # println("Turn = ", turn, " Val = ", n)
    end

    prev = last(nums)
    while turn < target_turn
        # compute next number to say
        # If that was the first time the number has been spoken, the current player
        # says 0. (i.e. default to 0)
        next = 0
        if haskey(last_said_on_turn, prev)
            # Otherwise, the number had been spoken before; the current player
            # announces how many turns apart the number is from when it was previously
            # spoken.
            next = turn - last_said_on_turn[prev]
        end

        # speak!
        last_said_on_turn[prev] = turn
        # println("Turn = ", turn, " Val = ", prev)

        prev = next
        turn += 1
    end

    println("Turn = ", turn, " Val = ", prev)
    return prev
end

println("\n[Part 1] Examples:")
@test run([0,3,6], 4) == 0
@test run([0,3,6], 5) == 3
@test run([0,3,6], 6) == 3
@test run([0,3,6], 7) == 1
@test run([0,3,6], 8) == 0
@test run([0,3,6], 9) == 4
@test run([0,3,6], 10) == 0
@test run([0,3,6]) == 436

println("\n[Part 1] Result:")
run([19,0,5,1,10,13])

println("\n[Part 2] Examples:")
@test run([0,3,6], 30000000) == 175594.
# Given 1,3,2, the 30000000th number spoken is 2578.
# Given 2,1,3, the 30000000th number spoken is 3544142.
# Given 1,2,3, the 30000000th number spoken is 261214.
# Given 2,3,1, the 30000000th number spoken is 6895259.
# Given 3,2,1, the 30000000th number spoken is 18.
# Given 3,1,2, the 30000000th number spoken is 362.

println("\n[Part 2] Result:")
run([19,0,5,1,10,13], 30000000)

