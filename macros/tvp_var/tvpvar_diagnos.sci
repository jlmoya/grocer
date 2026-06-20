function [results]=tvpvar_diagnos(res,obj,varargin)
 
// PURPOSE: computes MCMC convergence diagnostics for some
// type of results (At, Bt, S, Q, W or Htstd) from a tvp-var
// results
// ------------------------------------------------------------
// INPUT:
// * res = a tvp var results tlist
// * obj = a string, the name of the examined field in the tvp
//   var
// * varargin = optional arguemnts that can be
//   - 'nautcorr=x' where x is the order of the autocorrelation
//     tested for the draws (default: 0.04)
//   - 'npct_taper=x' where x is the % used to taper the window
//      in t for Geweke's test (default: 100)
//   - 'n_groups=x' where x is the number of draws that are
//     aggregated before performing the correlations
//   - 'q=x' where x is the quantile of the quantity of interest
//      in Raftery test (default: 0.025)
//   - 'r=x' where x is the level of precision desired in
//      Raftery test (default: 0.025)
//   - 's=x' where x is the required probability of attaining
//      the required accuracy r (default: 0.95)
//   - 'noprint' if the user does not want to print the results
// ------------------------------------------------------------
// OUTPUT:
// results = a results tlist with:
// -  results('meth') = 'tvp var convergence diagnostics'
// -  results('object') = the type of results that is diagnosed
// -  results('auto order') = the autocorrelation order of the
//    autocorrelation diagnostic
// -  results('autocorrelation') = autocorrelation estimates
// -  results('Geweke tests') = results tlist from the Geweke's
//    convergence diagnostics
// -  results('Raftery tests') = results tlist from the Raftery
//    and Lewis convergence diagnostics
// -----------------------------------------------------------------
// Copyright: Eric Dubois 2014
// http://grocer.toolbox.free.fr/grocer.html
 
 
grocer_nautocorr=20
grocer_pct_taper=0.04
grocer_n_groups=100
grocer_q=0.025
grocer_r=0.025
grocer_s=0.95
grocer_prt=%t
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if varargin(grocer_i) == 'noprint' then
       grocer_prt=%f
   else
      execstr('grocer'+varargin(grocer_i))
   end
end
 
// recover the names of the database that store the results correspoding
// to the chosen object
db_obj=res('.dat '+obj)
load(db_obj(1))
 
// calculate the size of the whole results for the object
execstr('size_data=size('+obj+')')
ndim=size(size_data,2)
ndraws_perdb=size_data(ndim)
n_db=size(db_obj,1)
size_data(ndim)=size_data(ndim)*n_db
 
execstr('data=zeros('+strcat(string(size_data),',')+')')
for db=1:n_db
   load(db_obj(db))
   execstr('data(:,:,1+(db-1)*ndraws_perdb:db*ndraws_perdb)='+obj)
end
 
autocorr=MCMC_autocorr(data,grocer_nautocorr);
resultsg=tvp_var_geweke(res,obj,grocer_pct_taper,grocer_n_groups)
 
resultsr = raftery(runs,grocer_q,grocer_r,grocer_s)
 
results=tlist(['results';'meth';'object';'auto order';'autocorrelation';'Geweke tests';'Raftery tests'],...
'tvp var convergence diagnostics',obj,grocer_nautocorr,autocorr,resultsg,resultsr)
 
if grocer_prt then
   prt_tvpvar_diagnos(results)
end
 
endfunction
