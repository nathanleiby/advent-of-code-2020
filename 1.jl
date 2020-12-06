# EXAMPLE INPUT:
example = [
1721,
979,
366,
299,
675,
1456,
]

f = open("1.txt", "r")
lines = readlines(f)
numbers = map((x) -> parse(Int64, x), lines)
# > ["this is a simple file containing", "text and numbers:", "43.3", "17"]
close(f)

function compute2(d)
    for i in 1:length(d)
        for j in i + 1:length(d)
            if d[i] + d[j] == 2020
                return d[i] * d[j]
            end
        end
    end
    return -1
end

function compute3(d)
    for i in 1:length(d)
        for j in i + 1:length(d)
            for k in j + 1:length(d)
                if d[i] + d[j] + d[k] == 2020
                    return d[i] * d[j] * d[k]
                end
            end

        end
    end
    return -1
end


println(compute2(example))
println(compute3(example))

println(compute2(numbers))
println(compute3(numbers))

