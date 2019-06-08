module Instance

using Metaheuristics
using CEC17
import Random: seed!

desired_accu = 1e-6

function accuracy_termination(P::Array)
    if typeof(P[1]) <: Float64
        f = minimum(P)
    elseif typeof(P[1]) <: Metaheuristics.Bee
        f = minimum( map(x->x.sol.f, P) )
    else
        f = minimum( map(x->x.f, P) )
    end

    return abs(f) < desired_accu
end

function parseArgsED(args)
    arguments = Dict([ 
                        "--N" => 100,
                        "--F" => 1.0,
                        "--CR" => 0.9,
                        "--strategy" => 1,
                        "--D" => 10,
                        # "--instance" => 1,
                        # "--desiredAccur" => 1e-6,
                    ])

    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    return arguments
end


function parseArgsECA(args)
    arguments = Dict([ ("--D", 10),
                       ("--N", 100),
                       ("--K", 7),
                       ("--eta", 2.0),
                       # ("--instance", 1),
                       # ("--desiredAccur", 1e-6)
                    ])
   
    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    return arguments
end

function parseArgsPSO(args)
    arguments = Dict([ ("--D", 10),
                       ("--N", 100),
                       ("--C1", 2.0),
                       ("--C2", 2.0),
                       ("--omega", 0.8),
                       # ("--instance", 1),
                       # ("--desiredAccur", 1e-6)
                    ])
    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    return arguments
end

function parseArgsABC(args)
    arguments = Dict([ ("--D", 10),
                       ("--N", 100),
                       ("--limit", 10),
                       ("--Ne", 0.5),
                       ("--No", 0.5),
                       # ("--instance", 1),
                       # ("--desiredAccur", 1e-6)
                    ])

    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

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
                    termination = accuracy_termination,
                    showResults = false)
    return fx
end

function edResult(f, p)
    x, fx = DE(f, Int(p["--D"]);
                N = Int(p["--N"]),
                F = Float64(p["--F"]),
                CR= Float64(p["--CR"]),
                termination = accuracy_termination,
                showResults = false)
    return fx
end

function psoResult(f, p)
    x, fx = pso(f, Int(p["--D"]);
                    N  = Int(p["--N"]),
                    C1 = Float64(p["--C1"]),
                    C2 = Float64(p["--C2"]),
                    ω  = Float64(p["--omega"]),
                    termination = accuracy_termination,
                    showResults = false)
    return fx
end

function abcResult(f, p)
    D = Int(p["--D"])
    N = round(Int, p["--N"])
    Ne = round(Int, p["--Ne"]*N)

    println("$N $Ne")

    x, fx = ABC(f, Matrix([-100.0ones(D) 100ones(D)]');
                            N = Int(p["--N"]),
                            limit = Int(p["--limit"]),
                            Ne = Ne,
                            termination = accuracy_termination,
                            No = N - Ne)
    return fx
end

function getResult(f, alg, parms)
    fx = NaN
    if lowercase(alg)=="ed"
        fx = edResult(f, parms)
    elseif lowercase(alg)=="eca"
        fx = ecaResult(f, parms)
    elseif lowercase(alg)=="pso"
        fx = psoResult(f, parms)
    elseif lowercase(alg)=="abc"
        fx = abcResult(f, parms)
    else
        @error "Not valid algorithm."
        exit(1)
    end

    if fx < desired_accu
        fx = 0.0
    end

    fx
end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint

    alg, parms = parseArgs(ARGS)

    if "--desiredAccur" in keys(parms)
        global desired_accu = parms["--desiredAccur"]
    end

    if "--seed" in keys(parms)
        seed!(round(Int, parms["--seed"]))
    else
        @info("Starting with a random seed...")
    end

    if "--instance" in keys(parms)
        instance = round(Int, parms["--instance"])
    else
        @error("No instance (`--instance` flag) was provided...")
        exit(1)
    end

    f(x, fnum=instance) = cec17_test_func(x, fnum) - fnum*100.0



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