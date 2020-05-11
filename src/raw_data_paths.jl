#const ongoing_dir = "/Volumes/GoogleDrive/My Drive"
const ongoing_dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/"
const Directory = joinpath(ongoing_dir,"Flipping/Datasets/Pharmacology/SwitchingData/rawdata")
const saving_dir = joinpath(ongoing_dir,"Flipping/Datasets/Pharmacology/SwitchingData/Results")

function files_dict(;dir = Directory)
    files = readdir(dir)
    filter!(t-> occursin("data_@switching2",t),files)
    return Dict("Dir" => dir,"Files" => files)
end

const Files_Dict = files_dict()

function get_rawfile(idx)
    dir = Files_Dict["Dir"]
    file = Files_Dict["Files"][idx]
    joinpath(dir,file)
end

function read_rawfile(file::String)
    MAT.matread(file)
end

function read_rawfile(idx::Int64)
    file_path = get_rawfile(idx)
    MAT.matread(file_path)
end
