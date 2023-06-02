# default constructor: dictionary of Symbol => Any #################################################

# struct NMRMetadata <: DimensionalData.Dimensions.LookupArrays.AbstractMetadata
# Metadata() = Metadata(Dict{Symbol,Any}())


# getters ##########################################################################################

# metadata accessor functions
metadata(A::AbstractNMRData, key::Symbol) = get(metadata(A), key, nothing)
metadata(A::AbstractNMRData, dim, key::Symbol) = get(metadata(A, dim), key, nothing)
metadata(d::NMRDimension, key::Symbol) = get(metadata(d), key, nothing)
Base.getindex(A::AbstractNMRData, key::Symbol) = metadata(A, key)
Base.getindex(A::AbstractNMRData, dim, key::Symbol) = metadata(A, dim, key)
Base.getindex(d::NMRDimension, key::Symbol) = metadata(d, key)
Base.setindex!(A::AbstractNMRData, v, key::Symbol) = setindex!(metadata(A), v, key)  #(A[key] = v  =>  metadata(A)[key] = v)
Base.setindex!(A::AbstractNMRData, v, dim, key::Symbol) = setindex!(metadata(A,dim), v, key)  #(A[dim, key] = v  =>  metadata(A, dim)[key] = v)
Base.setindex!(d::NMRDimension, v, key::Symbol) = setindex!(metadata(d), v, key)  #(d[key] = v  =>  metadata(d)[key] = v)


function units end
units(A::AbstractNMRData) = metadata(A, :units)
units(A::AbstractNMRData, dim) = metadata(A, dim, :units)
units(d::NMRDimension) = get(metadata(d), :units, nothing)

function label end
label(A::AbstractNMRData) = metadata(A, :label)
label(A::AbstractNMRData, dim) = metadata(A, dim, :label)
label(d::NMRDimension) = get(metadata(d), :label, nothing)
label!(A::AbstractNMRData, labeltext::AbstractString) = (A[:label] = labeltext)
label!(A::AbstractNMRData, dim, labeltext::AbstractString) = (A[dim, :label] = labeltext)
label!(d::NMRDimension, labeltext::AbstractString) = (d[:label] = labeltext)

# acqus accessor functions
acqus(A::AbstractNMRData) = metadata(A, :acqus)
acqus(A::AbstractNMRData, key::Symbol) = ismissing(acqus(A)) ? missing : get(acqus(A), key, missing)
acqus(A::AbstractNMRData, key::String) = acqus(A, Symbol(lowercase(key)))
acqus(A::AbstractNMRData, key, index) = acqus(A, key)[index]

# # Metadata for NMRData #############################################################################

function defaultmetadata(::Type{<:AbstractNMRData})
    defaults = Dict{Symbol,Any}(:title => "",
                                :label => "",
                                :filename => nothing,
                                :format => nothing,
                                :lastserialised => nothing,
                                :pulseprogram => nothing,
                                :ns => nothing,
                                :rg => nothing,
                                :noise => nothing)

    return Metadata{NMRData}(defaults)
end


# # Metadata for Dimensions ##########################################################################

function defaultmetadata(T::Type{<:NMRDimension})
    defaults = Dict{Symbol,Any}(:label => "",
                                :units => nothing)
    return Metadata{T}(defaults)
end

function defaultmetadata(::Type{<:FrequencyDimension})
    defaults = Dict{Symbol,Any}(:label => "",
                                :coherence => nothing,
                                :bf => nothing,
                                :offsethz => nothing,
                                :offsetppm => nothing,
                                :swhz => nothing,
                                :swppm => nothing,
                                :td => nothing,
                                :tdzf => nothing,
                                :npoints => nothing,
                                :region => nothing,
                                :units => nothing,
                                :window => nothing,
                                :mcindex => nothing)
    return Metadata{FrequencyDimension}(defaults)
end

function defaultmetadata(::Type{<:TimeDimension})
    defaults = Dict{Symbol,Any}(:label => "",
                                :units => nothing,
                                :window => nothing,
                                :mcindex => nothing)
    return Metadata{TimeDimension}(defaults)
end

function defaultmetadata(::Type{<:TrelaxDim})
    defaults = Dict{Symbol,Any}(:label => "Relaxation time",
                                :units => nothing)
    return Metadata{TrelaxDim}(defaults)
end

function defaultmetadata(::Type{<:TkinDim})
    defaults = Dict{Symbol,Any}(:label => "Time elapsed",
                                :units => nothing)
    return Metadata{TkinDim}(defaults)
end

function defaultmetadata(::Type{<:UnknownDimension})
    defaults = Dict{Symbol,Any}(:label => "",
                                :units => nothing)
    return Metadata{UnknownDimension}(defaults)
end


# Metadata entry definitions and help ##############################################################
function metadatahelp(A::Type{T}) where {T <: Union{NMRData,NMRDimension}}
    m = Metadata{A}()
    return Dict(map(kv -> kv[1] => metadatahelp(kv[1]), m))
end

function metadatahelp(key::Symbol)
    return get(metadatahelp(), key, "No information is available on this entry.")
end

function metadatahelp()
    d = Dict(:title => "Experiment title (may be multi-line)",
             :label => "Short experiment or axis description",
             :filename => "Original filename or template",
             :format => ":NMRPipe or :pdata",
             :pulseprogram => "Pulse program (PULPROG) from acqus file",
             :ns => "Number of scans",
             :rg => "Receiver gain",
             :noise => "RMS noise level",
             :units => "Axis units",
             :window => "Window function",
             :mcindex => "Index of imaginary component associated with axis (for multicomplex data)")
    return d
end