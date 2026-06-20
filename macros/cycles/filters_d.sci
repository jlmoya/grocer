function []=filters_d()
 
global GROCERDIR;
 
load(GROCERDIR+'/data/deugdp.dat')
bounds();
deu_gdp_hp=hpfilter(deu_gdp,1600)
deu_gdp_bk12=bkfilter(deu_gdp,6,32,12,'fixed')
deu_gdp_bkasym=bkfilter(deu_gdp,6,32,1,'vari')
deu_gdp_cff=cffilter(deu_gdp,6,32)
prtts('deu_gdp_bkasym')
//prtts('deu_gdp','deu_gdp-pibrfa_hp','deu_gdp_bk12','deu_gdp_bkasym','deu_gdp_cff')
//bounds('1960q2','2002q4')
pltseries('deu_gdp-deu_gdp_hp','deu_gdp_bk12','deu_gdp_bkasym','deu_gdp_cff','bounds=[''1960q2'';''2002q4'']','yaxex=0','title=filters on DEU GDP','styleg=6')
endfunction
