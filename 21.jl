using Test

struct Entry
    Ingredients::Set{String}
    Allergens::Set{String}
end

function find_safe_ingredients(a, b)
    out = Set()
    # If they *dont* have overlapping allergens
    if length(intersect(a.Allergens, b.Allergens)) > 0
        return out
    end
    # the overlapping ingredients cannot be the cause of allergens
    return intersect(a.Ingredients, b.Ingredients)
end

# TODO
# INSTEAD, try this algo
# 1. find everything that has the allergen
# 2. set if they have exactly one common ingredient

function run(fname)
    f = open(fname, "r")
    lines = readlines(f)
    close(f)

    entries = []
    for l in lines
        l = l[1:end - 1]
        parts = split(l, " (contains ")
        ingredients = split(parts[1])
        allergens = split(parts[2], ", ")
        push!(entries, Entry(Set(ingredients), Set(allergens)))
    end
    entries_bak = copy(entries)

    for e in entries
        @show e
    end
    all_allergens = reduce(union, map((e) -> e.Allergens, entries))
    @show all_allergens
    ingredient_to_allergen = Dict()
    while length(all_allergens) > 0
        for a in all_allergens
            @show a
            entries_w_allergen = filter((e) -> in(a, e.Allergens), entries)
            @show entries_w_allergen
            ingredients_that_may_cause = intersect(map((e) -> e.Ingredients, entries_w_allergen)...)
            @show ingredients_that_may_cause
            if length(ingredients_that_may_cause) == 1
                ingr = first(ingredients_that_may_cause)
                # we found it!
                ingredient_to_allergen[ingr] = a
                delete!(all_allergens, a)
                # remove it from entries as well
                for e in entries
                    delete!(e.Ingredients, ingr)
                    delete!(e.Allergens, a)
                end
                # break, since we modified all_allergens and are looping within it
                break
            end
        end
    end

    unsafe_ingredients = collect(keys(ingredient_to_allergen))
    result = 0
    for e in entries_bak
        result += length(setdiff(e.Ingredients, unsafe_ingredients))
    end

    println("[part 1] File = ", fname, " got result = ", result)
    return result
end

# mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
# trh fvjkl sbzzf mxmxvkd (contains dairy)
# sqjhc fvjkl (contains soy)
# sqjhc mxmxvkd sbzzf (contains fish)

# manually, seems like
# mxmxvkd => dairy
# sqjhc => fish
# fvjkl => soy

# Each allergen is found in exactly one ingredient.
# Each ingredient contains zero or one allergen.
# **Allergens aren't always marked**, but if they are marked, the corresponding ingredien t is definitely present
@test run("21ex.txt") == 5

run("21.txt")
