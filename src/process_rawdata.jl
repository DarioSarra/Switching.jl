function process_session(filename::String)
    ongoing = MAT.matread(filename)
    MouseID = match(r"[a,b,c,d]\d{1}",filename).match #ongoing["saved_history"]["SavingSection_ratname"][3]
    preday = match(r"\d{6}",filename).match
    println(preday," ",MouseID)
    Day = Date("20"*replace(preday,r"a.mat" => ""),"yyyymmdd")
    Session = MouseID * "_" * string(Day)
    Phase = get(Phase_Calendar,Day,"training")
    Group = string(MouseID[1]) in ["a","d"] ? "Group A" : "Group B"
    Treatment = get_treatment(Phase,Group,Day) #get_injection(Phase,Group,Day)
    Injection = occursin("Veh",Treatment) ? "Vehicle" : Treatment
    pokes = process_pokes(ongoing)
    sort!(pokes,:PokeIn)
    streaks = process_streaks(pokes)
    for df in (pokes,streaks)
        for (n,v) in zip([:MouseID,:Day,:Phase,:Group,:Treatment, :Injection],[MouseID,Day,Phase,Group,Treatment, Injection])
            df[!,n] .= v
        end
    end
    return pokes, streaks
end

function process_all()
    source = files_dict()
    full_pokes = DataFrame()
    full_streaks = DataFrame()

    for idx in 1:length(source["Files"])
        filepath = get_rawfile(idx)
        ongoing_pokes, ongoing_streaks = process_session(filepath)
        if isempty(full_pokes)
            full_pokes = ongoing_pokes
            full_streaks = ongoing_streaks
        else
            append!(full_pokes,ongoing_pokes)
            append!(full_streaks,ongoing_streaks)
        end
    end
    full_pokes[!,:ExpDay] = exp_calendar(full_pokes)
    full_pokes[!,:ProtocolDay] = exp_calendar(full_pokes,:Phase)
    full_streaks[!,:ExpDay] = exp_calendar(full_streaks)
    full_streaks[!,:ProtocolDay] = exp_calendar(full_streaks,:Phase)
    return full_pokes,full_streaks
end
