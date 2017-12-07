

using IcanProj
using JFSM
using PyPlot






function run_new(filename, year, month, day, hour, dt)

    rainf, snowf, tair, iswr, ilwr, pres, rhum, wind = read_mtclim_fsm(filename)

    metdata = [year month day hour iswr ilwr snowf/dt rainf/dt tair+273.15 rhum wind pres*1000]

    am = 0
    cm = 0
    dm = 0
    em = 0
    hm = 0

    md = FsmType(am, cm, dm, em, hm, dt)

    hs = run_fsm(md, metdata)

    return hs

end



filename = "../data/metdata_71.16148_25.54974"

dt = 3*3600

time = [DateTime(2002,1,1,6)+i*Dates.Hour(3) for i in 0:(length(rainf)-1)]

year = Dates.year.(time)

month = Dates.month.(time)

day = Dates.day.(time)

hour = Dates.hour.(time)

hs = run_new(filename, year, month, day, hour, dt)

