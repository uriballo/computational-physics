using Plots
using LaTeXStrings

struct TISE 
    # Potential
    V::Function

    # Discretization
    N::Int
    dn = 1.0 / N
    x = range(0, 1, length=N)
end

struct Potential
    name::String
    V::Function
end