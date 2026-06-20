function [rspec,rvar]=specvarma_d()
 
global GROCERDIR;
 
// of French (fr), German (ger), Italian (it) and Spanish (spa) PPP GDP
 
load(GROCERDIR+'\data\specgdp.dat');
 
// get the names of the variables available in the database
lvar =dblist(GROCERDIR+'\data\specgdp.dat');
 
// transforms by log and first difference
// & center data
for i = 1:size(lvar,1)
   execstr('dl'+lvar(i)+' = delts(log('+lvar(i)+'))')
   execstr('dl'+lvar(i)+'_m = dl'+lvar(i)+' - mean(dl'+lvar(i)+')')
end
 
bounds()
// estimate var(4) model with no constant
rvar = VAR(4,'endo=dlfr_m;dlger_m;dlit_m;dlsp_m','nocte','noprint')
 
// estimates and prints cohesion of var model
// and compute 95% interval confidence band
rspec = specvarma(rvar,'cohes=1','ic=1');
endfunction
