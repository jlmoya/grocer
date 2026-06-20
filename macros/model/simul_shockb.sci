function simul_result=simul_shockb(grocer_model,grocer_db,grocer_startdate,grocer_enddate,varargin)
 
// PURPOSE: simulate the impact of shocks to exogenous
// variables
// ------------------------------------------------------------
// INPUT:
// * grocer_model = a model typed list created by the function
//   create_model
// * grocer_db = a tsmat, containing values for endogenous,
//   exoegnous and residuals variables
// * grocer_startdate = a string, the starting date of the
//   simulation
// * grocer_enddate = a string, the end date of the simulation
// * varargin = arguments that can be:
//   - the string 'from=xxx' where xxx is the date from which
//   data should be kept (if before the starting date)
//   - the string 'to=xxx' where xxx is the date to which
//   data should be kept (if after the ending date)
//   - the string 'lag=xxx' where xxx is the lag applied to
//     the data in the data tsmat to provide starting values
//     the simulation programs (0 if you want to use the
//     current values in the baseline, 1 if you want to use
//     lagged simulated values -default)
//   - a list with 3 elements: a string vector (maybe of size
//    1), indicating the variables that are shocked
//   - a string, indicating, indicating how the variables are
//   shocked ('pcer' for a deviation by a percentage, 'er' for
//   a deviation by a given amount, 'ts' to susbtitue the
//   values taken from a ts to the values in the databse)
///  - either a real containing the percentage shock (when
//    2nd arg set to 'pcer'), the deviation (when 2nd arg
//    set to 'er'); a string vector of the same size as the
//    first arg, containing the names of the ts used to replace
//    the values in the database, or a ts (only if the first
//    arg has size one)
//   - any option to simulate
// ------------------------------------------------------------
// OUTPUT:
// * grocer_tsmat = a results tlist, containing the results of
//   the simulation
// ------------------------------------------------------------
// Copyright: Eric Dubois 2016
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_ftol=1E-8
grocer_deltol=1E-8
grocer_delf_tol=5*1E-9
grocer_meth='Newton'
grocer_itermax=50
grocer_alphamin=0.01
grocer_newton_meth='newton_U15_sp'
grocer_verbose=%f
 
grocer_nargin=length(varargin)
grocer_dbnames=grocer_db('names')
grocer_dates=grocer_db('dates')
grocer_series=grocer_db('series')
 
for grocer_i=1:grocer_nargin
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
 
if ~exists('grocer_fromdate','local') then
    grocer_fromdate=grocer_startdate
end
if ~exists('grocer_to','local') then
    grocer_todate=grocer_enddate
end
 
grocer_dbend=size(grocer_dates,1)
grocer_date0=grocer_dates(1)
grocer_daten=grocer_dates($)
[grocer_startnum,grocer_fq]=date2num_fq(grocer_startdate)
grocer_start=grocer_startnum-grocer_date0+1
grocer_from=date2num(grocer_fromdate)-grocer_date0+1
grocer_end=date2num(grocer_enddate)-grocer_date0+1
grocer_to=date2num(grocer_todate)-grocer_date0+1
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   select typeof(grocer_argi)
   case 'list' then
      grocer_vari=grocer_argi(1)
      grocer_shocki=grocer_argi(3)
      for grocer_j=1:size(grocer_vari,'*')
         grocer_vari_j=grocer_vari(grocer_j)
         if typeof(grocer_shocki) == 'string' then
            grocer_shocki_j=grocer_shocki(grocer_j)
 
         elseif typeof(grocer_shocki) == 'ts' then
            grocer_shocki_j=grocer_shocki
 
         elseif typeof(grocer_shocki) == 'constant' then
            if size(grocer_shocki,'*') == 1 then
               grocer_shocki_j=grocer_shocki
            else
               grocer_shocki_j=grocer_shocki(grocer_j)
            end
         end
 
         grocer_indvari_j=find(grocer_dbnames == grocer_vari_j)
         if isempty(grocer_indvari_j) then
            error('variable not found in database: '+grocer_vari_j)
         end
         grocer_type_shock=grocer_argi(2)
         select grocer_type_shock
         case 'er' then
            grocer_series(grocer_start:grocer_end,grocer_indvari_j)=grocer_series(grocer_start:grocer_end,grocer_indvari_j)+grocer_shocki_j
         case 'pcer' then
            grocer_series(grocer_start:grocer_end,grocer_indvari_j)=grocer_series(grocer_start:grocer_end,grocer_indvari_j)*(1+grocer_shocki_j/100)
         case 'ts' then
            grocer_newts=grocer_shocki_j
            if typeof(grocer_newts) == 'string' then
               grocer_newts=evstr(grocer_newts)
            end
            grocer_newts_dates=grocer_newts('dates')
            grocer_newts_series=grocer_newts('series')
            grocer_series(grocer_start:grocer_end,grocer_indvari_j)=grocer_newts_series([grocer_startnum:date2num(grocer_enddate)]-grocer_newts_dates(1)+1)
         end
      end
      varargin(grocer_i)=null()
   end
end
 
grocer_db('series')=grocer_series
 
clear grocer_dbnames grocer_series grocer_dbend grocer_date0 grocer_daten grocer_startnum grocer_fq grocer_i grocer_nargin ;
clear grocer_start grocer_from grocer_end grocer_to grocer_newts grocer_newts_series grocer_newts_dates grocer_type_shock ;
 
[sers,dats,valf]=simulate1b(grocer_model,grocer_db,grocer_startdate,grocer_enddate,1,grocer_fromdate,grocer_todate,grocer_newton_meth,grocer_ftol,grocer_deltol,grocer_itermax,grocer_alphamin,grocer_verbose)
grocer_db('series')=sers;
grocer_db('dates')=dats
 
clear grocer_startdate grocer_enddate grocer_lag grocer_fromdate grocer_todate sers dats ;
clear grocer_newton_meth grocer_ftol grocer_deltol grocer_itermax grocer_alphamin grocer_verbose;
simul_result=tlist(['results';'meth';'model name';'model';'simulation results';...
'function values'],...
'model simulation',grocer_model('namemod'),grocer_model,grocer_db,valf)
 
clear grocer_db grocer_model grocer_series valf grocer_namevari ;
 
endfunction
