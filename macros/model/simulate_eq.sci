function [sim_eq,model_eq]=simulate_eq(model,model_db,name_eq,name_endo,grocer_startdate,grocer_enddate,varargin)
 
// PURPOSE: simulate an equation of a model
// ------------------------------------------------------------
// INPUT:
// * model = a model typed list created by the function
//   create_model
// * model_db = a tsmat, containing values for endogenous,
//   exogenous and residuals variables (perferably created by
//   the function create_dbmod)
// * name_eq =  the name of the equation
// * name_endo = the name of the variable in the equation
//   that will be considered as endogenous
// * grocer_startdate = a string, the starting date of the
//   simulation
// * grocer_enddate = a string, the end date of the simulation
// * varargin = optional arguments that should start with:
//    - an integer, the lag used for the starting
//    values of the simulation (0: current values in the
//    database,1: the results of the simulation at the previous
//    period)
//    - a string, the starting date for the
//    preservation of the data in the tsmat output
//   - a string, the final date for the
//   preservation of the data in the tsmat output
// and thereafter optional arguments, among which:
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
// * sim_eq = a tsmat, containing the results of the
// simulation, with:
//   - result('meth') = 'model simulation'
//   - result('model name') = a string, the name of the
//   simulated model
//   - result('model') = a model tlist, used for the simulation
//   - result('simulation results') = a tsmat, the results of
//   the simulation
//   - result('function values') = a (N X 1) vector, collecting
//   the errors terms of the equations
// * model_eq = the model created from the selected equation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2018
// http://grocer.toolbox.free.fr/grocer.html
 
 
[nargout,nargin]=argn(0)
 
ind_eq=find(model('name eq') == name_eq)
eq=model('equations')(ind_eq)
model_eq=create_emptymodel('name_endo')
model_eq('name eq')=name_eq
model_eq('equations')=eq
model_eq('name endo')=name_endo
 
if ~isempty(model('eq coeffs')) then
   ind_coeffs=find(model('eq coeffs')(:,ind_eq) ~= 0)
   model_eq('name coeff')=model('name coeff')(ind_coeffs)
   coeffs=tlist(['coeffs';model_eq('name coeff')])
   for i=1:size(ind_coeffs,2)
      coeffs(i+1)=model('coeffs')(ind_coeffs(i)+1);
   end
   model_eq('coeffs')=coeffs
else
   model_eq('name coeff')=[]
   model_eq('coeffs')=tlist(['coeffs'])
end
 
if ~isempty(model('eq params')) then
   ind_params=find(model('eq params')(:,ind_eq) ~= 0)
   model_eq('name param')=model('name param')(ind_params)
   params=tlist(['params';model_eq('name param')])
   for i=1:size(ind_params,2)
      params(i+1)=model('params')(ind_params(i)+1);
   end
   model_eq('params')=params
else
   model_eq('name param')=[]
   model_eq('params')=tlist(['params'])
end
 
ind_endos=find(model('eq endos')(:,ind_eq) ~= 0)
name_endos=model('name endo')(ind_endos)
name_exos_eq=name_endos(name_endos ~= name_endo)
 
ind_exos=find(model('eq exos')(:,ind_eq) ~= 0)
name_exos=model('name exo')(ind_exos)
name_exos_eq=[name_exos_eq ; name_exos(name_exos ~= name_endo)]
 
ind_resids=find(model('eq resids')(:,ind_eq) ~= 0)
name_resids=model('name resid')(ind_resids)
name_resids_eq=name_resids(name_resids ~= name_endo)
 
if isempty([name_endos(name_endos == name_endo) , name_exos(name_exos == name_endo) , name_resids(name_resids == name_endo)]) then
   error('variable '+name_endo+' is not in equation '+name_eq)
end
 
model_eq('name exo')=name_exos_eq
model_eq('name resid')=name_resids_eq
model_eq=model_transf(model_eq)
if nargin < 6 then
   sim_eq=simulate(model_eq,model_db,grocer_startdate,grocer_enddate,[],grocer_startdate,grocer_enddate,varargin(:))
else
   sim_eq=simulate(model_eq,model_db,grocer_startdate,grocer_enddate,[],varargin(:))
end
 
endfunction
