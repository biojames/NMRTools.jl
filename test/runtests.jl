using NMRTools
using Test
using SafeTestsets

@safetestset "NMRBase" begin
    include("nmrbase_test.jl")
end

@safetestset "NMRIO" begin
    include("nmrio_test.jl")
end

@safetestset "PlotsExt" begin
    include("plotsext_test.jl")
end
