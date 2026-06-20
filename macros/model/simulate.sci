function [result,grocer_tsmat]=simulate(grocer_model,grocer_tsmat,grocer_startdate,grocer_enddate,grocer_lag,grocer_fromdate,grocer_todate,varargin)
 
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
//   - 'newton_meth=xx' where xx is the function used to
//     perform the Newton method to solve the model
//   - 'ftol=xx' where xx is the value of the convergence
//   criterion for the function absolute value (default: 1e-8)
//   - 'deltol=xx' where xx is the value of the convergence
//   criterion for the absolute value of the variation of the
//   endogenous variables (default: 1e-8)
//  - 'verbose' if the user wants to display the date as they
//    are reached by the function
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
 
// set defaults if inputs are lacking
grocer_ftol=1E-8
grocer_deltol=1E-8
grocer_delf_tol=5*1E-9
grocer_meth='Newton'
grocer_itermax=50
grocer_alphamin=0.01
grocer_newton_meth='newton_U15_sp'
grocer_verbose=%f
 
if ~grocer_model('transf') then
   error('model has not been transformed for simulation: use model_transf')
end
[grocer_nargout,grocer_nargin]=argn(0)
 
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
      elseif part(grocer_argi,1:7) == 'deltol=' then
         execstr('grocer_'+grocer_argi)
      elseif grocer_argi == 'verbose' then
         grocer_verbose=%t
      end
   end
end
 
grocer_boundslit=bounds_db4model(grocer_model,grocer_tsmat,'noprint')
grocer_bounds=date2num_m(grocer_boundslit)
[grocer_startnum,grocer_fq]=date2num_fq(grocer_startdate)
grocer_endnum=date2num(grocer_enddate)
grocer_inbounds=%f
for grocer_i=size(grocer_bounds,1)
   grocer_inbounds = grocer_inbounds | (grocer_startnum >= grocer_bounds(1) &...
                     grocer_endnum <= grocer_bounds(2) & grocer_endnum <= grocer_bounds(3))
end
if ~grocer_inbounds then
   mat2prt1=[' - '+grocer_boundslit(:,1)+' to '+grocer_boundslit(:,2) , ...
   emptystr(grocer_boundslit(:,1))+'|' , grocer_boundslit(:,3)]
   mat2prt=[['simulation can start from: ' , '|' , 'and must end by:'; '--------------------------' , '|' , '----------------']; mat2prt1]
   write(%io(2),' ','(a)')
   printmat(mat2prt,%io(2))
   write(%io(2),' ','(a)')
   error('simulation bounds are not admissible')
end
 
write(%io(2),'newton function: '+grocer_newton_meth,'(a)')
execstr('grocer_newton='+grocer_newton_meth)
 
if isempty(strindex(grocer_newton_meth,'_sp')) then
   grocer_sp=%f
   execstr('grocer_newtons='+grocer_newton_meth)
else
    grocer_sp=%t
   execstr('grocer_newtons='+strsubst(grocer_newton_meth,'_sp',''))
end
// from the dates given as input, define the indexes of the
// start, end, from and to simulation dates
grocer_dates=grocer_tsmat('dates')
grocer_dbend=size(grocer_dates,1)
grocer_date0=grocer_dates(1)
grocer_daten=grocer_dates($)
 
grocer_start=grocer_startnum-grocer_date0+1
grocer_end=date2num(grocer_enddate)-grocer_date0+1
grocer_from=date2num(grocer_fromdate)-grocer_date0+1
grocer_to=date2num(grocer_todate)-grocer_date0+1
 
grocer_namendo=grocer_model('name endo')
grocer_nendo=size(grocer_namendo,1)
grocer_namexos=grocer_model('name exo')
grocer_namecoeffs=grocer_model('name coeff')
grocer_nameparams=grocer_model('name param')
grocer_coeffs=grocer_model('coeffs')
grocer_params=grocer_model('params')
grocer_list_emptycoeffs=[]
grocer_list_emptyparams=[]
 
// recover the values of the coefficients
for grocer_i=2:length(grocer_coeffs)
   if isempty(grocer_coeffs(grocer_i)) then
      grocer_list_emptycoeffs=[grocer_list_emptycoeffs ; grocer_namecoeffs(grocer_i-1)]
   end
   execstr(grocer_coeffs(1)(grocer_i)+'=grocer_coeffs('+string(grocer_i)+')')
end
 
if ~isempty(grocer_list_emptycoeffs) then
   write(%io(2),'error - the following coefficients are empty:','(a)')
   write(%io(2),strcat(grocer_list_emptycoeffs,', '),'(a)')
   abort
end
 
