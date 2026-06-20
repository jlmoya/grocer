function res=pfixed(grocer_namey,varargin)
 
// PURPOSE: Performs HAC or standard fixed effects
// estimation for panel data (for balanced or unbalanced data).
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a real (n x 1) vector or a string equal to
// the name of a time series or a (n x 1) real vector between
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
//    - 'hac=ccm' for  "clustered" covariance matrix of Arellano (1987)
//      recommended when T is fixed and N large
//      but "works" also when T is large and N fixed
//      see Hansen C. B. (2007) (reference below)
//      or 'hac=nw' for a Newey-west type estimator
//      recommended when T is large and N fixed
//      (see references)
//      or 'hac=mbb' for a moving block bootstrap etimation
//      of the symetric percentile-t confidence interval
//      of the betas
//    - 'nboot=xxx' number of bootstrap replications when
//          'hac=mbb' (default=999)
//    - 'alpha=xxx' with 0<xxx<1 the confidence level (default=0.95)
//          for the symetric percentile-t confidence interval
//    - 'win=xxx' the length of the Barlett window kernel estimator
//      (default = automatic selection by Andrews (1991) method
//        using an AR(1) model)
// ------------------------------------------------------------
// OUTPUT:
// res = a tlist with
//   . res('meth') = 'panel with fixed effects'
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
// ------------------------------------------------------------
// REFERENCE:
// * Andrews Donald W. K. (1991), "Heteroskedasticity and Autocorrelation
//     Consistent Covariance Matrix Estimation", Econometrica, 59, 817-858
// * Arellano M. (2003), "Panel Data Econometrics", ed. OUP
// * Hansen C. B. (2007), "Asymptotic Properties of a Robust Variance
//    Matrix for Panel Data when T is Large", Journal of Econometrics,
//    141, 597-620.
// * Gonçalves S. (2011), 'The moving blocks bootstrap for panel
//     linear regression models with individual fixed effects",
//     Econometric Theory, 27, 1048-1082.
// * Green W. H. (2000), "Econometric Analysis", 4th ed, Prentice Hall
// ------------------------------------------------------------
// Copyright Eric Dubois 2005 & Emmanuel Michaux 2010-2012
// http://grocer.toolbox.free.fr/grocer.html
 
grocer_prt = %t
grocer_arg1 = varargin(1)
grocer_subnameid = %f
grocer_nargin=length(varargin)
grocer_hac=0
grocer_nboot=0
grocer_alpha=0
grocer_win=[]
grocer_dropna=%f
grocer_prests=%f
 
if typeof(grocer_arg1) == 'panel data' then
 
   grocer_namep=grocer_arg1('namex')(:)
// grocer_namep is the vector of names in the data base
   grocer_findendo=(grocer_namep == grocer_namey)
 
   grocer_xp=grocer_arg1('x')
// grocer_xp is the vector of values in the data base
 
   // define the variables corresponding to the names in the panel database
   execstr(joinstr(grocer_namep,'=grocer_xp(:,',string(1:size(grocer_namep,'*')),')',';'))
   execstr('grocer_y='+grocer_namey)
   grocer_id=grocer_arg1('id')
// grocer_id is the vector of individuals
 
   grocer_nameid=grocer_arg1('nameid')
