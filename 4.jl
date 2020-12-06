required_fields = Dict(
# byr (Birth Year) - four digits; at least 1920 and at most 2002.
"byr" => function (s::SubString)
    x = parse(Int64, s)
    return 1920 <= x && x <= 2002
end,
# # iyr (Issue Year) - four digits; at least 2010 and at most 2020.
"iyr" => function (s::SubString)
    x = parse(Int64, s)
    return 2010 <= x && x <= 2020
end,
# # eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
"eyr" => function (s::SubString)
    x = parse(Int64, s)
    return 2020 <= x && x <= 2030
end,
# # hgt (Height) - a number followed by either cm or in:
#     # If cm, the number must be at least 150 and at most 193.
#     # If in, the number must be at least 59 and at most 76.
"hgt" => function (s::SubString)
    x = parse(Int64, s[1:length(s) - 2])
    unit = s[length(s) - 1:length(s)]
    if unit == "cm"
        # cm case
        return 150 <= x && x <= 193
    else
        # in case
        return 59 <= x && x <= 76
    end
end,
# hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
"hcl" => function (s::SubString)
    # TODO: check for alphanumeric
    return length(s) == 7 && s[1] == '#'
end,
# # ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
"ecl" => function (s::SubString)
    return s in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"]
end,
# # pid (Passport ID) - a nine-digit number, including leading zeroes.
"pid" => function (s::SubString)
    # has 9 digits?
    if ! (length(s) == 9)
        return false
    end
    # is numeric?
    try
        parse(Int64, s)
        return true
    catch
        return false
    end
end,
# # "cid", # confusing: this is described as a "required" field at first but then "optional" later
)




function is_valid(passport::Dict)
    result = true
    for k in keys(required_fields)
        if ! haskey(passport, k)
            result = false
            break
        end

        rule = required_fields[k]
        if ! rule(passport[k])
            println("Failed rule ", k, " for passport ", passport)
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

@assert run("4ex2.txt") == 0
@assert run("4ex3.txt") == 4

run("4.txt")
