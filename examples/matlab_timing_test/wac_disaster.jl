using BenchmarkTools, RiskAdjustedLinearizations, MATLAB
include(joinpath(dirname(@__FILE__), "..", "wachter_disaster_risk", "wachter.jl"))

# Settings: what do you want to do?
autodiff = false

# Set up
autodiff_method = autodiff ? :forward : :central
m_wachter = WachterDisasterRisk()
m = inplace_wachter_disaster_risk(m_wachter)
z0 = copy(m.z)
y0 = copy(m.y)
Ψ0 = copy(m.Ψ)

# Use deterministic steady state as guesses
solve!(m, z0, y0; algorithm = :deterministic, autodiff = autodiff_method, verbose = :none)
zdet = copy(m.z)
ydet = copy(m.y)
Ψdet = copy(m.Ψ)

println("Relaxation algorithm in MATLAB")
mat"""
genaffine_wac_disaster_relaxation;
"""

println("Relaxation algorithm in Julia")
@btime begin # called the "iterative" method in the original paper
    solve!(m, zdet, ydet, Ψdet; algorithm = :relaxation, autodiff = autodiff_method, verbose = :none)
end

println("Relaxation algorithm with Anderson acceleration")
@btime begin # called the "iterative" method in the original paper
    solve!(m, zdet, ydet, Ψdet; algorithm = :relaxation, use_anderson = true, m = 3, autodiff = autodiff_method, verbose = :none)
end

println("Homotopy algorithm in MATLAB")
mat"""
genaffine_wac_disaster_homotopy;
"""

println("Homotopy algorithm in Julia")
@btime begin # called the "continuation" method in the original paper, but is called homotopy in the original code
    solve!(m, zdet, ydet, Ψdet; algorithm = :homotopy, autodiff = autodiff_method, verbose = :none)
end
