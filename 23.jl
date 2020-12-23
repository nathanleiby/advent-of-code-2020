using Test
using CircularList

# TODO: using circular list
# can make it lazy if desired

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
end

function place_cups(cups, picked_up, dest)
    return cups
end

MAX_CUP = Int(1e6)
MAX_MOVES = Int(1e7)
# MAX_CUP = Int(9)
# MAX_MOVES = Int(100)

function run(input, version=1)
    @info "initializing list..."
    given_values = map(x -> parse(Int, x), collect(input))
    cur = given_values[1] # TODO: ideally cur will == head of the list to save effort

    cups = Nothing
    lookup = Dict() # maps from value to Node in CircularList
    for i in given_values
        if cups == Nothing
            # initialize
            cups = circularlist(i)
            lookup[i] = head(cups)
        else
            insert!(cups, i)
            lookup[i] = head(cups)
        end
    end

    max_cup = 9
    if version == 2
        max_cup = MAX_CUP
        for i in 10:max_cup
            insert!(cups, i)
            lookup[i] = head(cups)
        end
    end


    num_moves = 100
    if version == 2
        num_moves = Int(MAX_MOVES)
    end
    @info "starting..."
    for move in 1:num_moves
        # @show move
        if move % Int(1e5) == 0
            @info("-- move $(move) --")
        end
        # print_cups(cups, cur)

        # The crab picks up the three cups that are immediately clockwise of
        # the current cup. They are removed from the circle; cup spacing is
        # adjusted as necessary to maintain the circle.

        ## PICK UP CUPS
        jump!(cups, lookup[cur])
        # while head(cups).data != cur
        #     forward!(cups)
        # end

        picked_up = []
        for i in 1:3
            forward!(cups)
            push!(picked_up, current(cups).data)
            delete!(cups)
            # previous node becomes the head
            @assert cur == head(cups).data
        end
        # @show picked_up

        next_cur = next(cups).data

        # @info("pick up: $(picked_up)")

        # The crab selects a destination cup: the cup with a label equal to the
        # current cup's label minus one. If this would select one of the cups
        # that was just picked up, the crab will keep subtracting one until it
        # finds a cup that wasn't just picked up. If at any point in this
        # process the value goes below the lowest value on any cup's label, it
        # wraps around to the highest value on any cup's label instead.
        dest = cur - 1
        while dest == 0 || in(dest, picked_up)
            dest = mod(dest - 1, max_cup + 1)
        end

        # @info("destination: $(dest)")
        # @info("")

        # The crab places the cups it just picked up so that they are
        # immediately clockwise of the destination cup. They keep the same
        # order as when they were picked up.

        ## PLACE CUPS
        jump!(cups, lookup[dest])
        # while head(cups).data != dest
        #     forward!(cups)
        # end

        for p in picked_up
            insert!(cups, p)
            lookup[p] = head(cups)
        end

        cur = next_cur
    end

    jump!(cups, lookup[1])

    result = Nothing
    if version == 1
        result = join(collect(cups)[2:end]) # skip 1
    else
        forward!(cups)
        a = head(cups).data
        forward!(cups)
        b = head(cups).data
        @show a
        @show b
        result = a * b
    end

    println("Result = ", result)
    return result
end

function run2(input)
    return run(input, 2)
end

example = "389125467"
actual = "362981754"
@test run(example) == "67384529"

run(actual)

@test run2(example) == (934001 * 159792) # 149245887792

run2(actual)
