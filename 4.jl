required_fields = [
"byr",
"iyr",
"eyr",
"hgt",
"hcl",
"ecl",
"pid",
# "cid", # confusing: this is described as a "required" field at first but then "optional" later
]

function is_valid(o::Dict)
    result = true
    for k in required_fields
        if ! haskey(o, k)
            result = false
            break
        end
    end

    # println("IsValid? => ", result)
    return result
end

function compute(rows)
    valid_count = 0
    passport = Dict()
    for r in rows
        # end current passport
        if r == ""
            if is_valid(passport)
                valid_count += 1
            end
            passport = Dict()
        else
            # continue reading details of current passport
            items = split(r, " ")
            for i in items
                key_val = split(i, ":")
                key = key_val[1]
                passport[key_val[1]] = key_val[2]
            end
        end
    end

    # make sure to include last passport in file
    if is_valid(passport)
        valid_count += 1
    end

    return valid_count
end

function run(fname)
    println("Running", fname, " ...")
    f = open(fname, "r")
    rows = readlines(f)
    close(f)

    out = compute(rows)
    println("Final result for ", fname, " was: ", out)
    return out
end

@assert run("4ex.txt") == 2

run("4.txt")
