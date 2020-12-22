using Test
using DataStructures

function play(decks)
    round = 0
    while length(decks[1]) > 0 && length(decks[2]) > 0
        round += 1
        println("-- Round $(round) --")
        for i in 1:2
            println("Player $(i)'s deck: $(decks[i])")
        end

    # draw top card from each
        cards = Dict()
        for i in 1:2
            cards[i] = dequeue!(decks[i])
            println("Player $(i) players: $(cards[i])")
        end

        winner, loser = 2, 1
        if cards[1] > cards[2]
            winner, loser = 1, 2
        end

        println("Player $(winner) wins the round!")

        # The winner keeps both cards, placing them on the bottom of their own deck
        # so that the winner's card is above the other card.
        enqueue!(decks[winner], cards[winner])
        enqueue!(decks[winner], cards[loser])
    end

    println("== Post-game results ==")
    for i in 1:2
        println("Player $(i)'s deck: $(decks[i])")
    end

    if length(decks[1]) == 0
        return decks[2]
    else
        return decks[1]
    end
end

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    # initialize decks
    decks = Dict()
    decks[1] = Queue{Int}()
    decks[2] = Queue{Int}()

    # parse input
    current_player = 1
    for l in lines
        if l == "Player 1:"
            current_player = 1
        elseif l == "Player 2:"
            current_player = 2
        elseif l != ""
            num = parse(Int, l)
            enqueue!(decks[current_player], num)
        end
    end

    winning_deck = play(decks)

    # compute score
    result = 0
    for (idx, val) in enumerate(reverse(collect(winning_deck)))
        result += (idx * val)
    end

    println("[Part 1] Running $(fname) got result = $(result)")
    return result
end

@test run("22ex.txt") == 306
run("22.txt")
