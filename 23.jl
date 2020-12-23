# TODO: use mod() to find right position
using Test

function print_cups(cups, cur)
    out = ""
    for c in cups
        if c == cur
            out *= "($(c)) "
        else
            out *= "$(c) "
        end
    end
    @info("cups: $(out)")
end

function pick_up_cups(cups, cur)
    first = clockwise_val(cups, cur)
    second = clockwise_val(cups, first)
    third = clockwise_val(cups, second)

    remaining_cups = filter((x) -> !in(x, [first, second, third]), cups)
    picked_up = [first, second, third]

    return remaining_cups, picked_up
end

# given a value, finds the cup that's clockwise of it
function clockwise_val(list, val)
    idx = indexin(val, list)[1]
    if idx == length(list)
        return list[1]
    else
        return list[idx + 1]
    end
end

function place_cups(cups, picked_up, dest)
    idx = indexin(dest, cups)[1]
    return [cups[1:idx]..., picked_up..., cups[idx + 1:end]...]
end


function run(input)

    cups = map(x -> parse(Int, x), collect(input))
    cur = cups[1]
    max_cup = maximum(cups)
    for move in 1:100
        @info("-- move $(move) --")
        print_cups(cups, cur)

        # The crab picks up the three cups that are immediately clockwise of
        # the current cup. They are removed from the circle; cup spacing is
        # adjusted as necessary to maintain the circle.
        cups, picked_up = pick_up_cups(cups, cur)
        @info("pick up: $(picked_up)")

        # The crab selects a destination cup: the cup with a label equal to the
        # current cup's label minus one. If this would select one of the cups
        # that was just picked up, the crab will keep subtracting one until it
        # finds a cup that wasn't just picked up. If at any point in this
        # process the value goes below the lowest value on any cup's label, it
        # wraps around to the highest value on any cup's label instead.
        dest = (cur - 1)
        while ! in(dest, cups)
            dest = mod(dest - 1, max_cup + 1)
        end
        @info("destination: $(dest)")
        @info("")

        # The crab places the cups it just picked up so that they are
        # immediately clockwise of the destination cup. They keep the same
        # order as when they were picked up.
        cups = place_cups(cups, picked_up, dest)
        cur = clockwise_val(cups, cur)
    end

    one_cup_idx = indexin(1, cups)[1]
    result = join([cups[one_cup_idx + 1:end]..., cups[1:one_cup_idx - 1]...])
    println("Result = ", result)
    return result
end

example = "389125467"
actual = "362981754"
@test run(example) == "67384529"

run(actual)
