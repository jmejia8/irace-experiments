module Hello

using Metaheuristics

f(x) = sum(x.^2)

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    println("hello, world")

    K = parse(Int,)
    N = parse(Int,)
    η_max = parse(Float64,)


    x, fx = eca(f, 10; K = K, N = N, η_max=η_max)

    println(fx)
    display(x)

    return 0
end

end