for grocer_i=2:length(grocer_params)
   if isempty(grocer_params(grocer_i)) then
      grocer_list_emptyparams=[grocer_list_emptyparams ; grocer_nameparams(grocer_i-1)]
   end
   execstr(grocer_params(1)(grocer_i)+'=grocer_params('+string(grocer_i)+')')
end
 
if ~isempty(grocer_list_emptyparams) then
   write(%io(2),'error - the following parameters are empty:','(a)')
   write(%io(2),strcat(grocer_list_emptyparams,', '),'(a)')
   abort
end
 
// prolog: define, if needed, the functions and Jacobians
execstr(grocer_model('prolog func txts'))
execstr(grocer_model('prolog Jac txts'))
grocer_nprolog=size(grocer_model('prolog endo'),'*')
if grocer_nprolog ~= 0 then
   deff('grocer_param=grocer_fprolog(grocer_param)',grocer_model('prolog string2run'))
end
// heart: from the texts of the fonction values and Jacobian, define the corresponding functions
grocer_heart_endo=grocer_model('heart endogenous')
grocer_nheart=size(grocer_heart_endo,2)
 
if grocer_meth == 'Gauss-Seidel' then
   execstr(grocer_model('gs func txts'))
   execstr(grocer_model('gs Jac txts'))
   grocer_gs_string2run=grocer_model('gs string2run')
   if grocer_nheart ~= 0 then
      deff('grocer_fval=grocer_fgs()',['grocer_fval=zeros('+string(grocer_nheart)+',1)' ;...
      'grocer_fval=['+strcat(strsubst(grocer_model('gs string2run'),'=','-(')+')',';')+']' ; 'grocer_fval  =real(grocer_fval)'])
   end
 
else
   grocer_Jacind=grocer_model('heart Jac indexes')
   if grocer_nheart ~= 0 then
      deff('grocer_fval=grocer_f(grocer_heart)',['grocer_fval=real(['+strcat(grocer_model('heart func txt'),';')+'])'])
      deff('grocer_v=grocer_Jacvec(grocer_heart)',['grocer_v=real(['+strcat(grocer_model('heart Jac rhs'),';')+'])'])
      deff('grocer_Jac=grocer_Jacf(grocer_heart)',[grocer_model('heart Jac txt');'grocer_Jac=real(grocer_Jac)'])
 
   end
 
end
 
// epilog: define, if needed, the functions and Jacobians
execstr(grocer_model('epilog func txts'))
execstr(grocer_model('epilog Jac txts'))
 
grocer_epilog_endo=grocer_model('epilog endo')
grocer_nepilog=size(grocer_epilog_endo,'*')
if grocer_nepilog ~= 0 then
   deff('grocer_param=grocer_fepilog(grocer_param)',grocer_model('epilog string2run'))
end
 
// recover individual series from the 'series' field in the db tsmat
grocer_namevari=grocer_tsmat('names')
grocer_series=grocer_tsmat('series')
execstr(grocer_namevari+'=grocer_series(:,'+string(1:size(grocer_namevari,1))'+')')
lagged_endos=grocer_model('non empty lagged endos')
 
// find the indexes of the endogenous variables in the db tsmat
grocer_indendo=[]
grocer_notfound=[]
for grocer_i=1:grocer_nendo
   grocer_indendo_i=find(grocer_namevari == grocer_namendo(grocer_i))
   if isempty(grocer_indendo_i) then
      grocer_notfound=[grocer_notfound ; grocer_namendo(grocer_i)]
   else
      grocer_indendo=[grocer_indendo ; grocer_indendo_i]
   end
end
if ~isempty(grocer_notfound) then
   error('variables '+strcat(grocer_notfound,', ')+' not found in the database')
end
if isempty(lagged_endos) then
   grocer_ind_laggedendo=[]
   grocer_series2endo=emptystr()
else
   grocer_ind_laggedendo=grocer_indendo(lagged_endos)
// create the string that updates the endogenous variables that are lagged in the model
   grocer_series2endo=grocer_namevari(grocer_ind_laggedendo)+'(grocer_date)=grocer_series(grocer_date,'+string(grocer_ind_laggedendo)+')'
end
grocer_valf=zeros(grocer_end-grocer_start+1,grocer_nendo)
grocer_info=zeros(grocer_end-grocer_start+1,1)
 
//simul_bounds=bounds_db4model(grocer_model,grocer_tsmat)
 
