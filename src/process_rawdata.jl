function process_session(filename::String)
    ongoing = MAT.matread(filename)
    MouseID = match(r"[a,b,c,d,p]{1,2}\d{1,2}",filename).match #ongoing["saved_history"]["SavingSection_ratname"][3]
    preday = match(r"\d{6}",filename).match
    println(preday," ",MouseID)
    Day = Date("20"*replace(preday,r"a.mat" => ""),"yyyymmdd")
    Session = MouseID * "_" * string(Day)
    Phase = get(Phase_Calendar,Day,"training")
    if string(MouseID[1]) == "p"
        Group = string(MouseID[end]) in ["1","3","5","7","9"] ? "Group C" : "Group D"
    else
        Group = string(MouseID[1]) in ["a","d"] ? "Group A" : "Group B"
    end
    Treatment = get_treatment(Phase,Group,Day) #get_injection(Phase,Group,Day)
    Injection = occursin("Veh",Treatment) ? "Vehicle" : Treatment
    ExpType = occursin("pc",MouseID) ? "Optogenetic" : "Pharmacology"
    pokes = process_pokes(ongoing)
    sort!(pokes,:PokeIn)
    streaks = process_streaks(pokes)
    for df in (pokes,streaks)
        for (n,v) in zip([:MouseID,:Day,:Phase,:Group,:Treatment, :Injection, :ExpType],[MouseID,Day,Phase,Group,Treatment, Injection, ExpType])
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
        println(filepath)
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
