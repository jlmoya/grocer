function res = ljungbox(grocer_y,grocer_p,varargin)
 
// PURPOSE: computes the Ljung-Box Q test of
// autocorrelation for a vector or the residuals of a
// results tlist
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
//   . 'meth=Box-Pierce' if the user wants to use the
//     Box-Pierce formula instead of the Ljung-Box one
//   . 'size=x' if the user wants to choose the size of
//     the autocorrelation confidence band (default = 0.05)
//   . 'styleg=x' with x between 1 and 7 if the user wants
//     to choose the location of the legend for the
//     graph of autocorrelations (default = 7, that is to
//     the right of the graph)
//   . 'corrdf=x' whther x is the number to subtract from
//     the entered # of autocorrelations to obtain the
//     correct # of degrees of freedom for the test
//     statistic (default = " of AR and MA parameters for
//     an arma model, 0 in other cases)
//   . 'dropna' if the user wants to remove the NA values
//     from the data
//--------------------------------------------------------
// OUTPUT:
// * res = a results tlist with:
//   . res('meth')   = 'Ljung-Box' or 'Box-Pierce'
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
grocer_meth='Ljung-Box'
 
nargin=length(varargin)
for grocer_i=1:nargin
   if typeof(varargin(grocer_i)) == 'string' then
      grocer_argi=strsubst(varargin(grocer_i),' ','')
      if grocer_argi == 'noplt' then
         grocer_plt=%f
      elseif grocer_argi == 'noprint' then
         grocer_prt=%f
      elseif part(varargin(grocer_i),1:7) == 'styleg=' |...
           part(grocer_argi,1:5) == 'meth='  |...
           part(grocer_argi,1:5) == 'size=' | ...
           part(grocer_argi,1:7) == 'corrdf=' then
 
         execstr('grocer_'+varargin(grocer_i))
 
      elseif varargin(grocer_i) == 'dropna' then
         grocer_dropna=%t
 
      else
         error('not a suitable option: '+varargin(grocer_i))
      end
   else
      error(typeof(varargin(grocer_i))+' is not authorized in ljungbox for entry '+string(varargin(grocer_i)))
   end
end
 
typ=typeof(grocer_y)
if typ == 'results' then
   if grocer_y('meth') == 'varma' then
       if ~exists('grocer_corrdf','local') then
          grocer_corrdf=size(grocer_y('AR'),'*')+size(grocer_y('ARS'),'*')...
          +size(grocer_y('MA'),'*')+size(grocer_y('MAS'),'*')
      end
      df=grocer_p-grocer_corrdf
      if df <= 0 then
         write(%io(2),'error: if ljungbox is applied after varma, arg 2 must be greater than the sum of the AR and MA param','(a)')
         abort
      end
   elseif ~exists('grocer_corrdf','local') then
      grocer_corrdf=0
   end
 
   df=grocer_p-grocer_corrdf
   namey='residuals from '+grocer_y('meth')+' estimation'
   prests=grocer_y('prests')
   if prests then
      boundsvarb=grocer_y('bounds')
   end
   grocer_y=grocer_y('resid')
 
else
   [grocer_y,namey,prests,boundsvarb,nonna]=explone(grocer_y,[],'variable',%t,grocer_dropna)
   if ~exists('grocer_corrdf','local') then
      grocer_corrdf=0
   end
   df=grocer_p-grocer_corrdf
end
 
n=size(grocer_y,1)
res=acf1(grocer_y,grocer_p,grocer_size)
select grocer_meth
case 'Ljung-Box' then
   q=sum(res('acf').^2*n*(n+2)./(n-[1:grocer_p]'))
 
case 'Box-Pierce' then
   q=sum(res('acf').^2)*n
 
else
   error('not an available option: '+grocer_meth)
end
 
res('meth')=grocer_meth
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
