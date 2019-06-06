module Hello

using Metaheuristics
using CEC17

function parseArgs(args)
    if length(args)%2 != 0
        @error "No Valid Arguments..."
        exit(1)
    end

    arguments = Dict([ ("--D", 10),  ("--N", 100), ("--K", 7), ("--eta", 2.0), ("--instance", 1)  ])
    for i = 1:div(length(args), 2)
        arguments[args[2i-1]] = parse(Float64, args[2i])
    end

    # display(arguments)
    return Int(arguments["--D"]), Int(arguments["--N"]), Int(arguments["--K"]), Float64(arguments["--eta"]), Int(arguments["--instance"])
end

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint

    D, N, K, η_max, instance = parseArgs(ARGS)

    f(x, fnum=instance) = cec17_test_func(x, fnum) - fnum*100.0

    x, fx = eca(f, D; K = K, N = N, η_max=η_max, showResults=false)


    print(fx)
    # display(x)

    return 0
end

# using PackageCompiler
# build_executable("main.jl", "main")


end