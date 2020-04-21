const drugs = ["Cit","Meth","Alt","WAY","SB"]

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
for (dic,drug) in zip([Cit_per,Meth_per,Alt_per,WAY_per,SB_per],["Cit","Meth","Alt","WAY","SB"])
    for x in dic
        Phase_Calendar[x] = drug
    end
end

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
