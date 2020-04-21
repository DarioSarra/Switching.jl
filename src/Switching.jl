module Switching

using MAT
using DataFrames
using Dates
using OrderedCollections
using ShiftedArrays
using StaticArrays


include("raw_data_paths.jl")
include("utilities.jl")
include("process_pokes.jl")
include("process_streaks.jl")
include("process_rawdata.jl")
#include("process_alldata.jl")
include("drug_calendar.jl")

export matread, DataFrame, by
export get_rawdata, get_rawfile, read_rawfile
export process_pokes, process_session
export get_alldata, read_alldata_format, process_alldata

end # module
