function rvar = rolvar(grocer_p,varargin)
 
// PURPOSE: computes rolling VAR
//------------------------------------------------------------
// INPUT:
// * grocer_p = the lag length
// * varargin = arguments which can be:
//   . 'endo=[var1 var2 ... varn]' with vari: the ith
//     endogenous variable in the var
//   . 'exo=[var1 var2 ... varn]' with vari: the ith
//     exogenous variable in the var
//   . the string 'nocte' if the user doesn't want a constant
//     in the model
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . 'dropna' if the user wants to remove the NA values
//     from the data
//   . 'nper=x' where x is the number of observations kept
//     at each estimation
//   . 'nper=x' where x is the number of observations kept
//     at each estimation
//   . 'start_firstbound=x' where x is the first bound of the
//     first estimation
//   . 'end_firstbound=x' where x is the first bound of the
//     last estimation
//   . 'start_firstobs=x' where x is the first observation of
//     the first estimation
//   . 'end_firstobs=x' where x is the first observation of
//     the last estimation
//   (note that you must use either the option
//    'start_firstbound=x' along with the option
//    'end_firstbound=x' or the option 'start_firstobs=x' and
//    'end_firstobs=x'; the first option is moreover available
//    only with ts)
//------------------------------------------------------------
// OUTPUT:
// rvar = a results tlist with:
//   . rvar('meth')  = 'rolling var'
//   . rvar('yall')  = y data vector lagged data included
//   . rvar('y')     = y data vector used in the rhs parts of
//                     the VAR
//   . rvar('x')     = x data matrix
//   . rvar('nvar')  = # exogenous variables
//   . rvar('nobs')  = # observations
//   . rvar('neqs')  = # endogenous variables
//   . rvar('nlag')  = # lags in the VAR
//   . rvar('resid') = residuals, with rvar('resid')(:,i):
//                     residuals for equation # i
//   . rvar('beta')  = bhat, with rvar('beta')(:,i):
//                     coefficients for equation # i
//   . rvar('tstat') = t-stats, with rvar('tstat')(:,i):
//                     t-stat for equation # i
//   . rvar('pvalue')= pvalue of the betas, with
//                      rvar('pvalue')(:,i): p-value for
//                      equation # i
//   . rvar('rsqr')  = rsquared, with rvar('rsqr')(i) :
//                     rsquared for equation # i
//   . rvar('overallf') = F-stat for the nullity of
//                     coefficients other than the constant
//                     with: rvar('f')(i): F-stat for equation
//                     # i
//   . rvar('pvaluef') = their significance level with:
//                     rvar('pvaluef')(i): significance level
//                     for equation # i
//   . rvar('rbar')  = rbar-squared
//   . rvar('sigu')  = sums of squared residuals with
//                     rvar('sigu')(:,i): sum of squared
//                     residuals for equation # i
//   . rvar('ser')   = standard errors of the regression with
//                    rvar('ser')(i): standard error for
//                    equation # i
//   . rvar('dw')    = Durbin-Watson Statistic, with:
//                    rvar('dw')(i): DW for equation # i
//   . rvar('condindex') = multicolinearity cond index, with
//                         rvar('condindex')(i): cond index for
//                         equation # i
//   . rvar('ftes') = F-stat for the nullity of coefficients other
//          than the constant with f(i): F-stat for equation # i
//   . rvar('fvalues') = their significance level with fvalues(i):
//             significance level for equation # i
//   . rvar('boxq') = Box Q-stat, with rvar('boxq')(i):
//                    Box Q-stat for equation # i
//   . rvar('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . rvar('aic') = Akaïke information criterion
//   . rvar('bic') = Schwartz information criterion
//   . rvar('hq') = Hannan-Quinn information criterion
//   . rvar('xpxi') = inv(X'X)
//   . rvar('vcovar') = variance matrix of the vector of all
//     coefficents
//   . rvar('prescte') = boolean indicating the presence or
//     absence of a cosntant in the VAR
//   . rvar('nx') = # of exogenous variables in the VAR
//   . rvar('namey') = name of the y variable
//   . rvar('namex') = name of the x variables (if any)
//   . rvar('dropna') = boolean indicating if NAs had
//     been dropped
//   . rvar('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rvar('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
//------------------------------------------------------------
// Copyright E. Dubois (2014)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_dropna=%f
grocer_prt=%t
grocer_dates=%f
grocer_flagexo=%f
grocer_nocte=%f
 
