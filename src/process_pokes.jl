function process_pokes(ongoing::AbstractDict)
    curr_data = adjust_matfile(ongoing)
    process_pokes(curr_data)
end

function process_pokes(curr_data::AbstractDataFrame)
    curr_data[!,:Poke_within_Trial] .= 0
    curr_data[!,:Poke_within_Trial] = Vector{Union{Float64,Missing}}(undef,size(curr_data,1))
    curr_data[!,:Pre_Interpoke] = Vector{Union{Float64,Missing}}(undef,size(curr_data,1))
    curr_data[!,:Post_Interpoke] = Vector{Union{Float64,Missing}}(undef,size(curr_data,1))
    # curr_data[!,:Poke_Hierarchy] .= Vector{Union{Int64,Missing}}(undef,size(curr_data,1))
    curr_data[!,:LastPoke] .= false
    by(curr_data,:Trial) do dd
        dd[:,:Poke_within_Trial] = collect(1:nrow(dd))
        dd[:,:Pre_Interpoke] =  dd[!,:PokeIn] .-lag(dd[!,:PokeOut],default = missing)
        dd[:,:Post_Interpoke] = lead(dd[!,:PokeIn],default = missing).- dd[!,:PokeOut]
        #dd[:,:Poke_Hierarchy] = ismissing(dd[1,:Reward]) ? missing : get_hierarchy(dd[!,:Reward])
        dd[end,:LastPoke] = true
    end
    hierarchy = by(curr_data,:Trial) do dd
        (Poke_Hierarchy = ismissing(dd[1,:Reward]) ? [missing] : Switching.get_hierarchy(dd.Reward),)
    end
    curr_data = join(curr_data,hierarchy, on = :Trial; kind = :left, makeunique = true)
    # curr_data[!,:Block] = count_sequence(curr_data[!,:Wall])
    # curr_data[!,:Trial_within_Block] .= 0
    # by(curr_data,:Block) do dd
    #     dd[:,:Trial_within_Block] = count_sequence(dd[!,:Side])
    # end
    # curr_data[!,:SideHigh] = [x ? "L" : "R" for x in curr_data[!,:SideHigh]]
    curr_data[!,:ReverseTrial] .= reverse(curr_data[:,:Trial])
    curr_data[!,:Correct] = [ismissing(x) ? false : true for x in curr_data[!,:Poke]]
    return curr_data
end

function adjust_matfile(ongoing::AbstractDict)
    # switching_type = match(r"switching\d{1}",filename).match
    outcomesR = ongoing["saved_history"]["switching2_RrewList"]
    outcomesL = ongoing["saved_history"]["switching2_LrewList"]
    protocolsR = ongoing["saved_history"]["switching2_current_rightMax"]
    protocolsL = ongoing["saved_history"]["switching2_current_leftMax"]
    trials_vec = ongoing["saved_history"]["ProtocolsSection_parsed_events"]
    poke_count = 0
    df = DataFrame(Poke = Union{Int64,Missing}[], Trial = Int64[],
        PokeIn = Union{Float64,Missing}[],PokeOut = Union{Float64,Missing}[],
        Side = Union{String,Missing}[], Reward = Union{Bool,Missing}[],
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
    #test = size(df,1) == length(trials_vec)
    return df
end
