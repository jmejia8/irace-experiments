module Hello

using Metaheuristics
using CEC17
import Random: seed!

function parseArgsED(args)
    arguments = Dict([ 
                        "--N" => 100,
                        "--F" => 1.0,
                        "--CR" => 0.9,
                        "--strategy" => 1,
                        "--D" => 10,
                        "--instance" => 1,
                    ])

    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    # return Int(arguments["--D"]), Int(arguments["--N"]), arguments["--F"], arguments["--CR"], Int(arguments["--instance"])
    return arguments
end

function parseArgsECA(args)
    arguments = Dict([ ("--D", 10),
                       ("--N", 100),
                       ("--K", 7),
                       ("--eta", 2.0),
                       ("--instance", 1)
                    ])
   
    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    # return Int(arguments["--D"]), Int(arguments["--N"]), Int(arguments["--K"]), Float64(arguments["--eta"]), Int(arguments["--instance"])
    return arguments
end

function parseArgsPSO(args)
    arguments = Dict([ ("--D", 10),
                       ("--N", 100),
                       ("--C1", 2.0),
                       ("--C2", 2.0),
                       ("--omega", 0.8),
                       ("--instance", 1)
                    ])
    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    # return Int(arguments["--D"]), Int(arguments["--N"]), arguments["--C1"], arguments["--C1"], arguments["--omega"], Int(arguments["--instance"])
    return arguments
end

function parseArgsABC(args)
    arguments = Dict([ ("--D", 10),
                       ("--N", 100),
                       ("--limit", 10),
                       ("--Ne", 10),
                       ("--No", 10),
                       ("--instance", 1)
                    ])

    arguments["--Ne"] = arguments["--No"] = div(arguments["--N"], 2)

    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    # return Int(arguments["--D"]), Int(arguments["--N"]), Int(arguments["--limit"]), Int(arguments["--Ne"]), Int(arguments["--No"]), Int(arguments["--instance"])
    return arguments
end

function parseArgs(args)
    # if length(args)%2 != 0
    #     @error "No Valid Arguments..."
    #     exit(1)
    # end

    alg = args[1]

    args = args[findfirst(x->'-' in x, args):end]

    if lowercase(alg)=="ed"
        return alg, parseArgsED(args)
    elseif lowercase(alg)=="eca"
        return alg, parseArgsECA(args)
    elseif lowercase(alg)=="pso"
        return alg, parseArgsPSO(args)
    elseif lowercase(alg)=="abc"
        return alg, parseArgsABC(args)
    else
        @error "No Valid Arguments..."
        exit(1)
    end

end

# ./main eca --D 10 --instance 4  --N 189 --K 5 --eta 2 --seed 123456
# ./main  ed --D 10 --instance 4  --N 189 --F 5  --CR 2 --strategy 1 --seed 123456

function ecaResult(f, p)

    x, fx = eca(f, Int(p["--D"]);
                    K = Int(p["--K"]),
                    N = Int(p["--N"]),
                    η_max = Float64(p["--eta"]),
                    showResults = false)
    return fx
end

function edResult(f, p)
    x, fx = DE(f, Int(p["--D"]);
                N = Int(p["--N"]),
                F = Float64(p["--F"]),
                CR= Float64(p["--CR"]),
                showResults = false)
    return fx
end

function psoResult(f, p)
    x, fx = pso(f, Int(p["--D"]);
                    N  = Int(p["--N"]),
                    C1 = Float64(p["--C1"]),
                    C2 = Float64(p["--C2"]),
                    ω  = Float64(p["--omega"]),
                    showResults = false)
    return fx
end

function abcResult(f, p)
    D = Int(p["--D"])
    x, fx = ABC(f, Matrix([-100.0ones(D) 100ones(D)]');
                            N = Int(p["--N"]),
                            limit = Int(p["--limit"]),
                            Ne = Int(p["--Ne"]),
                            No = Int(p["--No"]))
    return fx
end

function getResult(f, alg, parms)
    if lowercase(alg)=="ed"
        return edResult(f, parms)
    elseif lowercase(alg)=="eca"
        return ecaResult(f, parms)
    elseif lowercase(alg)=="pso"
        return psoResult(f, parms)
    elseif lowercase(alg)=="abc"
        return abcResult(f, parms)
    else
        @error "Not valid algorithm."
        exit(1)
    end
end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint

    alg, parms = parseArgs(ARGS)

    seed!(round(Int, parms["--seed"]))

    instance = round(Int, parms["--instance"])

    f(x, fnum=instance) = cec17_test_func(x, fnum) - fnum*100.0


    # display(parms)

    print(getResult(f, alg, parms))

    return 0
end

# using PackageCompiler
# build_executable("main.jl", "main")

# julia_main([ "eca", "--D", "10", "--instance", "10", "--N", "189", "--K", "7", "--eta", "2", "--seed", "123456"])
# julia_main([ "ed", "--D", "10", "--instance", "10", "--N", "189", "--K", "7", "--eta", "2", "--seed", "123456"])
# julia_main([ "pso", "--D", "10", "--instance", "10", "--N", "189", "--K", "7", "--eta", "2", "--seed", "123456"])
# julia_main([ "abc", "--D", "10", "--instance", "10", "--N", "189", "--K", "7", "--eta", "2", "--seed", "123456"])

end