for grocer_date=grocer_start:grocer_end
   if grocer_verbose then
      write(%io(2),'simulation at date: '+num2date(grocer_date+grocer_date0-1,grocer_fq),'(a)')
   end
   if isempty(grocer_lag) then
      grocer_param=grocer_series(grocer_date,grocer_indendo)'
      grocer_nan=find(isnan(grocer_param))
      grocer_delta=1
      // now search starting values for the endogenous variables
      // starting with the values at the starting date and extending
 
      // progressively at other periods for the values that are non
      // available at the current date
      while ~isempty(grocer_nan) & (grocer_start > grocer_delta | grocer_start+grocer_delta <=grocer_dbend)
         if grocer_date > grocer_delta then
            grocer_i=grocer_date-grocer_delta
            grocer_param(grocer_nan)=grocer_series(grocer_i,grocer_indendo(grocer_nan))';
         end
         grocer_nan=find(isnan(grocer_param))
         if grocer_date+grocer_delta <=grocer_dbend then
            grocer_i=grocer_date+grocer_delta
            grocer_param(grocer_nan)=grocer_series(grocer_i,grocer_indendo(grocer_nan))';
         end
         grocer_nan=find(isnan(grocer_param))
         grocer_delta = grocer_delta+1
      end
      if grocer_nan then
         mat2print=grocer_namevari(grocer_indendo(grocer_nan));
         error('in your entry tsmat, you have an endogenous always equal to %nan')
      end
 
   else
      grocer_param=grocer_series(grocer_date-grocer_lag,grocer_indendo)'
      grocer_nan=find(isnan(grocer_param))
      if ~isempty(grocer_nan) then
         mat2print=grocer_namevari(grocer_indendo(grocer_nan));
         write(%io(2),'error: at date '+num2date(grocer_date+grocer_date0-1,grocer_fq)+' the following variables are %nan at lag '+string(grocer_lag),'(a)')
         write(%io(2),' ','(a)')
         printmat(mat2print,%io(2))
         result=[]
         return
      end
 
   end
 
   if grocer_nprolog ~=0 then
      grocer_param=grocer_fprolog(grocer_param)
   end
 
   if grocer_nheart ~= 0 then
      // restrict the grocer_param vector to the heart parameters
      grocer_heart=grocer_param(grocer_heart_endo)
 
      select grocer_meth
 
   case 'Newton'
      if grocer_sp then
         [grocer_heart1,grocer_v1,grocer_maxf0]=grocer_newton(grocer_heart,grocer_f,grocer_Jacvec,grocer_Jacind,grocer_ftol,grocer_itermax,grocer_alphamin)
      else
         [grocer_heart1,grocer_v1,grocer_maxf0]=grocer_newton(grocer_heart,grocer_f,grocer_Jacf,grocer_ftol,grocer_itermax,grocer_alphamin)
      end
      grocer_heart=real(grocer_heart1)
 
      if grocer_maxf0 > grocer_ftol then
         warning('max of the function abs values ('+string(grocer_maxf0)+'> tolerance value ('+ string(grocer_ftol)+')')
 
      elseif or(grocer_heart ~= grocer_heart1) then
         warning('converge acheived at complex values: real part taken')
         grocer_v1=grocer_f(grocer_heart)
 
      end
      grocer_param(grocer_heart_endo)=grocer_heart
 
      case 'Gauss-Seidel' then
         grocer_maxf0=%inf
         grocer_max_delx0=%inf
         grocer_iter=1
         grocer_order=1:grocer_nheart
         grocer_cut=1
         while grocer_maxf0 > grocer_ftol & grocer_max_delx0 > grocer_deltol
            grocer_heart0=grocer_heart
            execstr(grocer_gs_string2run(grocer_order))
            execstr('grocer_heart=['+joinstr('grocer_param',string(grocer_heart_endo),'_',';')+']')
            grocer_v2=grocer_f(grocer_heart)
            [grocer_maxf0,grocer_cut]=max(abs(grocer_v2))
            grocer_indcut=find(grocer_order == grocer_cut)
            grocer_order=[grocer_order(1:grocer_indcut-1) , grocer_order(grocer_indcut+1:grocer_nheart) , grocer_cut]
            grocer_maxdelx0=max(abs(grocer_heart-grocer_heart0))
            grocer_iter=grocer_iter+1
         end
      end
      grocer_valf(grocer_date-grocer_start+1,grocer_heart_endo)=grocer_v1'
   end
   if grocer_nepilog ~=0 then
      grocer_param=grocer_fepilog(grocer_param)
   end
   grocer_series(grocer_date,grocer_indendo)=grocer_param'
   execstr(grocer_series2endo)
   // stores the simulated values into the vectors of endogenous lagged variables
   // to start from them at the next dates
end
 
// insert the matrix of simulated values into the original tsmat,
// keeping only the required observations (grocer_from:grocer_end)
grocer_tsmat('series')=grocer_series(grocer_from:grocer_to,:)
grocer_tsmat('dates')=grocer_dates(grocer_from:grocer_to)
 
result=tlist(['results';'meth';'model name';'model';'simulation results';...
'function values'],...
'model simulation',grocer_model('namemod'),grocer_model,grocer_tsmat,...
grocer_valf)
 
endfunction
