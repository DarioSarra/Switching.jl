function process_raw(filename::String)
    ongoing = MAT.matread(filename)
    MouseID = ongoing["saved_history"]["SavingSection_ratname"][3]
    preday = match(r"\d{6}",filename).match
    println(preday," ",MouseID)
    Day = Date("20"*replace(preday,r"a.mat" => ""),"yyyymmdd")
    Session = MouseID * "_" * string(Day)
    Phase = get(Phase_Calendar,Day,"training")
    Group = string(MouseID[1]) in ["a","d"] ? "Group A" : "Group B"
    Treatment = get_injection(Phase,Group,Day)
    #switching_type = match(r"switching\d{1}",filename).match
    pokes = process_raw(ongoing)
    sort!(pokes,:PokeIn)
    pokes[!,:MouseID] .= MouseID
    pokes[!,:Day] .= Day
    pokes[!,:Phase] .= Phase
    pokes[!,:Group] .= Group
    pokes[!,:Treatment] .= Treatment
    return pokes
end

function process_raw(ongoing::AbstractDict)
    # ongoing = MAT.matread(filename)
    # MouseID = ongoing["saved_history"]["SavingSection_ratname"][3]
    # preday = match(r"\d{6}",filename).match
    # println(preday," ",MouseID)
    # Day = Date("20"*replace(preday,r"a.mat" => ""),"yyyymmdd")
    # switching_type = match(r"switching\d{1}",filename).match
    outcomesR = ongoing["saved_history"]["switching2_RrewList"]
    outcomesL = ongoing["saved_history"]["switching2_LrewList"]
    protocolsR = ongoing["saved_history"]["switching2_current_rightMax"]
    protocolsL = ongoing["saved_history"]["switching2_current_leftMax"]
    trials_vec = ongoing["saved_history"]["ProtocolsSection_parsed_events"]
    poke_count = 0
    df = DataFrame(Poke = Union{Int64,Missing}[], Trial = Int64[],
        PokeIn = Union{Float64,Missing}[],PokeOut = Union{Float64,Missing}[],
        side = Union{String,Missing}[], Reward = Union{Bool,Missing}[],
        ROI_In = Float64[], ROI_Out = Float64[], Protocol = Union{Float64,Missing}[])
    for (idx,t) in enumerate(trials_vec)

        default_in = t["states"]["state_0"][1,2]
        default_out = t["states"]["state_0"][2,1]

        ROI_activity = t["pokes"]["C"]
        if size(ROI_activity,1)  == 0
            ROI_activity_in = default_in
            ROI_activity_out = default_out
        else
            ROI_activity_in = isnan(ROI_activity[1]) ? default_in : ROI_activity[1]
            ROI_activity_out = isnan(ROI_activity[end]) ? default_out : ROI_activity[end]
            # push!(df,[activity_in,activity_out,"ROI",false,idx])
        end

        if length(t["pokes"]["R"]) > 0
            p = t["pokes"]["R"]
            side = "R"
            outcomes = outcomesR[idx]
            protocol = protocolsR[idx]
        elseif length(t["pokes"]["L"]) > 0
            p = t["pokes"]["L"]
            side = "L"
            outcomes = outcomesL[idx]
            protocol = protocolsL[idx]
        else
            p = nothing
        end
        if !isnothing(p)
            for i  = 1:size(p,1)
                poke_count = poke_count + 1
                rew = i>20 ? false : Bool(outcomes[i])
                p[1] = isnan(p[1]) ? default_in : p[1]
                p[end] = isnan(p[end]) ? default_out : p[end]
                push!(df,[poke_count,idx,p[i,1],p[i,2],side,rew,ROI_activity_in,ROI_activity_out,protocol])
            end
        else
            push!(df,[missing,idx,ROI_activity_in,ROI_activity_out,missing,missing,ROI_activity_in,ROI_activity_out,missing])
        end

    end
    # sort!(df,:PokeIn)
    # df[!,:MouseID] .= MouseID
    # df[!,:Day] .= Day
    #test = size(df,1) == length(trials_vec)
    return df
end

function process_pokes(;dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/Datasets/Pharmacology/SwitchingData/rawdata")
    dir, files_list = get_rawdata(dir = dir)

    fulldf = DataFrame(In = Float64[],Out = Float64[],
        event = String[], Reward = Bool[], Trial = Int64[],
        MouseID = String[], Day = Date[])

    for filename in files_list
        println(filename)
        ongoing_file = joinpath(dir,filename)
        df = process_raw(ongoing_file)
        append!(fulldf,df)
    end
    return fulldf
end
