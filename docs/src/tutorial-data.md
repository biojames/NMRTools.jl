# Working with NMR data

NMR measurements are arrays of data, with additional numerical data associated with each dimension, or axis. Within NMRTools, these data are stored as [`NMRData`](@ref) structures, which provides a convenient way to encapsulate both the data, axis information, and additional metadata providing information on acquisition or processing.


## Loading NMR data

NMR data are loaded using the [`loadnmr`](@ref) function. This can handle processed Bruker experiments, or NMRPipe-format data.

```@example 1
using NMRTools

# by default, NMRTools will load bruker processed data from proc 1
spec2d = loadnmr("../../exampledata/2D_HN/1")

# load a different processed spectrum
spec1d = loadnmr("../../exampledata/2D_HN/1/pdata/101")

# load data from NMRPipe format, using a template
spec3d = loadnmr("../../exampledata/pseudo3D_HN_R2/1/ft/test%03d.ft2")
nothing # hide
```

!!! tip
    `loadnmr` will attempt to locate and parse acquisition metadata, such as acqus files. If the spectrum file is located elsewhere (for example, if you are loading a file that was processed with NMRPipe), then you can specify the path to the experiment folder using the `experimentfolder` keyword argument.

When spectra are loaded, a simple algorithm runs to estimate the noise level, which is often used for subsequent plotting commands.

## Manipulating spectrum data

[`NMRData`](@ref) structures encapsulate a standard Julia array. This can be accessed using the [`data`](@ref) command. However, through the magic of multiple dispatch, most operations will work transparently on NMRData variables as if they are regular arrays, with the added benefit that axis information and metadata are preserved. Data can be sliced and accessed like a regular array using the usual square brackets:
```@example 1
spec1d[100:105]
spec2d[3:4, 10:14]
nothing # hide
```

However, more conveniently, value-based selectors can also be used to locate data using chemical shifts. Three selectors are defined:
- `At(x)`: select data precisely at the specified value
- `Near(x)`: select data at the nearest matching position
- `x .. y`: select the range of data between `x` and `y` (closed interval)

For example:
```@example 1
spec1d[8.2 .. 8.3] # select between 8.2 and 8.3 ppm
spec2d[Near(8.25), 123 .. 124] # select near 8.25 ppm in the first dimension
                               # and between 123 and 124 ppm in the second dimension
nothing # hide
```

When data are sliced, new NMRData structures are created and their axes are updated to match the new data size.

!!! warning
    When `NMRData` structures are sliced, copied, or otherwise modified, they inherit the same dictionary of metadata as the original variable. This means that any changes to metadata will affect both variables. To resolve this, make a `deepcopy` of the variable. Note also that any acquisition metadata might not reflect the correct shape of the data any more.


## Accessing axis data

Information on data dimensions is stored in `NMRDimension` structures. These can be accessed with the `dims` function:
```@example 1
# get the first dimension of this two-dimensional experiment
dims(spec2d, 1)
```

`NMRDimension`s can be treated like vectors (one-dimensional arrays) for most purposes, including indexing and slicing. Value-based selectors can also be used, as for spectrum data. Like spectrum data, the underlying numerical data can be accessed if needed using the [`data`](@ref) function.

A heirarchy of types are defined for NMR dimensions, reflecting the variety of different experiments:
- `NMRDimension`
    - `FrequencyDimension`: with specific types `F1Dim` to `F4Dim`
    - `NonFrequencyDimension`
        - `TimeDimension`:
            - `TrelaxDim`: for relaxation times
            - `TkinDim`: for kinetic evolution times
            - `T1Dim` to `T4Dim`: for general frequency evolution periods
        - `GradientDimension`: for e.g. diffusion measurements, with specific types `G1Dim` to `G4Dim`
        - `UnknownDimension`: with specific types `X1Dim` to `X4Dim`

## Accessing metadata

[`NMRData`](@ref) objects contain comprehensive metadata on processing and acquisition parameters that are populated automatically upon loading a spectrum. Entries are divided into *spectrum* metadata - associated with the experiment in general - and *axis* metadata, that are associated with a particular dimension of the data.

Metadata entries are labelled by symbols such as `:ns` or `:pulseprogram`. Entries can be accessed using the `metadata` function, or directly as a dictionary-style lookup:
```@repl 1
spec2d = loadnmr("../../exampledata/2D_HN/1"); # hide
metadata(spec2d, :ns)
spec2d[:title]
```

Acquisition parameters from Bruker acqus files are also parsed when loading data, and can be accessed using the [`acqus`](@ref) function. Parameters are specified either as lower-case symbols or strings (not case-sensitive). An index can be specified for arrayed parameters such as pulse lengths or delays.
```@repl 1
acqus(spec2d, "TE")
acqus(spec2d, :p, 1)
```

Axis metadata can be accessed by providing an additional label, which can either be numerical or the appropriate `NMRDimension` type, such as `F1Dim` etc:
```@repl 1
metadata(spec2d, F2Dim, :label)
spec2d[2, :bf]
spec2d[F2Dim, :window]
```



