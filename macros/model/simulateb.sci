function [result]=simulateb(grocer_model,grocer_tsmat,grocer_startdate,grocer_enddate,grocer_lag,grocer_fromdate,grocer_todate,varargin)
 
// PURPOSE: simulate macroeconometric models with lagged or
// simultaneous variables
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model typed list created by the function
//   create_model
// * grocer_tsmat = a tsmat, containing values for endogenous,
//   exogenous and residuals variables (perferably created by
//   the function create_dbmod)
// * grocer_startdate = a string, the starting date of the
//   simulation
// * grocer_enddate = a string, the end date of the simulation
// * grocer_lag = an interger, the lag used for the starting
//   values of the simulation (0: current values in the
//   database,1: the results of the simulation at the previous
//   period)
// * grocer_fromdate = a string, the starting date for the
//   preservation of the data in the tsmat output
// * grocer_todate = a string, the final date for the
//   preservation of the data in the tsmat output
// * varargin = an optional argument, which can be
//   - 'meth=xx' where xx is either 'Newton' for the Newton
//   method or 'Gauss-Seidel' for the Gauss-Seidel method
//   - 'ftol=xx' where xx is the value of the convergence
//   criterion for the function absolute value (default: 1e-8)
//   - 'deltol=xx' where xx is the value of the convergence
//   criterion for the absolute value of the variation of the
//   endogenous variables (default: 1e-8)
//   - 'exp=xx' where xx is the value of the exponent applied
//     to the number of endogenous variables in the heart to
//     obtain the number of Gauss-Seidel simulations performed
//     before switching back to the Newton method, when the
//     Newton method hs not converged intially (default: 0.5)
// ------------------------------------------------------------
// OUTPUT:
// * result = a tsmat, containing the results of the
// simulation, with:
//   - result('meth') = 'model simulation'
//   - result('model name') = a string, the name of the
//   simulated model
//   - result('model') = a model tlist, used for the simulation
//   - result('simulation results') = a tsmat, the results of
//   the simulation
//   - result('function values') = a (N X 1) vector, collecting
//   the errors terms of the equations
// ------------------------------------------------------------
// Copyright: Eric Dubois 2012-2016
// http://grocer.toolbox.free.fr/grocer.html
 
mkdir(GROCERDIR+'\tmp')
// set defaults if inputs are lacking
grocer_ftol=1E-8
grocer_deltol=1E-8
grocer_delf_tol=5*1E-9
grocer_meth='Newton'
grocer_itermax=50
grocer_alphamin=0.01
grocer_newton_meth='newton_U15_sp'
grocer_verbose=%f
 
[grocer_nargout,grocer_nargin]=argn(0)
if ~grocer_model('transf') then
   error('model has not been transformed for simulation: use model_transf')
end
 
if grocer_nargin <= 6 then
   grocer_todate=grocer_enddate
end
if grocer_nargin <=5  then
   grocer_fromdate=grocer_startdate
end
if typeof(grocer_tsmat) == 'results' then
   if  or(grocer_tsmat(1) == 'simulation results') then
      grocer_tsmat=grocer_tsmat('simulation results')
   end
end
 
for grocer_i=1:grocer_nargin-7
   grocer_argi=varargin(grocer_i)
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if part(grocer_argi,1:5) == 'meth=' then
         grocer_meth=part(grocer_argi,6:length(grocer_argi))
      elseif part(grocer_argi,1:12) == 'newton_meth=' then
         grocer_newton_meth=part(grocer_argi,13:length(grocer_argi))
      elseif part(grocer_argi,1:5) == 'ftol=' then
         execstr('grocer_'+grocer_argi)
      elseif part(grocer_argi,1:9) == 'alphamin=' then
         execstr('grocer_'+grocer_argi)
      elseif part(grocer_argi,1:8) == 'itermax=' then
         execstr('grocer_'+grocer_argi)
      elseif part(grocer_argi,1:7) == 'deltol=' then
         execstr('grocer_'+grocer_argi)
      elseif grocer_argi == 'verbose' then
         grocer_verbose=%t
      end
   end
end
 
if ~exists('grocer_fromdate','local') then
    grocer_fromdate=grocer_startdate
end
if ~exists('grocer_to','local') then
    grocer_todate=grocer_enddate
end
[sers,dats,valf]=simulate1b(grocer_model,grocer_tsmat,grocer_startdate,grocer_enddate,1,grocer_fromdate,grocer_todate,grocer_newton_meth,grocer_ftol,grocer_deltol,grocer_itermax,grocer_alphamin,grocer_verbose)
 
grocer_tsmat('series')=sers;
grocer_tsmat('dates')=dats
 
clear grocer_startdate grocer_enddate grocer_lag grocer_fromdate grocer_todate sers dats ;
clear grocer_newton_meth grocer_ftol grocer_deltol grocer_itermax grocer_alphamin grocer_verbose;
result=tlist(['results';'meth';'model name';'model';'simulation results';...
'function values'],...
'model simulation',grocer_model('namemod'),grocer_model,grocer_tsmat,valf)
 
clear grocer_db grocer_model grocer_tsmat valf ;
 
endfunction
