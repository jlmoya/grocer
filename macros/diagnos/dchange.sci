function rdchange = dchange(grocer_y,grocer_yc,varargin)
 
// PURPOSE: compute test of accuracy of forecast of
// direction of change
// ------------------------------------------------------------
// INPUT:
// * grocer_y  = vector or ts of observable or benchmark series
// * grocer_yc = vector or ts of competiting or forecasted
//   series
// * varargin = arguments which can be:
//   . the string 'noprint' if the user doesn't want to print
//     the results of the regression
//   . the string 'dropna' if the user wants to remove the NA
//     values from the data
// ------------------------------------------------------------
// OUTPUT:
// rchange = a result tlist
//    . rchange('meth')   = 'direct. change'
//    . rchange('y')      = benchmark or observable series
//    . rchange('yc')     = competiting series or forecasted
//      series
//    . rchange('namey')  = name of benchmark or observable
//      series
//    . rchange('nameyc') = name of competiting series or
//      forecasted series
//    . rchange('P')      = proportion of time the sign of the
//      observable value is correctly forecasted
//    . rchange('Pstar')  = concordance index
//    . rchange('pvalue') = pvalue of the statistic
//    . rchange('dropna') = boolean indicating if NAs have
//		    been dropped
//    . rchange('nonna') = vector indicating position of
//     non-NA values (if the option 'dropna' was active)
// ------------------------------------------------------------
// REFERENCE:
// M. Hashem Pesaran & A. Timmermann (1992), "A Simple
// Nonparametric Test of Predictive Performance", Journal of
// Business & Economics Statistics,  Vol. 10, n°4.
// ------------------------------------------------------------
// Copyright : E. Michaux (2005)
// http://grocer.toolbox.free.fr/grocer.html
 
 
// separate from the list of variable arguments the list of
// exogenous variables and 'noprint' if the user has given this
// argument
grocer_dropna=%f
grocer_prt=%t
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if grocer_argi == 'noprint' then
         grocer_prt=%f
         varargin(grocer_i)=null()
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
         varargin(grocer_i)=null()
      end
   end
end
 
[grocer_y,grocer_namey,grocer_yc,grocer_nameyc,grocer_prests,grocer_boundsvarb,nonna]=...
                  explouniv(grocer_y,grocer_yc,[],['endogenous';'exogenous'],%t,grocer_dropna)
 
n =size(grocer_y,1)
 
// Direction of change statistics
y0  = bool2s(grocer_y > 0)
yc0 = bool2s(grocer_yc > 0)
z0  = bool2s(grocer_y .* grocer_yc >0)
Py  = mean0(y0)
Pyc = mean0(yc0)
P   = mean0(z0)
Pstar = Py*Pyc+(1-Py)*(1-Pyc)
 
V = (1/n)*Pstar*(1-Pstar) // variance of P
Vstar = (1/n)*((2*Py-1)^2)*Pyc*(1-Pyc)+(1/n)*((2*Pyc-1)^2)*Py*(1-Py)+(4/n^2)*Py*Pyc*(1-Py)*(1-Pyc) // variance of Pstar
 
// statistic of test
Sn = (P-Pstar)/(V-Vstar)^0.5
pvalue = 1-cdfnor("PQ",Sn,0,1)	
 
// fill-in tlist
rdchange=tlist(['results';'meth';'y';'yc';'namey';'nameyc';'stat';'pvalue';'P';'Pstar';'prests';'dropna'],...
                'direct. change',grocer_y,grocer_yc,grocer_namey,grocer_nameyc,...
                 Sn,pvalue,P,Pstar,grocer_prests,grocer_dropna)
 
if grocer_prests then
   rdchange(1)($+1)='bounds'
   rdchange('bounds')=grocer_boundsvarb
end
 
if grocer_dropna then
   rdchange(1)($+1)='nonna'
   rdchange('nonna')=nonna
end
 
if grocer_prt then
   prtdchange(rdchange)
end
 
endfunction
