function [recm]=ecm(grocer_nlag,varargin)
 
// PURPOSE: performs error correction model estimation
// ------------------------------------------------------------
// INPUT:
// * grocer_nlag = the lag length
// * varargin = a string which can be:
//   . 'endo=endo1;...;endon' where endo1,...,endon are the
//      names of the endogenous variables
//   . 'jres=xx' where xx is the name of a johansen results
//               tlist (optional: if not given, is estimated by
//               the function)
//   . 'stat_meth=asym' if the user wants to use asymptotic
//     tables to determine the # of cointegration relationships
//     instead of simutaed ones obtained by bootstrap
//   . 'Nboot=xx' where xx is the number of bootstrap
//      replications in the johansen method (default =999)
//   . 'exo_st=exo1;..,exok' where exo1,...,exok are variables
//     entering the johansen estimation equations in the short
//     run dynamic (needed if the user does not use the option
//     'jrex=xx'; if needed constant must be one of the exoi
//     variables)
//   . 'exo_lt=exo1;..,exok' where exo1,...,exok are variables
//     entering the johansen estimation equations in the
//     cointegration relationships (needed if the user does not
//     use the option 'jrex=xx')
//   . 'st2lt' if the user wants to add the exogenous variables
//     in the short run relation to the long run relationship
//   . 'nbr=xx' where xx is the # of cointegration vectors to
//     keep from the johansen estimation (optional: if not
//     given, is calculated by the function with a level equal
//     to plevel)
//   . 'plevel=xx' where xx=0.01, 0.05 or 0.1 is the
//     significance level for the cointegrating vectors
//     (optional: if not given, is set to 0.05; useless if the
//     option 'nbr=xx' is used)
//   . 'dropna' if the user wants to exclude dates containing
//     NA values
//   . 'noprint' if the user does not want to print the
//      estimation results
// ------------------------------------------------------------
// OUTPUT:
// recm = a recm tlist with:
//   . recm('meth')  = 'ecm
//   . recm('y')     = y data vector
//   . recm('x')     = x data matrix
//   . recm('nobs')  = # observations
//   . recm('nvar')  = # exogenous variables
//   . recm('neqs')  = # endogenous variables
//   . recm('resid') = residuals, with recm('resid')(:,i):
//                     residuals for equation # i
//   . recm('beta')  = bhat, with recm('beta')(:,i):
//                     coefficients for equation # i
//   . recm('tstat') = t-stats, with recm('tstat')(:,i):
//                     t-stat for equation # i
//   . recm('pvalue')= pvalue of the betas, with
//                      recm('pvalue')(:,i): p-value for
//                      equation # i
//   . recm('rsqr')  = rsquared, with recm('rsqr')(i) :
//                     rsquared for equation # i
//   . recm('overallf') = F-stat for the nullity of
//                     coefficients other than the constant
//                     with: recm('f')(i): F-stat for equation
//                     # i
//   . recm('pvaluef') = their significance level with:
//                     recm('pvaluef')(i): significance level
//                     for equation # i
//   . recm('rbar')  = rbar-squared
//   . recm('sigu')  = sums of squared residuals with
//                     recm('sigu')(:,i): sum of squared
//                     residuals for equation # i
//   . recm('ser')   = standard errors of the regression with
//                    recm('ser')(i): standard error for
//                    equation # i
//   . recm('dw')    = Durbin-Watson Statistic, with:
//                    recm('dw')(i): DW for equation # i
//   . recm('condindex') = multicolinearity cond index, with
//                         recm('condindex')(i): cond index for
//                         equation # i
//   . recm('boxq') = Box Q-stat, with recm('boxq')(i):
//                    Box Q-stat for equation # i
//   . recm('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . recm('aic') = Aka�ke information criterion
//   . recm('bic') = Schwartz information criterion
//   . recm('hq') = Hannan-Quinn information criterion
//   . recm('namey') = name of the y variable
//   . recm('nx') = # of x variables
//   . recm('namex') = name of the cointegration relations
//     (if any)
//   . recm('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . recm('nb_coint_relat') = # of cointegration relations
//   . recm('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . recm('jres') = the result tlist from the johansen step
//   . recm('dropna') = boolean indicating if NAs have
//		   been dropped
//   . recm('evec') = matrix of cointegrating vectors
//   . recm('namexo_lt') = the names of the exogenous variables
//                          in the cointegration relationship
//   . recm('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// NOTES:
// * constant vector automatically included
// * x-matrix of exogenous variables not allowed
// * error correction variables are automatically
//         constructed using output from Johansen's ML-estimator
// ---------------------------------------------------
// Copyright Eric Dubois 2002-2009
// http://grocer.toolbox.free.fr/grocer.html
// adapted from:
// James P. LeSage, Dept of Economics
// University of Toledo
// 2801 W. Bancroft St,
// Toledo, OH 43606
// jpl@jpl.econ.utoledo.edu
 
