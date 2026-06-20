function res = li_mcleod(grocer_y,grocer_p,varargin)
 
// PURPOSE: computes the Li-Mac Leod Q test of
// squared autocorrelations for a vector or the residuals
// of a tlist
//--------------------------------------------------------
// INPUT
// * grocer_y  = a vector, a ts between quotes or not or a
//   results tlist
// * grocer_p  = a scalar, the # of autocorrelations
//   considered
// * varargin = optional arguments that can be:
//   . 'noplt' if the user does not want to plot the
//     autocorrelations
//   . 'noprint' if the user does not want to print the
//     results of the test
//   . 'size=x' if the user wants to choose the size of
//     the autocorrelation confidence band (defaut = 0.05)
//   . 'styleg=x' with x between 1 and 7 if the user wants
//     to choose the location of the legend for the
//     graph of autocorrelations (default = 7, that is to
//     the right of the graph)
//   . 'dropna' if the user wants to remove the NA values
//     from the data
//--------------------------------------------------------
// OUTPUT:
// * res = a results tlist with:
//   . res('meth')   = 'Li McLeod'
//   . res('y')      = values of the input variable
//    (residuals in the case of a tlist)
//   . res('acf')   = autocorrelation coefficients
//   . res('acf_l') = low bound of the confidence interval
//   . res('acf_u') = upper bound of the confidence interval
//   . res('size') = size of the confidence band
//   . res('chistat') = Ljung-Box (or Box-Pierce) chi-
//     squared
//   . res('chi_pvalue') = the p-value of the test
//   . res('chi_df') = the # of degrees of freedom
//   . res('namey') = name of the variable tested
//   . res('prests') = a boolean indicating whether the
//     tested variable is a ts
//   . res('bounds') =  the estimation period (if the
//     variable was a ts)
//   . res('dropna') = boolean indicating if NAs have
//     been dropped
//   . res('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
//--------------------------------------------------------
// Copyright : E. Dubois (2007)
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_plt=%t
grocer_prt=%t
grocer_size=0.05
grocer_styleg=[]
grocer_dropna=%f
 
nargin=length(varargin)
for grocer_i=1:nargin
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if grocer_argi == 'noplt' then
         grocer_plt=%f
      elseif part(grocer_argi,1:5) == 'size=' | ...
         part(varargin(grocer_i),1:7) == 'styleg=' then
         execstr('grocer_'+varargin(grocer_i))
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
      else
         error('not a suitable option: '+varargin(grocer_i))
      end
   else
      error(typeof(varargin(grocer_i))+' is not authorized in acf for entry '+string(varargin(grocer_i)))
   end
end
df=grocer_p
 
typ=typeof(grocer_y)
 
if typ == 'results' then
   namey='residuals from a '+grocer_y('meth')+' estimation'
   prests=grocer_y('prests')
   if prests then
      boundsvarb=grocer_y('bounds')
   end
   grocer_y=grocer_y('resid').^2
 
else
   [grocer_y,namey,prests,boundsvarb,nonna]=explone(grocer_y,[],'variable',%t,grocer_dropna)
 
end
 
grocer_y=grocer_y.^2
 
n=size(grocer_y,1)
res=acf1(grocer_y,grocer_p,grocer_size)
q=sum(res('acf').^2*n*(n+2)./(n-[1:grocer_p]'))
 
res('meth')='Li McLeod'
pvalue=1-cdfchi("PQ",q,grocer_p)
res(1)($+1)='chistat'
res(1)($+1)='chi_pvalue'
res(1)($+1)='chi_df';
res($+1)=q
res($+1)=pvalue
res($+1)=df
 
res(1)($+1)='namey'
res(1)($+1)='prests'
res($+1)=namey
res($+1)=prests
 
res(1)($+1)='dropna'
res('dropna')=grocer_dropna
 
if prests then
   res(1)($+1) = 'bounds'
   res('bounds')=boundsvarb
end
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
if grocer_plt then
   if grocer_styleg == [] then
      pltacf(res)
   else
      pltacf(res,'styleg='+string(grocer_styleg))
   end
end
 
if grocer_prt then
   prtchi(res)
end
 
endfunction
