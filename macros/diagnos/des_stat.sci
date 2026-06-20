function r=des_stat(grocer_ly,varargin)
 
// PURPOSE: presents basic statistics on a variable
// ------------------------------------------------------------
// INPUT:
// * grocer_ly = a time series, a real (nx1) vector or a
//   string equal to the name of a time series or a (nx1) real
//   vector between quotes
// * varargin = optional arguments that can be:
//   - 'color=x' where x is numerical representation of the
//   color
//   - 'nbars=n' where n is the # of bars of the histogram
//   - 'bounds=[''b1'';''b2'']' where b1 and b2 are the bounds
//     over which the stats are calculated
//   - 'noprint' if the user does not want to print the results
//   - 'dropna' if the user wants to remove the NA values
//     from the data
// ------------------------------------------------------------
// OUPTUT:
// * r = a results tlist with:
//   - r('meth') = 'des_stat'
//   - r('namey') = name of the variable
//   - r('y') = (n x 1) vector of variables
//   - r('mean') = mean of the variable
//   - r('median') = median of the variable
//   - r('miny') = min of the variable
//   - r('maxy') = min of the variable
//   - r('stdevy') = standard deviation of y
//   - r('skew') = skewness of variable y
//   - r('kurt') = kurtosis of variable y
//   - r('jbstat') = Jarque and Bera stat for normality
//   - r('jbprob') = associated p-value
//   - r('prests') = a boolean indicating whether there is a ts
//     in the regression
//   - r('bounds') = if the variable is a timeseries, the
//     bounds used for the calculations
// ------------------------------------------------------------
// Copyright: Eric Dubois 2007
// http://grocer.toolbox.free.fr/grocer.html
 
// set defaults
grocer_prt=%t
grocer_nbars=20
grocer_color=2
grocer_dropna=%f
 
grocer_nargin=length(varargin)
for grocer_i=grocer_nargin:-1:1
   grocer_argi=varargin(grocer_i)
   if typeof(grocer_argi) == 'string' then
      grocer_argi=strsubst(grocer_argi,' ','')
      if part(grocer_argi,1:6) == 'color=' | ...
        part(grocer_argi,1:6) == 'nbars=' | ...
        part(grocer_argi,1:5) == 'wind=' then
         execstr('grocer_'+grocer_argi)
      elseif part(grocer_argi,1:7) == 'bounds=' then
         grocer_endc=part(grocer_argi,8:length(grocer_argi))
         execstr('grocer_boundsvar='+grocer_endc)
      elseif part(grocer_argi,1:7) == 'noprint' then
         grocer_prt=%f
      elseif grocer_argi == 'dropna' then
         grocer_dropna=%t
      else
         error('not an available option:' +grocer_argi)
      end
   end
end
 
[y,namey,prests,b,nonna]=explone(grocer_ly,[],'unknown',%t,grocer_dropna)
m=mean(y)
med=median(y)
maxy=max(y)
miny=min(y)
stdevy=st_dev(y)
[jb,pn,s,k]=jbnorm_var1(y)
 
r=tlist(['results';'meth';'namey';'y';'mean';'median';'miny';...
'maxy';'stdevy';'skew';'kurt';'jbstat';'jbprob';'prests';...
'dropna'],...
'des_stat',namey,y,m,med,miny,maxy,stdevy,s,k,jb,pn,prests,grocer_dropna)
 
if prests then
   r(1)($+1)='bounds'
   r('bounds')=b
end
 
if grocer_dropna then
   res(1)($+1)='nonna'
   res('nonna')=nonna
end
 
if grocer_prt then
   prt_des_stat(r,%io(2))
   if exists('grocer_wind','local') then
      histg(y,grocer_nbars,grocer_color,grocer_wind)
   else
      histg(y,grocer_nbars,grocer_color)
   end
end
 
endfunction
 
 