if exists('grocer_boundsvar') then
   // get the bounds p times back, because the y variable in var1
   // is lead p times
   // transfer the boundsvar variable in the function
   // so that it can be transformed in the function
   if size(grocer_boundsvar,1) > 2 then
      error('you cannot use discountinous bounds in var')
   end
   if grocer_boundsvar ~= [] then
      grocer_boundsvar=[num2date(date2num(grocer_boundsvar(1))-grocer_p,...
                   date2fq(grocer_boundsvar(1))) ; grocer_boundsvar(2)]
   end
end
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
 
   if typeof(varargin(grocer_i)) == 'string' then
 
      grocer_st=strsubst(varargin(grocer_i),' ','')
      str4=part(grocer_st,1:4)
      str5=part(grocer_st,1:5)
      str6=part(grocer_st,1:6)
 
      if str5 == 'endo=' then
         grocer_endo=str2vec(grocer_st)
 
      elseif str4 == 'exo=' then
        grocer_exo=str2vec(grocer_st)
        grocer_flagexo=%t
 
      elseif grocer_st == 'nocte' then
         grocer_nocte = 'nocte'
 
      elseif str5 == 'nper='  then
         execstr('grocer_'+varargin(grocer_i))
 
      elseif part(grocer_st,1:17) == 'start_firstbound=' then
         grocer_dates=%t
         grocer_start_date = part(grocer_st,18:length(grocer_st))
 
      elseif part(grocer_st,1:15) == 'end_firstbound=' then
         grocer_dates=%t
         grocer_end_date = part(grocer_st,16:length(grocer_st))
 
      elseif part(grocer_st,1:15) == 'start_firstobs=' then
         execstr('grocer_first_start='+part(grocer_st,16:length(grocer_st)))
 
      elseif part(grocer_st,1:12) == 'end_lastobs=' then
         execstr('grocer_last_start='+part(grocer_st,13:length(grocer_st)))
 
      elseif str6 == 'dropna' then
         grocer_dropna = %t;
 
      elseif grocer_st == 'noprint' then
         grocer_prt=%f
 
      end
 
   else
      error('wrong type for entry number '+string(grocer_i+1))
   end
end
 
// explodes the list of the arguments into the corresponding
// variables, their names, and, if necessary creates the bounds
if grocer_flagexo then
   [y,namey,x,namex,prests,boundsvarb,nonna]=explouniv(grocer_endo,grocer_exo,[],['endogenous' 'exogenous'],%t,grocer_dropna)
 
else
   [y,namey,prests,boundsvarb,nonna]=explone(grocer_endo,[],'endogenous',%t,grocer_dropna)
   namex=[]
   x=[]
 
end
 
if grocer_nocte ~='nocte' then
   namex=[namex ; 'const']
   x=[x 0*y(:,1)+1]
end
 
if grocer_dates then
   grocer_first_start=date2num(grocer_start_date)-date2num(boundsvarb(1))+1
   grocer_last_start=date2num(grocer_end_date)-date2num(boundsvarb(1))+1
end
 
rvar=rolvar1(y,grocer_p,x,grocer_nper,grocer_first_start,grocer_last_start)
 
rvar(1)($+1)='namey'
rvar($+1)=namey
rvar(1)($+1)='namex'
rvar('namex')=namex
rvar(1)($+1)='nper'
rvar('nper')=grocer_nper
rvar(1)($+1)='first start'
rvar('first start')=grocer_first_start
rvar(1)($+1)='last start'
rvar('last start')= grocer_last_start
 
if grocer_dates then
   rvar(1)($+1)='start firstbound'
   rvar('start firstbound' )=grocer_start_date
   rvar(1)($+1)='end firstbound'
   rvar('end firstbound' )=grocer_end_date
end
 
// saves the names, the bounds if the regression involves ts
rvar(1)($+1) = 'prests'
rvar(1)($+1) = 'namex'
rvar(1)($+1) = 'namey'
rvar(1)($+1)  = 'dropna'
 
rvar('prests')=prests
rvar('namex')= namex
rvar('namey')= namey
rvar('dropna')=grocer_dropna
 
if prests then
  rvar(1)($+1) = 'bounds'
  rvar('bounds')=boundsvarb
end
 
if grocer_dropna then
   rvar(1)($+1)='nonna'
   rvar('nonna')=nonna
end
 
 
endfunction
