using Test
using DataStructures
using Logging

# LEARNINGS:
# - can use macros like @debug or @info to log with global logger
# - @debug isn't visible by default, have to tweak log levels
# - to use my own logger (e.g. writing to a file) I have to import Logging and init a SimpleLogger
#   ... this logger can also override the global logger

io = open("22.log", "w+")
logger = SimpleLogger(io)
global_logger(logger)

global total_games = 1
function recursive_combat(decks, isNewGame=false)
    game = 1
    if ! isNewGame
        global total_games += 1
        game = total_games
    end

    @info("\n=== Game $(game) ===")

    round = 0
    previous_rounds = Dict()
    while length(decks[1]) > 0 && length(decks[2]) > 0
        round += 1
        @info("\n-- Round $(round) (Game $(game)) --")
        for i in 1:2
            @info("Player $(i)'s deck: $(collect(decks[i]))")
        end

        p1_cards = join(collect(decks[1]), ",")
        p2_cards = join(collect(decks[2]), ",")
        key = (p1_cards, p2_cards)
        if in(key, keys(previous_rounds))
            @info("... the game instantly ends in a win for player 1")
            return 1, 2, decks
        end
        previous_rounds[key] = true

        # draw top card from each
        cards = Dict()
        for i in 1:2
            cards[i] = dequeue!(decks[i])
            @info("Player $(i) plays: $(cards[i])")
        end

        # If both players have at least as many cards remaining in their deck
        # as the value of the card they just drew, the winner of the round is
        # determined by playing a new game of Recursive Combat (see below).
        winner, loser = Nothing, Nothing
        if length(decks[1]) >= cards[1] && length(decks[2]) >= cards[2]
            new_decks = Dict()
            for p in 1:2
                # create a new deck of the correct length
                q = Queue{Int}()
                for card in collect(decks[p])[1:cards[p]]
                    enqueue!(q, card)
                end
                new_decks[p] = q
            end

            @info("Playing a sub-game to determine the winner...")
            winner, loser, _ = recursive_combat(new_decks)

            @info("\n...anyway, back to game $(game)")
        else
            # Otherwise, at least one player must not have enough cards left in
            # their deck to recurse; the winner of the round is the player with
            # the higher-value card.
            winner, loser = 2, 1
            if cards[1] > cards[2]
                winner, loser = 1, 2
            end
        end

        @info("Player $(winner) wins round $(round) of game $(game)!")

        # The winner keeps both cards, placing them on the bottom of their own deck
        # so that the winner's card is above the other card.
        enqueue!(decks[winner], cards[winner])
        enqueue!(decks[winner], cards[loser])
    end

    if game == 1
        @info ("== Post-game results ==")
        for i in 1:2
            @info("Player $(i)'s deck: $(collect(decks[i]))")
        end
    end

    if length(decks[1]) == 0
        # player 2 wins
        return 2, 1, decks
    else
        # player 1 wins
        return 1, 2, decks
    end
end

function combat(decks)
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

function run(fname, version=1)
    println("\n[Part $(version)] Running $(fname)...")
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

    winning_deck = Nothing
    if version == 1
        winning_deck = combat(decks)
    else
        winner, loser, decks = recursive_combat(decks, true)
        winning_deck = decks[winner]
    end

    # compute score
    result = 0
    for (idx, val) in enumerate(reverse(collect(winning_deck)))
        result += (idx * val)
    end

    println("[Part $(version)] Running $(fname) got result = $(result)")
    return result
end

# @test run("22ex.txt") == 306
# run("22.txt")

@test run("22ex.txt", 2) == 291
# run("22ex.part2.txt", 2)
# @test run("22ex.part2.txt", 2) == 105 # should exit early... i think this is right result?
run("22.txt", 2)
