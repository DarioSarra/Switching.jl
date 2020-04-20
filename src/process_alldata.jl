function read_alldata_format(ongoing::AbstractDict)
    df = DataFrame(Trial = Int64[], Poking_dur = Float64[], Trial_dur = Float64[],
                ROI_In = Float64[], ROI_Out = Float64[],
                Poke_In = Float64[], Poke_Out = Float64[],
                Reward = Union{Bool,Missing}[], Trial_type = Float64[],
                Side = String[],
                Correct = Bool[], MouseID = String[],
                Drug = String[], ExpDay = Int64[])

    for (idx,PDur) in enumerate(ongoing["all_pokes_dur"])
        Trial = idx
        Poking_dur = PDur
        Trial_dur = ongoing["trial_dur"][idx]
        ROI_In = ongoing["ROI_in"][idx]
        ROI_Out = ongoing["ROI_out"][idx]
        Trial_type = ongoing["ttype"][idx]
        Side = string(uppercase(ongoing["curr_side"][idx]))
        preMouseID = ongoing["name"][idx]
        MouseID = match(r"[abcd]\d{1}",preMouseID).match
        Drug = ongoing["gen"][idx]
        ExpDay = Int64(ongoing["day"][idx])
        Pokes = ongoing["pokes"][idx]
        Rewards = ongoing["rew_vec"][idx]
        for i in 1:size(Pokes,1)
            Poke_In = Pokes[i,1]
            Poke_Out = Pokes[i,2]
            if i > 40
                Rew = false
            else
                Rew = Rewards[i]
                Correct = true
                if isnan(Rew)
                    Rew = missing
                    Correct = false
                end
            end
            push!(df,[Trial, Poking_dur, Trial_dur,
                        ROI_In, ROI_Out,
                        Poke_In, Poke_Out,
                        Rew, Trial_type,
                        Side,
                        Correct, MouseID,
                        Drug, ExpDay])

        end
    end

    df.Session = [join([r.MouseID,r.Drug,r.ExpDay],"_") for r in eachrow(df)]
    return df

end

function read_alldata_format(file::String)
    ongoing = matread(file)["trials"]
    read_alldata_format(ongoing)
end

function process_alldata(files::AbstractVector{String})
    full_pokes = DataFrame()
    for f in files
        pokes = process_pokes_alldata(f)
        if isempty(full_pokes)
            full_pokes = pokes
        else
            append!(full_pokes,pokes; cols = :setequal)
        end
    end
    full_pokes
end

function process_alldata(;switching_path = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/Datasets/Pharmacology/SwitchingData",
                        to_analyze = "all_data_format")
    paths_list = get_alldata(switching_path, to_analyze)
    process_alldata(paths_list)
end

function get_alldata(switching_path, to_analyze)
    folder = joinpath(switching_path, to_analyze)
    files_list = readdir(folder)
    paths_list = joinpath.(folder,files_list)
end
