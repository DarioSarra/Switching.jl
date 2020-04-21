const drugs = ["Citalopram","Methysergide","Altanserin","Way_100135","SB242084"]

const Cit_per = Date(2016,03,14):Day(1):Date(2016,03,18)
const Meth_per = Date(2016,03,21):Day(1):Date(2016,03,25)
const Alt_per = Date(2016,03,28):Day(1):Date(2016,04,01)
const WAY_per = Date(2016,04,04):Day(1):Date(2016,04,08)
const SB_per = Date(2016,05,23):Day(1):Date(2016,05,27)

const Phase_calendar = OrderedDict()
for (d,p) in zip(drugs,[Cit_per,Meth_per,Alt_per,WAY_per,SB_per])
    Phase_calendar[d] = p
end

const Phase_Calendar = OrderedDict()
for (dic,drug) in zip([Cit_per,Meth_per,Alt_per,WAY_per,SB_per],drugs)
    for x in dic
        Phase_Calendar[x] = drug
    end
end
###

const Drug_assignment = OrderedDict()

for d in drugs
    Drug_assignment[d] = OrderedDict()
end
for d in drugs
    for g in ["Group A", "Group B"]
        Drug_assignment[d][g] = OrderedDict()
    end
end

Drug_assignment["Citalopram"]["Group A"] = ["none","PreVeh","Cit","PostVeh","sal"]
Drug_assignment["Citalopram"]["Group B"] = ["none","sal","PreVeh","Cit","PostVeh"]
Drug_assignment["Citalopram"]["Days"] = Cit_per
Drug_assignment["Methysergide"]["Group A"] = ["none","PreVeh","Met","PostVeh","sal"]
Drug_assignment["Methysergide"]["Group B"] = ["none","sal","PreVeh","Met","PostVeh"]
Drug_assignment["Methysergide"]["Days"] = Meth_per
Drug_assignment["Altanserin"]["Group A"] = ["none","PreVeh","Alt","PostVeh","sal"]
Drug_assignment["Altanserin"]["Group B"] = ["none","sal","PreVeh","Alt","PostVeh"]
Drug_assignment["Altanserin"]["Days"] = Alt_per
Drug_assignment["Way_100135"]["Group A"] = ["none","PreVeh","WAY","PostVeh","sal"]
Drug_assignment["Way_100135"]["Group B"] = ["none","sal","PreVeh","WAY","PostVeh"]
Drug_assignment["Way_100135"]["Days"] = WAY_per
Drug_assignment["SB242084"]["Group A"] = ["none","sal","PreVeh","SB","PostVeh"]
Drug_assignment["SB242084"]["Group B"] = ["none","PreVeh","SB","PostVeh","sal"]
Drug_assignment["SB242084"]["Days"] = SB_per


##
const Procedure =  DataFrame(Phase = String[], Group = String[], Day = Date[],
    Treatment = String[],PhaseDay = Int64[])

for d in drugs
    for (i,day) in enumerate(Drug_assignment[d]["Days"])
        for g in ["Group A", "Group B"]
            treatment = collect(Drug_assignment[d][g])[i]
            push!(Procedure,[d,g,day,treatment,i])
        end
    end
end

##
function get_treatment(drug,group,day)
    phase = get(Drug_assignment,drug,"none")
    if phase == "none"
        return "none"
    else
        v = collect(Drug_assignment[drug]["Days"])
        idx = findall(t-> t == day,v)
        if length(idx)>1
            println("weird amount of dates matching")
        else
            idx = idx[1]
        end
        return collect(Drug_assignment[drug][group])[idx]
    end
end

########################################
const Sequence = OrderedDict()
Sequence["Group A"] = ["none","sal","+","o","sal"]
Sequence["Group B"] = ["none","sal","o","+","sal"]

const Full_Drug_Calendar = OrderedDict()
for drug in drugs
    Full_Drug_Calendar[drug] = OrderedDict()
end

for drug in drugs
    for g in ["Group A","Group B"]
        Full_Drug_Calendar[drug][g] = OrderedDict()
    end
end

for drug in drugs
    for g in ["Group A","Group B"]
        for (day,inj) in zip(Phase_calendar[drug],Sequence[g])
            Full_Drug_Calendar[drug][g][day] = inj
        end
    end
end

function get_injection(phase,group,day)
    phase = get(Full_Drug_Calendar,phase,"none")
    if phase == "none"
        return "none"
    else
        return get(phase[group],day,"none")
    end
end
