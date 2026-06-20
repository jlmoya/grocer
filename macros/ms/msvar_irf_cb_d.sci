function msvar_irf_cb_d()

global GROCERDIR ;
load(GROCERDIR+'\data\msirf_d.dat')
rms=ms_var('all',2,['100*delts(log(us_gdp))','us_un'],2,2,3)
rirf_cb=mxvar_irf_cb(rms,20,99,0.1)

endfunction
