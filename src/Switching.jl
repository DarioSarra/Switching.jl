module Switching

using MAT
using DataFrames
using Dates


include("raw_data_paths.jl")
include("process_rawdata.jl")
include("process_alldata.jl")

export matread, DataFrame, by
export get_rawdata, get_rawfile, read_rawfile
export process_raw, process_pokes
export get_alldata, read_alldata_format, process_alldata

end # module
