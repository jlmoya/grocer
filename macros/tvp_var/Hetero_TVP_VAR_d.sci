function [res,irf_med,irf_low,irf_up]=Hetero_TVP_VAR_d()

global GROCERDIR
if ~isdir(GROCERDIR+'\temp') then
   mkdir(GROCERDIR+'\temp')
end
load(GROCERDIR+'\data\primiceri.dat')

nlag=2
bounds('1953q3','1963q2')
prior=tvpvar_prior0(nlag,4,4,0.01,0.01,0.1,['Inflation';'Unemployment';'rate_3m'])

bounds('1963q3','2001q3')
res=Hetero_TVP_VAR(nlag,['Inflation';'Unemployment';'rate_3m'],10000,2000,prior,GROCERDIR+'\temp',1000)
save(GROCERDIR+'\temp\res_tvpvar.dat','res')
Hetero_TVP_VAR_stdresid(res,1:3,0.32)
[irf_med,irf_mean,irf_low,irf_up]=Hetero_TVP_VAR_irf(res,['1975q1';'1981q3';'1996q1'],20,0.32)

endfunction
