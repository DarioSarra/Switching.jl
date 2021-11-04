function process_pokes(ongoing::AbstractDict)
    curr_data = adjust_matfile(ongoing)
    dropmissing!(curr_data, :Trial)
    process_pokes(curr_data)
end

function process_pokes(curr_data::AbstractDataFrame)
    curr_data[!,:Poke_within_Trial] = Vector{Union{Float64,Missing}}(undef,size(curr_data,1))
    curr_data[!,:Pre_Interpoke] = Vector{Union{Float64,Missing}}(undef,size(curr_data,1))
    curr_data[!,:Post_Interpoke] = Vector{Union{Float64,Missing}}(undef,size(curr_data,1))
    curr_data[!,:LastPoke] .= false
    combine(groupby(curr_data,:Trial)) do dd
        dd[:,:Poke_within_Trial] = collect(1:nrow(dd))
        dd[:,:Pre_Interpoke] =  dd[!,:PokeIn] .-lag(dd[!,:PokeOut],default = missing)
        dd[:,:Post_Interpoke] = lead(dd[!,:PokeIn],default = missing).- dd[!,:PokeOut]
        dd[end,:LastPoke] = true
    end
    curr_data.Poke_Hierarchy = Vector{Union{Float64,Missing}}(undef,nrow(curr_data))
    combine(groupby(curr_data,:Trial)) do dd
         dd[:,:Poke_Hierarchy] = ismissing(dd[1,:Reward]) ? [missing] : Switching.get_hierarchy(dd.Reward)
    end
    curr_data[!,:ReverseTrial] .= reverse(curr_data[:,:Trial])
    curr_data[!,:Correct] = [ismissing(x) ? false : true for x in curr_data[!,:Poke]]
    curr_data[!,:PokeDuration] = curr_data.PokeOut - curr_data.PokeIn
    curr_data[!,:Stim_Day] .= length(union(curr_data.Stim)) > 1
    # filter!(r -> r.PokeDuration > 0.10,curr_data)
    return curr_data
end

function adjust_matfile(ongoing::AbstractDict)
    # switching_type = match(r"switching\d{1}",filename).match
    # extract outcomes and protocols of both sides in 2 simpler variable to be later pointed
    outcomesR = ongoing["saved_history"]["switching2_RrewList"]
    outcomesL = ongoing["saved_history"]["switching2_LrewList"]
    protocolsR = ongoing["saved_history"]["switching2_current_rightMax"]
    protocolsL = ongoing["saved_history"]["switching2_current_leftMax"]
    Stimulation = ongoing["saved_history"]["LaserSection_currentStim"]
    #this is what contains the series of pokes
    trials_vec = ongoing["saved_history"]["ProtocolsSection_parsed_events"]
    poke_count = 0
    falsetrial_count = 0
    #create an empty dataframe wher to push single poke rows info
    df = DataFrame(Poke = Union{Int64,Missing}[], Trial = Union{Int64,Missing}[],
        PokeIn = Union{Float64,Missing}[], PokeOut = Union{Float64,Missing}[],
        Side = Union{String,Missing}[], Reward = Union{Bool,Missing}[],
        ROI_In = Float64[], ROI_Out = Float64[], Protocol = Union{String,Missing}[],
        Stim = Union{Bool,Missing}[])

    #loops over the trials and index them
    for (idx,t) in enumerate(trials_vec)
        # retrieve safe alternative for starting and ending time of pokes when value is missing
        default_in = t["states"]["state_0"][1,2]
        default_out = t["states"]["state_0"][2,1]
        # retrieve the entry and exit time to the ROI
        ROI_activity = t["pokes"]["C"]
        if size(ROI_activity,1)  == 0
            ROI_activity_in = default_in
            ROI_activity_out = default_out
        else
            ROI_activity_in = isnan(ROI_activity[1]) ? default_in : ROI_activity[1]
            ROI_activity_out = isnan(ROI_activity[end]) ? default_out : ROI_activity[end]
        end
        # define in which side was the trial, if no poke was made returns nothing
        if length(t["pokes"]["R"]) > 0
            p = t["pokes"]["R"]
            side = "R"
            outcomes = outcomesR[idx]
            protocol = string(protocolsR[idx])
            stim = Bool(Stimulation[idx])
        elseif length(t["pokes"]["L"]) > 0
            p = t["pokes"]["L"]
            side = "L"
            outcomes = outcomesL[idx]
            protocol = string(protocolsL[idx])
            stim = Bool(Stimulation[idx])
        else
            p = nothing
        end
        # if poke isn't nothing loops over the pokes to push all the info in 1 row
        if !isnothing(p)
            for i  = 1:size(p,1)
                poke_count += 1
                rew = i>20 ? false : Bool(outcomes[i])
                p[1] = isnan(p[1]) ? default_in : p[1]
                p[end] = isnan(p[end]) ? default_out : p[end]
                push!(df,[poke_count,idx-falsetrial_count,p[i,1],p[i,2],side,rew,ROI_activity_in,ROI_activity_out,protocol,stim])
            end
        else
            falsetrial_count += 1
            push!(df,[missing,missing,missing,missing,missing,missing,ROI_activity_in,ROI_activity_out,missing,missing])
        end

    end
    #test = size(df,1) == length(trials_vec)
    return df
end
