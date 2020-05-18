const drugs = ["Citalopram","Methysergide","Altanserin","Way_100135","SB242084","Optogenetic"]

const Cit_per = Date(2016,03,14):Day(1):Date(2016,03,18)
const Meth_per = Date(2016,03,21):Day(1):Date(2016,03,25)
const Alt_per = Date(2016,03,28):Day(1):Date(2016,04,01)
const WAY_per = Date(2016,04,04):Day(1):Date(2016,04,08)
const SB_per = Date(2016,05,23):Day(1):Date(2016,05,27)
const Opto_per = Date(2016,07,19):Day(1):Date(2016,08,04)

# const Phase_calendar = OrderedDict()
# for (d,p) in zip(drugs,[Cit_per,Meth_per,Alt_per,WAY_per,SB_per, Opto_per])
#     Phase_calendar[d] = p
# end

const Phase_Calendar = OrderedDict()
for (dic,drug) in zip([Cit_per,Meth_per,Alt_per,WAY_per,SB_per, Opto_per],drugs)
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
    for g in ["Group A", "Group B","Group C", "Group D"]
        Drug_assignment[d][g] = OrderedDict()
    end
end

Drug_assignment["Citalopram"]["Group A"] = ["None","PreVehicle","Citalopram","PostVehicle","Saline"]
Drug_assignment["Citalopram"]["Group B"] = ["None","Saline","PreVehicle","Citalopram","PostVehicle"]
Drug_assignment["Citalopram"]["Days"] = Cit_per
Drug_assignment["Methysergide"]["Group A"] = ["None","PreVehicle","Methysergide","PostVehicle","Saline"]
Drug_assignment["Methysergide"]["Group B"] = ["None","Saline","PreVehicle","Methysergide","PostVehicle"]
Drug_assignment["Methysergide"]["Days"] = Meth_per
Drug_assignment["Altanserin"]["Group A"] = ["None","PreVehicle","Altanserin","PostVehicle","Saline"]
Drug_assignment["Altanserin"]["Group B"] = ["None","Saline","PreVehicle","Altanserin","PostVehicle"]
Drug_assignment["Altanserin"]["Days"] = Alt_per
Drug_assignment["Way_100135"]["Group A"] = ["None","PreVehicle","Way_100135","PostVehicle","Saline"]
Drug_assignment["Way_100135"]["Group B"] = ["None","Saline","PreVehicle","Way_100135","PostVehicle"]
Drug_assignment["Way_100135"]["Days"] = WAY_per
Drug_assignment["SB242084"]["Group A"] = ["None","Saline","PreVehicle","SB242084","PostVehicle"]
Drug_assignment["SB242084"]["Group B"] = ["None","PreVehicle","SB242084","PostVehicle","Saline"]
Drug_assignment["SB242084"]["Days"] = SB_per
Drug_assignment["Optogenetic"]["Group C"] = ["Saline", "Saline", "Saline","Saline", "SB242084_opt", "None",
                                          "Saline", "Saline", "Saline", "SB242084_opt", "Saline", "Saline",
                                           "Saline", "SB242084", "Saline", "Saline", "SB242084_opt"]
Drug_assignment["Optogenetic"]["Group D"] = ["Saline", "Saline", "Saline", "SB242084_opt", "Saline", "None",
                                          "Saline", "SB242084","Saline", "Saline", "Saline", "SB242084_opt",
                                          "Saline", "Saline", "Saline","SB242084_opt", "Saline"]
Drug_assignment["Optogenetic"]["Days"] = Opto_per



##
const Procedure =  DataFrame(Phase = String[], Group = String[], Day = Date[],
    Treatment = String[],PhaseDay = Int64[])

for drug in drugs
    for (i,day) in enumerate(Drug_assignment[drug]["Days"])
        for group in ["Group A", "Group B"]
            if isempty(Drug_assignment[drug][group])
                continue
            else
                treatment = Drug_assignment[drug][group][i]
                push!(Procedure,[drug,group,day,treatment,i])
            end
        end
    end
end

##
function get_treatment(drug,group,day)
    phase = get(Drug_assignment,drug,"None")
    if phase == "None"
        return "None"
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
# const Sequence = OrderedDict()
# Sequence["Group A"] = ["none","sal","+","o","sal"]
# Sequence["Group B"] = ["none","sal","o","+","sal"]
#
# const Full_Drug_Calendar = OrderedDict()
# for drug in drugs
#     Full_Drug_Calendar[drug] = OrderedDict()
# end
#
# for drug in drugs
#     for g in ["Group A","Group B"]
#         Full_Drug_Calendar[drug][g] = OrderedDict()
#     end
# end
#
# for drug in drugs
#     for g in ["Group A","Group B"]
#         for (day,inj) in zip(Phase_calendar[drug],Sequence[g])
#             Full_Drug_Calendar[drug][g][day] = inj
#         end
#     end
# end

function get_injection(phase,group,day)
    phase = get(Full_Drug_Calendar,phase,"none")
    if phase == "none"
        return "none"
    else
        return get(phase[group],day,"none")
    end
end
