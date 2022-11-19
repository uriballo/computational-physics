using Plots
using LaTeXStrings
using LinearAlgebra

mutable struct Potential
    func::Function

    x₀::Float64
    xₙ::Float64

    formula::LaTeXString
end

mutable struct Config
    V::Potential

    dx::Float64

    ψs::Int
    λs::Int

    save::Bool
    filename::String
end

function constructHamiltonian(config::Config)
    # Construct the Hamiltonian matrix
    dx = config.dx
    V = config.V.func
    x = LinRange(config.V.x₀, config.V.xₙ, trunc(Int, 1 ÷ dx))

    # Main diagonal
    md = 1 / (dx^2) .+ V(x)

    # Upper and lower diagonals
    uld = -1 / (2dx^2) .* ones(length(md) - 1)

    SymTridiagonal(md, uld)
end

function help()
    println(
        "----------------------------------------------------------------------------------------",
    )
    println("Usage: julia TISE.jl [OPTIONS]")
    println("Options:")
    println("\t--help,        -h\tPrint this help message")
    println("\t--potential,   -p\tSpecify a sample configuration to use")
    println("\t\t\t\t\t* esin  > sin(20⋅x)⋅x⁴")
    println("\t\t\t\t\t* har   > ¹/₂⋅k⋅x²")
    println("\t\t\t\t\t* gwell > -μe^[-x²/σ^2]")
    println("\t\t\t\t\t* gwall > μe^[-x²/σ^2]")
    println("\t--dx,          -n\tSpecify the number of points to use")
    println("\t--x0,          -x\tSpecify the lower bound of the domain")
    println("\t--xn,          -X\tSpecify the upper bound of the domain")
    println("\t--ef,          -e\tSpecify the number of eigenfunctions to plot")
    println("\t--ev,          -v\tSpecify the number of eigenvalues to plot")
    println("\t--save,        -s\tSave the plot to a file")
    println("\t--sname,       -S\tSpecify the name of the file to save the plot to")
    println(
        "----------------------------------------------------------------------------------------",
    )
end

"""
> Potentials
"""

esin(α) = 1000 .* sin.(20 * α) .* α .^ 4
h(α, k = 1) = 250 * 1 / 2 .* k .* α .^ 2
gaussianWell(α, μ = 10, σ = 2) = -μ * exp.(-(α .^ 2) ./ σ^2)
gaussianWall(α, μ = 10000, σ = 0.1) = μ * exp.(-(α .^ 2) ./ σ^2)

sineP = Potential(esin, 0, 1, L"\sin(20x)x^4")
harP = Potential(h, -5, 5, L"\frac{1}{2} kx^2")
gaussWell = Potential(gaussianWell, -5, 5, L"-\mu e^{-x^2/σ^2}")
gaussWall = Potential(gaussianWall, -5, 5, L"\mu e^{-x^2/σ^2}")


function labels(symbol, n)
    return permutedims([latexstring(symbol, L"_%$i") for i = 1:n])
end

function plotPotential(V::Potential)
    plot(
        V.func,
        V.x₀,
        V.xₙ,
        title = "Potential",
        label = V.formula,
        xlabel = L"x",
        ylabel = L"V(x)",
        legend = :topleft,
        linecolor = :black,
    )
end

function plotEigenvalues(λ, n)
    bar(
        1:n,
        λ[1:n],
        title = "Eigenvalues",
        label = L"E",
        xlabel = L"n",
        ylabel = L"E",
        legend = :topleft,
    )
end

function plotEigenfunctions(Ψ, n)
    ls = labels(L"\Psi", n)

    plot(
        Ψ[:, 1:n],
        title = "Eigenfunctions",
        label = ls,
        xlabel = latexstring("\$x\$ (discrete points between \$x_0\$ and \$x_n\$)"),
        ylabel = L"\psi(x)",
        legend = :topleft,
    )
end

function plotProbabilities(Ψ, n)
    ls = labels(L"\vert\vert\psi\vert\vert^2", n)
    plot(
        Ψ[:, 1:n] .^ 2,
        title = "Probabilities",
        label = ls,
        xlabel = latexstring("\$x\$ (discrete points between \$x_0\$ and \$x_n\$)"),
        ylabel = L"\vert\vert\psi(x)\vert\vert^2",
        legend = :topleft,
    )

end

function initsol(options::Config)
    H = constructHamiltonian(options)
    λ, ψ = eigen(H)

    p1 = plotPotential(options.V)
    p2 = plotEigenvalues(λ, options.λs)
    p3 = plotEigenfunctions(ψ, options.ψs)
    p4 = plotProbabilities(ψ, options.ψs)

    pf = plot(p1, p2, p3, p4, layout = (2, 2), size = (1000, 1000))

    display(pf)
    readline()

    if options.save
        savefig(pf, options.filename)
    end
end

function optToPotential(opt)
    if opt == "esin"
        return sineP
    elseif opt == "har"
        return harP
    elseif opt == "gwell"
        return gaussWell
    else
        return gaussWall
    end
end

function main()
    if "--help" ∈ ARGS || "-h" ∈ ARGS
        help()
    else
        defaultConfig = Config(sineP, 0.01, 5, 5, false, "plot")
        for arg in ARGS
            options = split(arg, "=")
            if options[1] == "--potential" || options[1] == "-p"
                potential = optToPotential(options[2])
                defaultConfig.V = potential
            elseif options[1] == "--dx" || options[1] == "-n"
                defaultConfig.dx = parse(Float64, options[2])
            elseif options[1] == "--x0" || options[1] == "-x"
                defaultConfig.V.x₀ = parse(Float64, options[2])
            elseif options[1] == "--xn" || options[1] == "-X"
                defaultConfig.V.xₙ = parse(Float64, options[2])
            elseif options[1] == "--ef" || options[1] == "-e"
                defaultConfig.ψs = parse(Int, options[2])
            elseif options[1] == "--ev" || options[1] == "-v"
                defaultConfig.λs = parse(Int, options[2])
            elseif options[1] == "--save" || options[1] == "-s"
                defaultConfig.save = true
            elseif options[1] == "--sname" || options[1] == "-S"
                defaultConfig.filename = options[2]
            end
        end

        # Sanity Checks
        if defaultConfig.V.x₀ > defaultConfig.V.xₙ
            println("Error: x₀ must be less than xₙ")
            return
        end
        if defaultConfig.ψs <= 0 || defaultConfig.λs <= 0
            println("Error: ψs and λs must be greater than 0")
            return
        end

        initsol(defaultConfig)
    end
end

main()
