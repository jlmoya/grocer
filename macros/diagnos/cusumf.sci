function [rcusum]=cusumf(grocer_namey,varargin)
 
// PURPOSE: compute cusum and cusum-squares test and plots the
// tests values along with their 5% confidence bands
// ------------------------------------------------------------
// INPUT:
// * grocer_namey = a time series, a real (nx1) vector or a
// string equal to the name of a time series or a (nx1) real
// vector between quotes
// * varargin = arguments which can be:
//   . a time series
//   . a real (nx1) vector
//   . a string equal to the name of a time series or a (nx1)
//     real vector between quotes
//   . the string 'noprint' if the user doesn't want the
//     to print the results of the regression
//   . the string 'size=x' where x=0.01, 0.05 or 0.1 is the
//     size chosen for the teste (default =0.05)
//   . the string 'dropna' if the user wants to delete NAs
//     (this option should be used when dealing with daily and weekly TS)
// ------------------------------------------------------------
// OUTPUT:
// rcusum = a results tlist with:
//   . rcusum('meth')='cusum'
//   . rcusum('nobs')= # of observations
//   . rcusum('nvar')= # of variables
//   . rcusum('y')= y data vector
//   . rcusum('x')= x matrix vector
//   . rcusum('rres')= vector of recursive residuals
//   . rcusum('cusum')= cusum test
//   . rcusum('cusum_l90')= the lower value of its 90%
//     confidence interval
//   . rcusum('cusum_u90')= the upper value of its 90%
//     confidence interval
//   . rcusum('cusum_l95')= the lower value of its 95%
//     confidence interval
//   . rcusum('cusum_u95')= the upper value of its 95%
//     confidence interval
//   . rcusum('cusum_l99')= the lower value of the 99%
//     confidence interval
//   . rcusum('cusum_u99')= the upper value of the 99%
//     confidence interval
//   . rcusum('cusums')= squared cusum test
//   . rcusum('cusums_l90')= the lower value of its 90%
//     confidence interval
//   . rcusum('cusums_u90')= the upper value of its 90%
//     confidence interval
//   . rcusum('cusums_l95')= the lower value of its 95%
//     confidence interval
//   . rcusum('cusums_u95')= the upper value of its 95%
//     confidence interval
//   . rcusum('cusums_l99')= the lower value of the 99%
//     confidence interval
//   . rcusum('cusums_u99')= the upper value of the 99%
//     confidence interval
//   . rcusum('prests')=boolean indicating the presence or
//     absence of a time series in the regression
//   . rcusum('namey') = name of the y variable
//   . rcusum('namex') = name of the x variables
//   . rcusum('bounds') = if there is a timeseries in the
//     regression, the bounds of the test (which are the bounds
//     of the regression, less the k first dates)
//   . rcusum('dropna') = boolean indicating if NAs had
//		   been droped
//   . rcusum('nonna') = vector indicating position of non-NAs
// ------------------------------------------------------------
// REFERENCES: Brown, Durbin, Evans 1975 J. Royal Statistical
// Society, 'Techniques for testing the constancy of regression
// relationships over time', Series B, pp. 149-192.
// ------------------------------------------------------------
// Copyright: Eric Dubois 2002
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
grocer_size=0.05
grocer_dropna=%f
 
grocer_nargin=length(varargin)
 
for grocer_i=grocer_nargin:-1:1
   if typeof(varargin(grocer_i)) == 'string' then
      if varargin(grocer_i) == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      elseif part(varargin(grocer_i),1:4) == 'size' then
         execstr('grocer_'+varargin(grocer_i))
         varargin(grocer_i)=null()
      end
   end
end
 
[grocer_y,grocer_namey,grocer_x,grocer_namexos,grocer_prests,grocer_boundsvarb,nonna]=...
  explouniv(grocer_namey,varargin,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
u=grocer_y-grocer_x*ols0(grocer_y,grocer_x)
[nobs,k]=size(grocer_x)
df=nobs-k
sigma=sqrt(u'*u/(nobs-k))
// use recresid function to get recursive residuals
vv = recresid(grocer_y,grocer_x)
vv=vv(k+1:nobs)
s2 = sum(vv.^2);
 
w=cumsum(vv)/sigma
w2 = cumsum(vv.^2)/s2;
 
// construct bounds for test using 5 percent significance level
wu_1 = 1.143*sqrt(df)+2*1.143*[1:df]'/sqrt(df)
wl_1 = -wu_1
wu_5 = .948*sqrt(df)+2*.948*[1:df]'/sqrt(df)
wl_5 = -wu_5
wu_10 = .85*sqrt(df)+2*.85*[1:df]'/sqrt(df)
wl_10 = -wu_10
 
s=cusumsq_tab(nobs)
w2u_1=s(1)
w2u_5=s(2)
w2u_10=s(3)
 
 
w2l_10=max(-w2u_10+[1:df]'/df,0)
w2u_10=w2u_10+[1:df]'/df
w2l_5=max(-w2u_5+[1:df]'/df,0)
w2u_5=w2u_5+[1:df]'/df
w2l_1=max(-w2u_1+[1:df]'/df,0)
w2u_1=w2u_1+[1:df]'/df
 
rcusum=tlist(['results';'meth';'dir';'nobs';'nvar';'y';'x';'rres';...
'cusum';'cusum_l90';'cusum_u90';'cusum_l95';'cusum_u95';'cusum_l99';'cusum_u99';...
'cusums';'cusums_l90';'cusums_u90';'cusums_l95';'cusums_u95';'cusums_l99';'cusums_u99';...
]...
,'cusum','forward',nobs,k,grocer_y,grocer_x,vv,...
w,wl_10,wu_10,wl_5,wu_5,wl_1,wu_1,...
w2,w2l_10,w2u_10,w2l_5,w2u_5,w2l_1,w2u_1)
 
// saves the names, the bounds if the regression involves ts
rcusum(1)($+1) = 'prests'
rcusum(1)($+1) = 'namex'
rcusum(1)($+1) = 'namey'
rcusum(1)($+1) = 'dropna'
rcusum('prests')=grocer_prests
rcusum('namex')=grocer_namexos
rcusum('namey')=grocer_namey
rcusum('dropna') = grocer_dropna
if grocer_prests then
   rcusum(1)($+1) = 'bounds'
   endb=%f
// updates the bounds to take into account the nullity of
// the k first residuals
   b=date2num_m(grocer_boundsvarb)
   i=1
   while ~endb then
      b(i)=b(i)+k
      if b(i) <= b(i+1) then
         endb=%t
      else
         i=i+2
         b=b(3:size(b,1))
         k=k-(b(i+1)-b(i)+1)
         i=i+2
      end
   end
   b=num2date(b,date2fq(grocer_boundsvarb(1)))
   rcusum('bounds')=b
end
 
if grocer_dropna then
   rcusum(1)($+1)='nonna'
   rcusum('nonna')=nonna
end
 
if grocer_prt then
// the user has not entered 'noprint' as an argument
   pltcusum(rcusum,grocer_size,%io(2))
end
 
endfunction