// set defaults
grocer_plevel=0.05
grocer_prt=%t
grocer_t=0
grocer_dropna=%f
grocer_optjohansen=[]
grocer_st2lt=%f
 
 
// separates from the list of variable arguments the list of endogenous variables
// and the options
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_st=strsubst(varargin(grocer_i),' ','')
      str3=part(grocer_st,1:3)
      str4=part(grocer_st,1:4)
      str6=part(grocer_st,1:6)
      grocer_str7=part(strsubst(grocer_st,' ',''),1:7)
 
      if or(grocer_str7 == ['exo_lt=';'exo_st=']) then
         grocer_optjohansen=[grocer_optjohansen ; varargin(grocer_i)]
      elseif str6 == 'NBoot=' then
         grocer_optjohansen=[grocer_optjohansen ; varargin(grocer_i)]
         execstr('grocer_'+grocer_argin)
      elseif part(grocer_st,1:10) == 'stat_meth=' then
         grocer_optjohansen=[grocer_optjohansen ; grocer_st]
      elseif str4 == 'jres' | str3 == 'nbr' | str6 == 'plevel' then
         execstr('grocer_'+varargin(grocer_i))
      elseif grocer_st == 'noprint' then
          grocer_prt=%f
      elseif part(grocer_st,1:5) == 'endo=' then
         grocer_endo=str2vec(varargin(grocer_i))
      elseif grocer_st == 'dropna' then
         grocer_optjohansen=[grocer_optjohansen ; 'dropna']
         grocer_dropna = %t
      elseif grocer_st == 'st2lt' then
         grocer_st2lt = %t
      else
         error('not an available option in ecm: '+grocer_st)
      end
   else
      error(typeof(varargin(grocer_i))+': not a valid type in ecm')
   end
end
 
if ~exists('grocer_jres','local') then
   // the user has provided no johansen results tlist
   ch='johansen(grocer_nlag,'''+strcat(grocer_endo,''',''')+''','''+...
      strcat(grocer_optjohansen,''',''')+''''
   if ~grocer_prt then
      ch=ch+',''noprint'''
   end
   ch=ch+')'
   execstr('grocer_jres='+ch)
end
 
exo_st=grocer_jres('exo_st')
if ~exists('grocer_nbr','local') then
   // the user has not provided the # of cointegrating vectors
   if grocer_jres('stat_meth') == 'bootstrap' then
      lr1_p = grocer_jres('p double trace');
      vaux=find([ lr1_p ; 1 ]> grocer_plevel)
      grocer_nbr=vaux(1)-1
   else
      lr1=grocer_jres('lr1')
      cvt=grocer_jres('cvt')
      col=1+bool2s(grocer_plevel == 0.05)+2*bool2s(grocer_plevel == 0.01)
      vaux=find(lr1>=cvt(:,col))
      grocer_nbr=0+vaux($)
   end
end
 
grocer_jres=johansen_normalize(grocer_jres,1:grocer_nbr,'noprint')
ecvectors = grocer_jres('evec');
 
if exists('grocer_boundsvar') then
   if ~isempty(grocer_boundsvar) then
      grocer_nbounds=size(grocer_boundsvar,'*')/2
      grocer_boundsvarnum=grocer_boundsvarnum // copy the variable as a local one
      grocer_boundsvarnum(1:(grocer_nbounds-1)*2+1)=grocer_boundsvarnum(1:(grocer_nbounds-1)*2+1)-grocer_nlag-1
      grocer_boundsvar=num2date(grocer_boundsvarnum,grocer_boundsfq)
   end
end
 
// explodes the list of the arguments into the corresponding
// variable, its name, and, if necessary updates the bounds
[y,namey,prests,boundsvarb,nonna]=explone(grocer_endo,[],'endogenous',%t,grocer_dropna,%f,0)
 
[nobs,neqs] = size(y);
 
 
if isempty(exo_st) then
   x=[grocer_jres('lagy')*ecvectors(:,1:grocer_nbr) ]
else
   x=[grocer_jres('lagy')*ecvectors(:,1:grocer_nbr) exo_st]
end
 
b_st2lt=[]
if grocer_st2lt then
   b_st2lt=ols0(x(:,1:grocer_nbr),exo_st)
   x(:,1:grocer_nbr)=[x(:,1:grocer_nbr)-exo_st*b_st2lt]
end
dy=y(2:nobs,:)-y(1:nobs-1,:)
recm=var1(dy,grocer_nlag,x,'nocte')
recm(1)($+1)='namey'
recm('namey')='del('+namey+')'
recm(1)($+1)='namex'
namex=[]
if grocer_nbr >0 then
   namex=['lag 1 of coint. vec. #'+string([1:grocer_nbr]') ]
end
namex=[namex ; grocer_jres('namexo_st')]
indconst=search_cte(exo_st)
recm('prescte')=~isempty(indconst)
recm('namex')=namex
 
recm(1)($+1)='prests'
recm('prests')=prests
recm('meth')='ecm'
recm(1)($+1)='nb_coint_relat'
recm('nb_coint_relat')=grocer_nbr
recm(1)($+1)='jres'
recm('jres')=grocer_jres
recm(1)($+1)='dropna'
recm('dropna')=grocer_dropna
recm(1)($+1)='evec'
recm('evec')=[ecvectors(:,1:grocer_nbr) ; -b_st2lt]
recm(1)($+1)='namexo_lt'
if grocer_st2lt then
   recm('namexo_lt')=[grocer_jres('namexo_lt') ; grocer_jres('namexo_st')]
else
   recm('namexo_lt')=grocer_jres('namexo_lt')
end
 
if prests then
   recm(1)($+1)='bounds'
   recm('bounds')=[num2date(date2num(boundsvarb(1))+grocer_nlag+1,...
              date2fq(boundsvarb(1))) ; boundsvarb(2)]
end
 
if grocer_dropna then
   recm(1)($+1)='nonna'
   recm('nonna')=nonna
end
 
if grocer_prt then
   prtecm(recm,%io(2))
end
 
endfunction
