using Switching
using CSV, BrowseTables, Dates
mac_gdrive = "/Volumes/GoogleDrive/My Drive"
linux_gdrive = "/home/beatriz/mainen.flipping.5ht@gmail.com"
files_dir = "Flipping/Datasets/Pharmacology/SwitchingData/Results"

full_pokes,full_streaks = process_all()
CSV.write(joinpath(linux_gdrive,files_dir,"pokes.csv"), full_pokes)
CSV.write(joinpath(linux_gdrive,files_dir,"streaks.csv"), full_streaks)

c = full_pokes[ismissing.(full_pokes.Side),:]
open_html_table(c[1:500,:])

c2 = filter(r-> r.MouseID == "a1" && r.Day == Date(2016,02,26), full_pokes)
open_html_table(c2)
Switching.files_dict()
##
sess = Switching.read_rawfile(3)
[println(i) for i in keys(sess["saved_history"])]
sess["saved_history"]["ProtocolsSection_raw_events"]
