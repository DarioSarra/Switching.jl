function process_session(filename::String)
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
    pokes = process_pokes(ongoing)
    sort!(pokes,:PokeIn)
    streaks = process_streaks(pokes)

    for df in (pokes,streaks)
        for (n,v) in zip([:MouseID,:Day,:Phase,:Group,:Treatment],[MouseID,Day,Phase,Group,Treatment])
            df[!,n] .= v
        end
    end
    return pokes, streaks
end

function process_all(;dir = "/home/beatriz/mainen.flipping.5ht@gmail.com/Flipping/Datasets/Pharmacology/SwitchingData/rawdata")
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
