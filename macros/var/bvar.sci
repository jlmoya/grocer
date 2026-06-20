function [rbvar]=bvar(grocer_nlag,grocer_tight,grocer_weight,grocer_decay,varargin)
 
// PURPOSE: Performs a Bayesian vector autoregression of order
// grocer_nlag
// ------------------------------------------------------------
// INPUT:
// * grocer_nlag = the lag length
// * grocer_tight = Litterman's tightness hyperparameter
// * grocer_weight = Litterman's weight (matrix or scalar)
// * grocer_decay = Litterman's lag decay = lag^(-decay)
// * varargin = arguments which can be:
//   . 'endo=[var1;var2; ... ;varn]' with vari: the ith
//     endogenous variable in the var
//   . 'exo=[var1;var2;...;varn]' with vari: the ith
//     exogenous variable in the var
//   . the string 'noprint' if the user doesn't want to
//     print the results of the regression
//   . the string 'noconst' if there should be no constant in
//     the VAR
// ------------------------------------------------------------
// OUTPUT:
// rbvar = a results tlist with:
//   . rbvar('meth')  = 'bvar'
//   . rbvar('y')     = y data vector
//   . rbvar('x')     = x data matrix
//   . rbvar('nobs')  = # observations
//   . rbvar('nvar')  = # exogenous variables
//   . rbvar('tight')  = Litterman's tightness hyperparameter
//   . rbvar('weight')  = Litterman's weight (matrix or scalar)
//   . rbvar('decay')  = Litterman's lag decay = lag^(-decay)
//   . rbvar('neqs')  = # endogenous variables
//   . rbvar('resid') = residuals, with rbvar('resid')(:,i):
//                     residuals for equation # i
//   . rbvar('beta')  = bhat, with rbvar('beta')(:,i):
//                     coefficients for equation # i
//   . rbvar('rsqr')  = rsquared, with rbvar('rsqr')(i) :
//                     rsquared for equation # i
//   . rbvar('overallf')     = F-stat for the nullity of
//                     coefficients other than the constant
//                     with: rbvar('f')(i): F-stat for equation
//                     # i
//   . rbvar('pvaluef') = their significance level with:
//                     rbvar('pvaluef')(i): significance level
//                     for equation # i
//   . rbvar('rbar')  = rbar-squared
//   . rbvar('sigu')  = sums of squared residuals with
//                     rbvar('sigu')(:,i): sum of squared
//                     residuals for equation # i
//   . rbvar('ser')   = standard errors of the regression with
//                    rbvar('ser')(i): standard error for
//                    equation # i
//   . rbvar('tstat') = t-stats, with rbvar('tstat')(:,i):
//                     t-stat for equation # i
//   . rbvar('pvalue')= pvalue of the betas, with
//                      rbvar('pvalue')(:,i): p-value for
//                      equation # i
//   . rbvar('dw')    = Durbin-Watson Statistic, with:
//                    rbvar('dw')(i): DW for equation # i
//   . rbvar('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . rbvar('nx') = # of x variables
//   . rbvar('xpxi') = inv(X'X)
//   . rbvar('namey') = name of the y variable
//   . rbvar('namex') = name of the x variables (if agrocer_ny)
//   . rbvar('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rbvar('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
// ------------------------------------------------------------
// NOTE:  constant vector automatically included
// ------------------------------------------------------------
// Copyright Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
if grocer_nlag<1 then
  error('Lag length less than 1 in bvar');
end
 
nx=0
grocer_dropna=%f
grocer_prt=%t
grocer_const=%t
grocer_flagexo=%f
grocer_lx=list()
 
if exists('grocer_boundsvar') then
   if size(grocer_boundsvar,1) > 2 then
      error('you cannot use discountinous bounds in bvar')
   end
end
 
// check the validity of the parameters given by the user
if grocer_tight<.01 then
  warning('Tightness less than 0.01 in bvar');
end
 
if grocer_tight>1 then
  warning('Tightness greater than unity in bvar');
end
 
if grocer_decay<0 then
  error('Negative lag decay in bvar');
end
 
[grocer_wchk1,grocer_wchk2] = size(grocer_weight);
if grocer_wchk1~=grocer_wchk2 then
  error('non-square weight matrix in bvar');
end
 
// check for zeros in weight matrix
if grocer_wchk1==1 then
  if grocer_weight==0 then
    error('bvar: must have weight > 0');
  end
elseif grocer_wchk1>1 then
  grocer_zip = matrix(find(grocer_weight==0),1,-1);
  if max(size(grocer_zip))~=0 then
    error('bvar: must have weights > 0');
  end
end
 
 
nargin=length(varargin)
for grocer_i=1:nargin
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_st=strsubst(varargin(grocer_i),' ','')
 
      if part(grocer_st,1:5) == 'endo=' then
         grocer_ly=str2vec(grocer_st)
 
      elseif part(grocer_st,1:4) == 'exo=' then
         grocer_lx=str2vec(grocer_st)
         grocer_flagexo=%t
 
      elseif grocer_st == 'noprint' then
         grocer_prt=%f
 
      elseif or(grocer_st == ['noconst';'nocte']) then
         grocer_const=%f
 
      elseif grocer_st == 'dropna' then
         grocer_dropna = %t
 
      else
         error(typeof(varargin(grocer_i))+': not a valid type in bvar')
      end
   end
end
 
if grocer_flagexo | grocer_const then
    if grocer_const then
       if isempty(grocer_lx) then
          grocer_lx='const'
       else
          grocer_lx($+1)='const'
       end
    end
   [y,namey,x,namex,prests,boundsvarb]=explouniv(grocer_ly,grocer_lx,[],['endoegnous';'exogenous'],%t,grocer_dropna,%f,[grocer_nlag;0])
   nvar=size(y,2)
   if grocer_wchk1>1 & grocer_wchk1~=nvar then
         error('wrong size weight matrix in bvar');
   end
   rbvar = bvar1(grocer_nlag,grocer_tight,grocer_weight,grocer_decay,y,x)
   rbvar(1)($+1)='namey'
   rbvar($+1)=namey
   rbvar(1)($+1)='namex'
   rbvar($+1)=namex
 
else
   if exists('grocer_boundsvar') then
      // get the bounds p times back, because the y variable in var1
      // is lead p times
      // transfer the boundsvar variable in the function
      // so that it can be transformed in the function
      if grocer_boundsvar ~= [] then
         grocer_boundsvar=[num2date(date2num(grocer_boundsvar(1))-grocer_nlag,...
                   date2fq(grocer_boundsvar(1))) ; grocer_boundsvar(2)]
      end
   end
 
   [y,namey,prests,boundsvarb]=explone(grocer_ly)
   nvar=size(y,2)
   if grocer_wchk1>1 & grocer_wchk1~=nvar then
         error('wrong size weight matrix in bvar');
   end
   rbvar = bvar1(grocer_nlag,grocer_tight,grocer_weight,grocer_decay,y)
   rbvar(1)($+1)='namey'
   rbvar($+1)=namey
   rbvar(1)($+1)='namex'
   rbvar($+1)=[]
 
end
 
rbvar(1)($+1)='prests'
rbvar($+1)=prests
 
if prests then
   rbvar(1)($+1)='bounds'
   rbvar($+1)=[num2date(date2num(boundsvarb(1))+grocer_nlag,...
              date2fq(boundsvarb(1))) ; boundsvarb(2)]
end
 
if grocer_prt then
   prtvar(rbvar,%io(2))
end
endfunction
