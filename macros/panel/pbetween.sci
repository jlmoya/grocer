function res=pbetween(grocer_namey,varargin)
 
// PURPOSE: performs Between Estimation for Panel Data
//          (for balanced or unbalanced data)
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a real (nx1) vector or a string equal to
// the name of a time series or a (nx1) real vector between
// quotes (this last case is the only one authorized if you
// are using a 'panel data' tlist, see below)
// * first input of varargin:
//   - either a 'panel data' tlist
//   (generally imported from a .csv database by function
//    impexc2bd)
//   - or an endogenous variable taking the form of a time
//     series, a real (nx1) vector or a string equal to the
//     name of a time series or a (nx1) real vector between
//     quotes
// * other input of varargin:
//   - if first input of varargin was a 'panel data' tlist
//   then:
//      other input are optional and can be:
//      * either 'x=name1;...;namep' where name1,...,namep are
//      a subset of the names of the variables that are in the
//      database
//      * the string 'nameid=name1,..., namen' where name1,...
//      are names of individuals present in the database
//      * or the string 'noprint' if the user does not want to
//      print the estimation results
//   - if first input of varargin was an endegnous variable
//   then either:
//      * a time series
//      * a real (nxk) matrix
//      * a (kx1) string vector of names of time series, vectors
//      or matrices
//      * the string 'id=v' where v is the vector of individuals
//      attached to the y and x data (this argument must be
//      present somewhere in the list of variables arguments)
//      * the string 'noprint' if the user doesn't want the
//      to print the results of the regression
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')='panel with random effects'
//   . res('y')     = y data vector
//   . res('x')     = x data matrix
//   . res('nobs')  = nobs
//   . res('nvar')  = nvars
//   . res('beta')  = bhat
//   . res('yhat')  = yhat
//   . res('resid') = residuals
//   . res('vcovar') = estimated variance-covariance matrix of
//     beta
//   . res('sige')  = estimated variance of the residuals
//   . res('sige')  = estimated variance of the residuals
//   . res('ser')  = standard error of the regression
//   . res('tstat') = t-stats
//   . res('pvalue') = pvalue of the betas
//   . res('condindex') = multicolinearity cond index
//   . res('prescte') = boolean indicating the presence or
//     absence of a constant in the regression
//   . res('rsqr')  = rsquared
//   . res('rbar')  = rbar-squared
//   . res('f')    = F-stat for the nullity of coefficients
//     other than the constant
//   . res('pvaluef') = its significance level
//   . res('gls estimation method') = the gls method used
//   . res('random effects') = the estimation of the individual
//     effects
//   . res('res0') = residuals from the original model
//   . res('alfa') = the gls parameters
//----------------------------------------------------------------------------------------
// Copyright Eric Dubois 2005
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt = %t
grocer_prescte = %t
grocer_arg1 = varargin(1)
grocer_nargin=length(varargin)
 
if typeof(grocer_arg1) == 'panel data' then
 
   grocer_namep=grocer_arg1('namex')
// grocer_namep is the vector of names in the data base
 
   grocer_xp=grocer_arg1('x')
// grocer_xp is the vector of values in the data base
 
   grocer_findendo=(grocer_namep == grocer_namey)
   grocer_y=grocer_xp(:,grocer_findendo)
   grocer_x=grocer_xp(:,~grocer_findendo)
   grocer_namex=grocer_namep(~grocer_findendo)
// grocer_namex is the vector of names other than the endogenous
// one
 
   grocer_id=grocer_arg1('id')
// grocer_id is the vector of individuals
 
   grocer_nameid=grocer_arg1('nameid')
// and grocer_nameid is their name
 
   for grocer_i=grocer_nargin:-1:2
 
      argi=strsubst(varargin(grocer_i),' ','')
 
      if part(argi,1:2) == 'x=' then
// the user has given the name of the variables, which is a subset
// of the names in the database
         grocer_namex=str2vec(argi)
         grocer_x=[]
         for grocer_j=1:size(grocer_namex0,1)
            if or(grocer_namex == grocer_namep(grocer_j)) then
               grocer_x=[grocer_x grocer_xp(grocer_j)]
            end
         end
 
      elseif part(argi,1:7) == 'nameid=' then
// the user has given the name of the individuals, which is a subset
// of the names in the database
         grocer_namedi0=grocer_nameid
         grocer_nameid=str2vec(argi)
         grocer_id=[]
         for grocer_j=1:size(grocer_nameid0,1)
            if or(grocer_nameid == grocer_nameid(grocer_j)) then
               grocer_id=[grocer_id ; grocer_xp(grocer_j)]
            end
         end
 
      elseif varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
 
      elseif varargin(grocer_i) == 'cte' then
         grocer_prescte=%t
 
      end
 
   end
 
   if grocer_prescte then
      grocer_x=[grocer_x 0*grocer_y+1]
      grocer_namex=[grocer_namex ; 'cte']
   end
 
else
 
   grocer_lx=varargin
   for grocer_i=grocer_nargin:-1:2
      argi=strsubst(varargin(grocer_i),' ','')
      if part(argi,1:3) == 'id=' then
         execstr('grocer_'+varargin(grocer_i))
         grocer_lx(grocer_i) = null()
 
      elseif part(argi,1:8) == 'defname=' then
         grocer_nameid=str2vec(argi)
         grocer_lx(grocer_i) = null()
 
      elseif argi == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
      end
   end
 
   if ~exists('grocer_nameid','local') then
      grocer_nameid='individual # '+string(vec2col(grocer_id))
   end
   [grocer_y,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvarb]=explouniv(grocer_namey,grocer_lx)
 
end
// provides the results from the regression of the vector y
// on the vector x
res=pbetween1(grocer_y,grocer_id,grocer_x)
 
res(1)($+1) = 'prests'
res(1)($+1) = 'namex'
res(1)($+1) = 'namey'
 
res('namex') = grocer_namex
res('namey') = grocer_namey
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
// prtuniv(res,foutput)
   prt_panel(res,%io(2))
end
endfunction
