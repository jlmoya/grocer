function rd=dchange_d()
 
global GROCERDIR;
 
// performs Pesaran and Timmermann test on French business survey
// answers :
// . pp   = level of past own production
// . fp   = level of futur own production
// test if change in "fp" are a good predictors of change in "pp" 3 month laters
 
load(GROCERDIR+'\data\BusinessSurvey.dat');
 
// performs first differences
dpp = delts(pp);
dpf =delts(fp);
bounds()
rd = dchange('dpp','lagts(3,dpf)');
endfunction
