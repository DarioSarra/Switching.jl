function get_rawdata(;dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/Datasets/Pharmacology/SwitchingData")
    files = readdir(dir)
    filter!(t-> occursin("data_@switching2",t),files)
    return (dir,files)
end

function process_pokes(;dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/Datasets/Pharmacology/SwitchingData")
    dir, files_list = get_rawdata(dir = dir)

    fulldf = DataFrame(In = Float64[],Out = Float64[],
        event = String[], Reward = Bool[], Trial = Int64[],
        MouseID = String[], Day = Date[])

    for filename in files_list
        println(filename)
        ongoing_file = joinpath(dir,filename)
        ongoing = MAT.matread(ongoing_file)
        MouseID = ongoing["saved_history"]["SavingSection_ratname"][3]
        preday = match(r"\d{6}",filename).match
        println(preday)
        Day = Date("20"*replace(preday,r"a.mat" => ""),"yyyymmdd")

        switching_type = match(r"switching\d{1}",filename).match
        outcomesR = ongoing["saved_history"][switching_type * "_RrewList"]
        outcomesL = ongoing["saved_history"][switching_type * "_LrewList"]
        trials_vec = ongoing["saved_history"]["ProtocolsSection_parsed_events"]
        df = DataFrame(In = Float64[],Out = Float64[], event = String[], Reward = Bool[], Trial = Int64[])
        for (idx,t) in enumerate(trials_vec)
            default_in = t["states"]["state_0"][1,2]
            default_out = t["states"]["state_0"][2,1]
            if length(t["pokes"]["R"]) > 0
                p = t["pokes"]["R"]
                side = "R"
                outcomes = outcomesR[idx]
            elseif length(t["pokes"]["L"]) > 0
                p = t["pokes"]["L"]
                side = "L"
                outcomes = outcomesL[idx]
            else
                println("weird lack of pokes trial $idx session $filename")
                continue
            end
            for i  = 1:size(p,1)
                rew = i>20 ? false : Bool(outcomes[i])
                push!(df,[p[i,1],p[i,2],side,rew,idx])
            end
            activity = t["pokes"]["C"]
            for i = 1:size(activity,1)
                activity_in = isnan(activity[1]) ? default_in : activity[1]
                activity_out = isnan(activity[2]) ? default_out : activity[2]
                push!(df,[activity_in,activity_out,"C",false,idx])
            end
        end
        sort!(df,:In)
        df[!,:MouseID] .= MouseID
        df[!,:Day] .= Day
        append!(fulldf,df)
    end
    return fulldf
end
