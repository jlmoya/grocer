function histo_ts_d()

global GROCERDIR;
load(GROCERDIR+'\data\bdhenderic.dat')
histo_ts('delts(lm1)',2,'M1 growth rate',1)

endfunction
