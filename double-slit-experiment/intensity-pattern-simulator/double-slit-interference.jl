using Plots
using LaTeXStrings

# CLI Arguments
# [1] λ → wavelength in nm.
# [2] a → slit width in mm.
# [3] d → slit separation in mm.
# [4] ℓ → slits-screen distance in m.
# [5] fileName

# Simulation Setup
λ = parse(Float64, ARGS[1]) * 10^-9 # nm → m
a = parse(Float64, ARGS[2]) * 10^-3 # mm → m
d = parse(Float64, ARGS[3]) * 10^-3 # mm → m
ℓ = parse(Float64, ARGS[4])         # m
fileName = ARGS[5]

β(x) = x / ℓ
γ(x) = π * x / λ

# Equation to Model
function I(x)
    cosine = cos(γ(d)β(x))
    sine = sin(γ(a)β(x))
    γβ = γ(a) * β(x)
    return cosine^2 * sine^2 / γβ^2
end

# Plotting
plotFont = "Computer Modern"
default(
    fontfamily = plotFont,
    linewidth = 2,
    framestyle = :box,
    label = nothing,
    grid = false,
)
#scalefontsizes(1.1)

plot(
    I,
    -0.05,
    0.05,
    title = "Double-Slit Interference",
    label = L"I(x)",
    linecolor = :black,
)

xlabel!("screen position")
ylabel!("Intensity")

annotate!(-0.04, 0.95, text(L"\lambda = 550\ \textrm{ nm}", plotFont, 12))
annotate!(-0.0378, 0.875, text(L"a = 0.055\ \textrm{ mm}", plotFont, 12))
annotate!(-0.038, 0.80, text(L"d = 0.125\ \textrm{ mm}", plotFont, 12))
annotate!(-0.041, 0.725, text(L"\ell = 1.2\ \textrm{ m}", plotFont, 12))
savefig("./$(fileName).svg")
