function [rbecm]=becm(grocer_nlag,grocer_tight,grocer_weight,grocer_decay,varargin)
 
// PURPOSE: performs bayesian error correction model estimation
// ------------------------------------------------------------
// INPUT:
// * grocer_nlag = the lag length
// * tight = Litterman's tightness hyperparameter
// * weight = Litterman's weight (matrix or scalar)
// * decay = Litterman's lag decay = lag^(-decay)
// * varargin = arguments which can be:
//   . 'endo=endo1;...;endon' where endo1,...,endon are the
//      names of the endogenous variables
//   . the string 'noprint' if the user doesn't want to
//     print the results of the regression
//   . 'jres=xx' where xx is the name of a johansen results
//       tlist (optional: if not given, is estimated by the
//       function)
//   . 'plevel=xx' where xx=0.01, 0.05 or 0.1 is the
//      significance level for the cointegrating vectors
//      (optional: if not given, is set to 0.05; useless if the
//      option 'grocer_nbr=xx' is used)
//   . 'stat_meth=asym' if the user wants to use asymptotic
//     tables to determine the # of cointegration relationships
//     instead of simulated ones obtained by bootstrap
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
// ------------------------------------------------------------
// rbecm = a results tlist with:
//   . rbecm('meth')  = 'becm'
//   . rbecm('y')     = y data vector
//   . rbecm('x')     = x data matrix
//   . rbecm('nobs')  = # observations
//   . rbecm('nvar')  = # exogenous variables
//   . rbecm('neqs')  = # endogenous variables
//   . rbecm('tight')  = Litterman's tightness hyperparameter
//   . rbecm('weight')  = Litterman's weight (matrix or scalar)
//   . rbecm('decay')  = Litterman's lag decay = lag^(-decay)
//   . rbecm('resid') = residuals, with rbecm('resid')(:,i):
//                     residuals for equation # i
//   . rbecm('beta')  = bhat, with rbecm('beta')(:,i):
//                     coefficients for equation # i
//   . rbecm('rsqr')  = rsquared, with rbecm('rsqr')(i) :
//                     rsquared for equation # i
//   . rbecm('f')     = F-stat for the nullity of coefficients
//                     other than the constant with:
//                     rbecm('f')(i): F-stat for equation # i
//   . rbecm('pvaluef') = their significance level with:
//                     rbecm('pvaluef')(i): significance level
//                     for equation # i
//   . rbecm('rbar')  = rbar-squared with rbecm('rbar')(i) :
//                     r-bar-squared for equation # i
//   . rbecm('sigu')  = sums of squared residuals with
//                     rbecm('sigu')(:,i): sum of squared
//                     residuals for equation # i
//   . rbecm('ser')   = standard errors of the regression with
//                    rbecm('ser')(i): standard error for
//                    equation # i
//   . rbecm('tstat') = t-stats, with rbecm('tstat')(:,i):
//                     t-stat for equation # i
//   . rbecm('pvalue')= pvalue of the betas, with
//                      rbecm('pvalue')(:,i): p-value for
//                      equation # i
//   . rbecm('dw')    = Durbin-Watson Statistic, with:
//                    rbecm('dw')(i): DW for equation # i
//   . rbecm('boxq') = Box Q-stat, with rbecm('boxq')(i):
//                    Box Q-stat for equation # i
//   . rbecm('sigma') = (neqs x neqs) var-covar matrix of the
//                     regression
//   . rbecm('xpxi') = inv(X'X)
//   . rbecm('prests') = boolean indicating the presence or
//     absence of a time series in the regression
//   . rbecm('namey') = name of the y variable
//   . rbecm('namex') = name of the cointegrating variables
//                    (if any) and short terme exogenous
//                    variables
//   . rbecm('nx') = # of x variables
//   . rbecm('nb_coint_relat') = # of cointegration relations
//   . rbecm('bounds') = if there is a timeseries in the
//     regression, the bounds of the regression
//   . rbecm('jres') = the result tlist from the johansen step
//   . rbecm('dropna') = boolean indicating if NAs have
//		   been dropped
//   . rbecm('evec') = matrix of cointegrating vectors
//   . rbecm('namexo_lt') = the names of the exogenous variables
//                          in the cointegration relationship
//   . rbecm('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// NOTES:
// * constant vector automatically included
// * error correction variables are automatically
//   constructed using output from Johansen's ML-estimator
// ------------------------------------------------------------
// Copyright Eric Dubois 2002-2015
// http://grocer.toolbox.free.fr/grocer.html
// translated and adapted from a Matlab program by:
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
end
 
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
         error('not an available option in becm: '+grocer_st)
      end
   else
      error(typeof(varargin(grocer_i))+': not a valid type in ecm')
   end
