# This script checks sparse arrays can be used as caches for Γ₅, Γ₆, Λ_sss, and Σ_sss
using BenchmarkTools, RiskAdjustedLinearizations, Test
include(joinpath(dirname(@__FILE__), "..", "..", "examples", "rbc_cc", "rbc_cc.jl"))
include(joinpath(dirname(@__FILE__), "..", "..", "examples", "crw", "crw.jl"))

@testset "Sparse caching for Γ₅, Γ₆, Λ, and Σ (RBC-CC)" begin
    m_rbc_cc = RBCCampbellCochraneHabits()
    m = rbc_cc(m_rbc_cc, 0; sparse_arrays = true)

    @test issparse(m[:Γ₅])
    @test issparse(m[:Γ₆])
    @test issparse(m[:Λ_sss])
    @test issparse(m[:Σ_sss])

    # Solve!
    solve!(m; algorithm = :relaxation, verbose = :none)

    sssout = JLD2.jldopen(joinpath(dirname(@__FILE__), "..", "reference", "rbccc_sss_iterative_output.jld2"), "r")

    @test isapprox(sssout["z_rss"], m.z, atol=1e-4)
    @test isapprox(sssout["y_rss"], m.y, atol=1e-4)
    @test isapprox(sssout["Psi_rss"], m.Ψ, atol=1e-4)
end

@testset "Sparse caching for Γ₅, Γ₆, Λ, and Σ with jump-dependent shock matrices (CRW)" begin
m_crw = CoeurdacierReyWinant()
m = crw(m_crw; sparse_arrays = true)

solve!(m; algorithm = :homotopy, step = .5, verbose = :none)
sssout = JLD2.jldopen(joinpath(dirname(@__FILE__), "..", "reference", "crw_sss.jld2"), "r")

    @test isapprox(sssout["z_rss"], m.z, atol=1e-4)
    @test isapprox(sssout["y_rss"], m.y, atol=1e-4)
    @test isapprox(sssout["Psi_rss"], m.Ψ, atol=1e-4)
end