// and grocer_nameid is their name
   grocer_indnona=[]
 
   for grocer_i=grocer_nargin:-1:2
 
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if part(grocer_argi,1:2) == 'x=' then
         // the user has given the name of the variables
         grocer_namex=str2vec(grocer_argi)
         grocer_x=[]
         for grocer_j=1:size(grocer_namex,1)
            grocer_x=[grocer_x , evstr(grocer_namex(grocer_j))]
         end
      // robust covriance matrix
      elseif part(grocer_argi,1:3) == 'hac' then
         grocer_hac=part(grocer_argi,5:length(grocer_argi))
 
      elseif part(grocer_argi,1:3) == 'win' then
         execstr('grocer_'+grocer_argi)
 
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
 
      elseif part(grocer_argi,1:5) == 'alpha' then
         execstr('grocer_'+grocer_argi)
 
      elseif part(grocer_argi,1:5) == 'nboot' then
         execstr('grocer_'+grocer_argi)
 
      elseif part(grocer_argi,1:7) == 'nameid=' then
          // the user has given the name of the individuals, which is a subset
          // of the names in the database
         grocer_subnameid=%T
         grocer_nameid0=grocer_nameid
         grocer_nameid=str2vec(grocer_argi)
 
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
 
      end
 
   end
 
   if grocer_subnameid then
 
      [grocer_B,grocer_ind]=gsort(vec2col(grocer_id),'g','d')
      grocer_dB=[grocer_B(2:$)-grocer_B(1:$-1) ; 1]
      // eliminates the redundant values
      grocer_binv=grocer_B(grocer_dB ~= 0)
      // take the inverse of binv to obtain the increasing order
      grocer_uniq=grocer_binv($:-1:1)
 
      for grocer_j=1:size(grocer_nameid0,1)
         if and(grocer_nameid ~= grocer_nameid0(grocer_j)) then
            f=find(grocer_id ==grocer_uniq(grocer_j))
            grocer_id(f)=[]
            grocer_y(f)=[]
            grocer_x(f,:)=[]
 
         end
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
 
else
 
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
      elseif part(grocer_argi,1:6) == 'alpha=' then
         execstr('grocer_'+grocer_argi)
         grocer_lx(grocer_i) = null()
      elseif part(grocer_argi,1:6) == 'nboot=' then
         execstr('grocer_'+grocer_argi)
         grocer_lx(grocer_i) = null()
      elseif part(grocer_argi,1:8) == 'defname=' then
         grocer_nameid=str2vec(grocer_argi)
         grocer_lx(grocer_i) = null()
       elseif grocer_argi == 'noprint' then
         grocer_prt=%f
         grocer_lx(grocer_i) = null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         grocer_lx(grocer_i) = null()
      end
   end
 
   if ~exists('grocer_nameid','local') then
      grocer_nameid='individual # '+string(vec2col(unique(grocer_id)))
   end
   [grocer_y,grocer_namey,grocer_x,grocer_namex,grocer_prests,grocer_boundsvarb]=explouniv(grocer_namey,grocer_lx,[],['endogenous';'exogenous'],%t,grocer_dropna)
end
 
 
// provides the results from the regression of the vector y
// on the vector x
if grocer_hac==0 then
   res=pfixed1(grocer_y,grocer_id,grocer_x)
else
  if grocer_hac=='mbb' then
    if grocer_nboot==0 then
      warning('number of bootstrap replications is missing, it is set to 999')
      grocer_nboot=999
    end
 
    if grocer_alpha==0 then
      warning('confidence level for percentile-t interval is missing, it is set to 95%')
      grocer_alpha=0.95
    end
 
    res=pfixed_mbb1(grocer_y,grocer_id,grocer_x,grocer_nboot,grocer_alpha)
  else
    if grocer_hac=='ccm' then
      grocer_hac=1
    elseif grocer_hac=='nw' then
      grocer_hac=2
    end
    res=pfixed_hac1(grocer_y,grocer_id,grocer_x,grocer_hac,grocer_win)
  end
end
 
res(1)($+1) = 'prests'
res(1)($+1) = 'dropna'
res(1)($+1) = 'namex'
res(1)($+1) = 'namey'
res(1)($+1) = 'nb. indiv'
 
res('prests')=grocer_prests
res('dropna')=grocer_dropna
res('namex') = [ grocer_nameid ; grocer_namex ]
res('namey') = grocer_namey
res('nb. indiv') = size(grocer_nameid,'*')
 
if grocer_dropna then
   results(1)($+1)='nonna'
   results('nonna')=grocer_nonna
end
 
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
// a command to activate if foutput has been previously definded:
   prt_panel(res,%io(2))
end
 
endfunction
