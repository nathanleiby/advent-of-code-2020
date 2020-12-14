using Test;

function run(fname)
    f = open(fname)
    lines = readlines(f)
    close(f)

    mask = ""
    mem_values = Dict()
    for line in lines
        parts = split(line, " = ")
        cmd, val = parts[1], parts[2]
        println("cmd = ", cmd)
        println("val = ", val)
        if cmd == "mask"
            # update the mask
            println("MASK VAL = ", val)
            mask = val
        else
            # update something in mem, applying mask
            # TODO: find something like 123 in mem[123]
            mem_idx = parse(Int, cmd[5:length(cmd) - 1])
            num = parse(Int, parts[2])
            println("Mem_idx = ", mem_idx, " ... Num = ", num)

            # convert number to bit representation
            bits = bitstring(num)[29:64]  # want the last 36-bits
            # apply mask
            println("mask = ", mask)
            println("bits = ", bits)
            out = ""
            for (idx, m) in enumerate(mask)
                if m == 'X'
                    out *= bits[idx]
                else
                    out *= m
                end
            end
            println("new  = ", out)
            # store final number in memory
            new_val = parse(Int, out, base=2)
            println("newval = ", new_val)
            mem_values[mem_idx] = new_val
        end
    end
    total = 0
    for k in keys(mem_values)
        v = mem_values[k]
        total += v
    end

    println("Result of running ", fname, " was = ", total)
    return total
end

@test run("14ex.txt") == 165
run("14.txt")
