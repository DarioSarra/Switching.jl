"""
`process_streaks`
"""

function process_streaks(df::DataFrames.AbstractDataFrame)
    # dayly_vars_list = [:MouseID, :Gen, :Drug, :Day, :Daily_Session, :Box, :Stim_Day, :Condition, :ExpDay, :Area, :Session];
    # booleans=[:Reward,:Stim,:Wall,:Correct,:Stim_Day]#columns to convert to Bool
    # for x in booleans
    #     df[!,x] = eltype(df[!,x]) == Bool ? df[!,x] : occursin.("true",df[!,x],)
    # end
    streak_table = by(df, :Trial) do dd
        dt = DataFrame(
        Num_pokes = size(dd,1),
        Num_Rewards = length(findall(skipmissing(dd[!,:Reward]))),
        Start_Reward = dd[1,:Reward],
        Last_Reward = findlast(dd[!,:Reward]).== nothing ? 0 : findlast(dd[!,:Reward]),
        Prev_Reward = findlast(dd[!,:Reward]).== nothing ? 0 : findprev(dd[!,:Reward], findlast(dd[!,:Reward])-1),
        Poking_duration = (dd[end,:PokeOut]-dd[1,:PokeIn]),
        Trial_duration = (dd[end,:ROI_Out]-dd[1,:ROI_In]),
        Start = (dd[1,:PokeIn]),
        Stop = (dd[end,:PokeOut]),
        Pre_Interpoke = nrow(dd) > 1 ? maximum(skipmissing(dd[!,:Pre_Interpoke])) : missing,
        Post_Interpoke = nrow(dd) > 1 ? maximum(skipmissing(dd[!,:Post_Interpoke])) : missing,
        PokeSequence = [SVector{nrow(dd),Union{Bool,Missing}}(dd[!,:Reward])],
        #Stim = dd[1,:Stim],
        #StimFreq = dd[1,:StimFreq],
        #Wall = dd[1,:Wall],
        Protocol = dd[1,:Protocol],
        #Correct_start = dd[1,:Correct],
        #Correct_leave = !dd[end,:Correct],
        #Block = dd[1,:Block],
        #Streak_within_Block = dd[1,:Streak_within_Block],
        Side = dd[1,:Side],
        ReverseTrial = dd[1,:ReverseTrial]
        )
        # for s in dayly_vars_list
        #     if s in names(df)
        #         dt[!,s] .= df[1, s]
        #     end
        # end
        return dt
    end
    streak_table[!,:Prev_Reward] = [x .== nothing ? 0 : x for x in streak_table[:,:Prev_Reward]]
    streak_table[!,:AfterLast] = streak_table[!,:Num_pokes] .- streak_table[!,:Last_Reward];
    streak_table[!,:BeforeLast] = streak_table[!,:Last_Reward] .- streak_table[!,:Prev_Reward].-1;
    prov = lead(streak_table[!,:Start],default = 0.0) .- streak_table[!,:Stop];
    streak_table[!,:Travel_to] = [x.< 0 ? 0 : x for x in prov]
    return streak_table
end
