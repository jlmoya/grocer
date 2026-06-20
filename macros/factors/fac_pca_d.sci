function res=fac_pca_d()
 
global GROCERDIR;
 
// with INSEE actual business climate
// labels :
// . pp   = level of past personnal production
// . pf   = level of futur personnal production
// . gob  = level of global order books
// . fob  = level of foreign order books
// . in   = leverl of inventories
// . gpp  = general perspectives of production
// . clim = actual business climate provides by INSEE (french institut of statistics)
lines(0);
load(GROCERDIR+'/data/BusinessSurvey.dat');
 
bounds() 
// performs DFA and keep the first factor
res = fac_pca('pp','fp','gpp','gob','fob','in','pnum=6','snum=1');
f1 = 100+10*(res('f1')-mean(series(res('f1'))))/varcov0(series(res('f1')));
 
pltseries('clim','f1','yaxis=[1,2]','title=Actual and estimated french business climate',...
					'legend=[INSEE;DFA]','styleg=7')
					
endfunction
