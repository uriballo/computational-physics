# TISE.jl
Numerical Solver for the 1D Time-Independent-Schrödinger-Equation.

## Usage
```julia
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
```
## Examples
### `julia TISE.jl -p=gwell -s -S=gwell`
![gaussian well example](/assets/gwell.png)
### `julia TISE.jl -p=esin -s -S=esin`
![extended sine example](/assets/esin.png)
### `julia TISE.jl -p=har -s -S=harmonic`
![harmonic potential example](/assets/harmonic.png)
### `julia TISE.jl -p=gwall -s -S=gausswall`
![gaussian wall example](/assets/gausswall.png)