end
 
// explodes the list of the arguments into the corresponding
// variable, its name, and, if necessary updates the bounds
[y,namey,prests,boundsvarb,nonna]=explone(grocer_endo,[],'endogenous',%t,grocer_dropna)
nvar=size(y,2)
if grocer_wchk1 > 1 then
  grocer_zip = matrix(find(grocer_weight==0),1,-1);
  if max(size(grocer_zip))~=0 then
    error('bvar: must have weights > 0');
  elseif grocer_wchk1~=nvar then
     error('wrong size weight matrix in bvar');
  end
end
 
if ~exists('jres','local') then
   // the user has provided no johansen results tlist
   ch='johansen(grocer_nlag,'''+strcat(grocer_endo,''',''')+''''
   if ~isempty(grocer_optjohansen) then
      ch=ch+','''+strcat(grocer_optjohansen,''',''')+''''
   end
   if ~grocer_prt then
      ch=ch+',''noprint'''
   end
   ch=ch+')'
   execstr('jres='+ch)
end
 
exo_st=jres('exo_st')
 
if ~exists('grocer_nbr','local') then
   // the user has not provided the # of cointegrating vectors
   if jres('stat_meth') == 'bootstrap' then
      lr1_p = jres('p double trace');
      vaux=find([ lr1_p ; 1 ]> grocer_plevel)
      grocer_nbr=vaux(1)-1
   else
      lr1=jres('lr1')
      cvt=jres('cvt')
      col=1+bool2s(grocer_plevel == 0.05)+2*bool2s(grocer_plevel == 0.01)
      vaux=find(lr1>=cvt(:,col))
      grocer_nbr=0+vaux($)
   end
end
jres=johansen_normalize(jres,1:grocer_nbr,'noprint')
ecvectors = jres('evec');
if isempty(exo_st) then
   x=[jres('lagy')*ecvectors(:,1:grocer_nbr) ]
else
   x=[jres('lagy')*ecvectors(:,1:grocer_nbr) exo_st]
end
 
b_st2lt=[]
if grocer_st2lt then
   exo_str=jres('exo_st')(jres('nlags')+2:$,:)
   b_st2lt=ols0(x(:,1:grocer_nbr),exo_str)
   x(:,1:grocer_nbr)=[x(:,1:grocer_nbr)-exo_str*b_st2lt]
end
 
dy=y(2:$,:)-y(1:$-1,:)
// call VAR using 1st difference and co-integrating variables
// call depends on whether we have an x-matrix or not
rbecm=bvar1(grocer_nlag,grocer_tight,grocer_weight,grocer_decay,dy,x)
 
rbecm('meth')='becm'
rbecm(1)($+1)='namey'
rbecm('namey')='del('+namey+')'
rbecm(1)($+1)='namex'
namex=jres('namexo_st')
indconst=search_cte(exo_st)
rbecm('prescte')=~isempty(indconst)
if grocer_nbr >0 then
   namex=[ 'lag 1 of coint. vec. #'+string([1:grocer_nbr])' ; namex  ]
end
rbecm('namex')=namex
 
rbecm(1)($+1)='prests'
rbecm('prests')=prests
rbecm(1)($+1)='nb_coint_relat'
rbecm('nb_coint_relat')=grocer_nbr
rbecm('nx')=size(namex,1)
 
rbecm(1)($+1)='jres'
rbecm('jres')=jres
rbecm(1)($+1)='dropna'
rbecm('dropna')=grocer_dropna
rbecm(1)($+1)='evec'
rbecm('evec')=[ecvectors(:,1:grocer_nbr) ; -b_st2lt]
rbecm(1)($+1)='namexo_lt'
if grocer_st2lt then
   rbecm('namexo_lt')=[jres('namexo_lt') ; jres('namexo_st')]
else
   rbecm('namexo_lt')=jres('namexo_lt')
end
 
if prests then
   rbecm(1)($+1)='bounds'
   rbecm('bounds')=[num2date(date2num(boundsvarb(1))+grocer_nlag,...
              date2fq(boundsvarb(1))) ; boundsvarb(2)]
end
 
if grocer_dropna then
   rbecm(1)($+1)='nonna'
   rbecm('nonna')=nonna
end
 
 
if grocer_prt then
// print the rbecm
   prtecm(rbecm,%io(2))
end
 
endfunction
