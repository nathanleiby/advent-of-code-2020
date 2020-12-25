using Test

STARTING_SUBJECT_NUM = 7
MAX_VAL = 20201227 # ~20M

function transform_subject_number(subject_number, loop_size)
    value = 1
    for i in 1:loop_size
        # Set the value to itself multiplied by the subject number.
        value = value * subject_number
        # Set the value to the remainder after dividing the value by 20201227.
        value = mod(value, MAX_VAL)
    end
    return value
end

function search_for_loop_size(target)
    value = 1
    for i in 1:MAX_VAL
        # Set the value to itself multiplied by the subject number.
        value = value * STARTING_SUBJECT_NUM
        # Set the value to the remainder after dividing the value by 20201227.
        value = mod(value, MAX_VAL)
        if value == target
            return i
        end
    end
    throw("failed to find loop size")
end


function run(public_keys)
    # Discover loop size
    loop_sizes = map(search_for_loop_size, public_keys)

    @show public_keys
    @show loop_sizes

    # The card transforms the subject number of the door's public key according
    # to the card's loop size. The result is the encryption key.

    # The door transforms the subject number of the card's public key according
    # to the door's loop size. The result is the same encryption key as the
    # card calculated.
    encryption_keys = [
        transform_subject_number(public_keys[2], loop_sizes[1])
        transform_subject_number(public_keys[1], loop_sizes[2])
    ]
    @assert encryption_keys[1] == encryption_keys[2]

    result = encryption_keys[1]
    println("Result = $(result)")
    return result
end

@test run([5764801,17807724]) == 14897079

run([1965712, 19072108])
