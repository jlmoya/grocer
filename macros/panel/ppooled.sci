function res=ppooled(grocer_namey,varargin)
 
// PURPOSE: Performs HAC or standard pooled effect estimation
//  for panel data (for balanced or unbalanced data).
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
//      * 'x=name1;...;namep' where name1,...,namep are
//      a subset of the names of the variables that are in the
//      database
//      * the string 'cte' if the user does not want to
//      add a constant to the regression
//      * the string 'noprint' if the user does not want to
//      print the estimation results
//   - if first input of varargin was an endogenous variable
//   then either:
//      * a time series
//      * a real (nxk) matrix
//      * a (kx1) string vector of names of time series, vectors
//      or matrices
//      * the string 'noprint' if the user doesn't want the
//      to print the results of the regression
//    - 'hac=ccm' for  "clustered" covariance matrix of Arellano (1987)
//      recommended when T is fixed and N large
//      but "works" also when T is large and N fixed
//      see Hansen C. B. (2007) (reference below)
//      or 'hac=nw' for a Newey-west type (Driscoll-Kraay) estimator
//      recommended when T is large and N fixed
//      In that cases the string 'id=v' a (T x 1) index vector that
//      identifies each observation with an individualmust be given
//      somewhere  when calling the function. It can be in the panel
//      tlist or an argument of the function
//   - 'win=n' the length of the Barlett window kernel estimator
//      (default = automatic selection by Andrews (1991) method
//        using an AR(1) model)
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth')  = 'panel pooled'
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
//   . res('sigu')  = sum of squared residuals
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
//   . res('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . res('namey') = name of the y variable
//   . res('namex') = name of the x variables
// ------------------------------------------------------------
// copyright Eric Dubois (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
// [grocer_nargout,grocer_nargin]=argn(0)
 
grocer_prt=%t
grocer_prescte=%F
grocer_hac=0
grocer_id=[]
grocer_win=[]
grocer_dropna=%f
 
grocer_arg1=varargin(1)
grocer_nargin=length(varargin)
if typeof(grocer_arg1) == 'panel data' then
 
   grocer_prests=%t
   grocer_nargin=length(varargin)
 
// grocer_namep is the vector of names in the data base
   grocer_namep=grocer_arg1('namex')(:)
   grocer_findendo=(grocer_namep == grocer_namey)
 
   grocer_xp=grocer_arg1('x')
// grocer_x is the vector of values in the data base
 
   execstr(grocer_namep'+'=grocer_xp(:,'+string(1:size(grocer_namep,'*'))+')')
   execstr('grocer_y='+grocer_namey)
   const=1+0*grocer_y
 
   cte=const
 
   grocer_id=grocer_arg1('id')
// grocer_id is the vector of individuals
 
   grocer_nameid=grocer_arg1('nameid')
// and grocer_nameid is their name
 
   for grocer_i=grocer_nargin:-1:2
      grocer_argi=strsubst(varargin(grocer_i),' ','')
 
      if part(grocer_argi,1:2) == 'x=' then
        // the user has given the name of the variables, which is a subset
         // of the names in the database
         // the user has given the name of the variables
         grocer_namex=str2vec(grocer_argi)
         grocer_argi=strsubst(grocer_argi,';',',')
         grocer_argi=strsubst(grocer_argi,'=','=[')+']'
         execstr('grocer_'+grocer_argi)
 
         // robust covariance matrix
      elseif part(grocer_argi,1:3) == 'hac' then
         grocer_hac=part(grocer_argi,5:length(grocer_argi))
 
      elseif part(grocer_argi,1:3) == 'win' then
         execstr('grocer_'+grocer_argi)
 
      elseif part(grocer_argi,1:7) == 'nameid=' then
        // the user has given the name of the individuals, which is a subset
        // of the names in the database
         grocer_subnameid=%T
         grocer_nameid0=grocer_nameid
         grocer_nameid=str2vec(grocer_argi)
 
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
 
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
 
      elseif or(grocer_argi == ['cte','const']) then
         grocer_prescte=%t
 
      end
   end
 
   grocer_findendo=(grocer_namep == grocer_namey)
   if isempty(grocer_findendo) then
      if isempty(grocer_namex) then
         error('when the endogenous variable is derived from the name of a variable, you should enter the names of the exogenous ones with option ''x=...''')
      end
   else
      grocer_y=grocer_xp(:,grocer_findendo)
      grocer_x=grocer_xp(:,~grocer_findendo)
      grocer_namex=grocer_namep(~grocer_findendo)
 
   end
 
   if or(isnan([grocer_y grocer_x])) then
      if grocer_dropna then
         grocer_indonna=find(sum(isnan([grocer_y grocer_x]),'c') == 0)
         grocer_y=grocer_y(grocer_indonna)
         grocer_x=grocer_x(grocer_indonna,:)
         grocer_id=grocer_id(grocer_indonna,:)
      else
         error('there are %nan values in your panel data')
      end
   end
 
   if grocer_prescte then
      grocer_x=[grocer_x 0*grocer_y+1]
      grocer_namex=[grocer_namex ; 'const']
   end
 
else
// for a pooled estimation data have the same shape as for an ols estimation
   grocer_lx=varargin
   for grocer_i=grocer_nargin:-1:2
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if part(grocer_argi,1:3) == 'id=' then
         execstr('grocer_'+grocer_argi)
         grocer_lx(grocer_i) = null()
      elseif part(grocer_argi,1:4) == 'hac=' then
         execstr('grocer_'+part(grocer_argi,1:3)+'=str2vec(grocer_argi)')
         grocer_lx(grocer_i) = null()
      elseif part(grocer_argi,1:4) == 'win=' then
         execstr('grocer_'+grocer_argi)
         grocer_lx(grocer_i) = null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
      end
   end
 
 
   [grocer_y,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvarb]=explouniv(grocer_namey,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
end
 
 
// provides the results from the regression of the vector y
// on the vector x
if grocer_hac==0 then
  res=ppooled1(grocer_y,grocer_x)
 
 
else
  if grocer_hac=='ccm' then
    grocer_hac=1
  elseif grocer_hac=='nw' then
    grocer_hac=2
  end
 
 
  if length(grocer_id)==0 then
    error('the vector of individuals attached to the y and x data is missing');
  end
  res=ppooled_hac1(grocer_y,grocer_id,grocer_x,grocer_hac,grocer_win)
end
 
res(1)($+1) = 'prests'
res(1)($+1) = 'namey'
res(1)($+1) = 'namex'
res('prests')=grocer_prests
res('namey')=grocer_namey
res('namex')=grocer_namex
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
   prt_panel(res,%io(2))
end
 
 
endfunction
