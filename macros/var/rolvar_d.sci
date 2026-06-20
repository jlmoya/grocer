function [resrolvar,resrolgranger,resrolirf]=rolvar_d()

global GROCERDIR ;
load(GROCERDIR+'\data\france_maunf_survey.dat')
bounds()
resrolvar=rolvar(6,'endo=fra_past_output;fra_exp_output','nper=120','start_firstbound=1990m1','end_firstbound=2004m1')
resrolgranger=rolvar_granger(resrolvar,'fra_exp_output','fra_past_output')
resirf=rolirf(resrolvar,20)
pltrolirf_3d(resirf,2,1,1:12:169,1:21)

    
endfunction
